/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-08-15 16:25:01
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-09-04 14:33:32
 * @Description: 店铺与员工的数据相关方法
 */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:staff_performance/utils/database_manager.dart';
import 'entities/performance_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'entities/sell_group_entity.dart';
import 'package:staff_performance/config/services.dart';

final String detailName = '所选日期总计';
String detailShopName(String tableName) =>
    tableName == 'shop' ? '所选店铺总计' : '所选员工总计';
final String color = Color.fromRGBO(251, 248, 227, 1).value.toString();
//状态展示
enum PresentState {
  ///展示日期
  PresentStateDate,

  ///展示数据的拥有者，可以是人或者店铺
  PresentStateOwer,
}

class PeformanceRequestManager {
  PeformanceRequestManager();

  //接口请求
  Future<Map> requestPeformanceData(Map<String, dynamic> param) async {
    final response = await Services.requestSellList(param);
    var entitys = <PerformanceEntity>[];
    var sellGroupEntitys = <SellGroupEntity>[];
    entitys = (response.data['result']['data'] as List).map((item) {
      return PerformanceEntity.fromJson(item);
    }).toList();
    sellGroupEntitys =
        (response.data['result']['sellitemgroups'] as List).map((elment) {
      return SellGroupEntity.fromJson(elment);
    }).toList();
    return {'entitys': entitys, 'sellGroupEntitys': sellGroupEntitys};
  }
}

//逻辑处理
class PeformanceDataHandle {
  final String tableName;
  final String sql;
  PeformanceDataHandle({@required this.tableName, @required this.sql});
  static Future<String> get docPath async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String docPath = appDocDir.path;
    return docPath;
  }

  static List<String> getCurrentTimeSpan() {
    DateTime now = DateTime.now();
    String current =
        DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 0));

    int month = now.month - 12;
    String last =
        DateFormat('yyyy-MM-dd').format(DateTime(now.year, month, 01));
    return [last, current];
  }

  static String translationDateFormatter(String date, {String formatKey}) {
    String format = 'yyyy年MM月dd日';
    switch (formatKey) {
      case 'year':
        format = 'yyyy年';
        break;
      case 'month':
        format = 'yyyy年MM月';
        break;
      default:
        format = 'yyyy年MM月dd日';
        break;
    }
    DateTime time = DateTime.parse(date);
    if (time == null) {
      return DateFormat(format).format(DateTime.now());
    }
    String current =
        DateFormat(format).format(DateTime(time.year, time.month, time.day));
    return current;
  }

  static String dateToString(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  List<String> timesList(String format, String beginTime, String endTime) {
    DateTime begin = DateFormat('yyyy-MM-dd').parse(beginTime);
    DateTime end = DateFormat('yyyy-MM-dd').parse(endTime);
    final values = <String>[];
    while (begin.compareTo(end) <= 0) {
      values.add(PeformanceDataHandle.translationDateFormatter(begin.toString(),
          formatKey: format));
      begin = nextDate(begin, format);
    }
    return values;
  }

  static Function getColor({int index}) {
    index = 0;
    final colors = [
      '#6F78CA',
      '#4BCDFD',
      '#8CCE69',
      '#FDB55D',
      '#FB7152',
      '#528FFB',
      '#D68600',
    ];
    return (() {
      int next = index % colors.length;
      index++;
      return colors[next];
    });
  }

  int translationToTimestamp(String time, String formatKey) {
    String format = formatKey == 'year'
        ? 'yyyy'
        : (formatKey == 'month' ? 'yyyy-MM' : 'yyyy-MM-dd');
    return DateFormat(format).parse(time).millisecondsSinceEpoch ~/ 1000;
  }

  DateTime nextDate(DateTime time, String format) {
    if (format == 'year') {
      return DateTime(time.year + 1);
    } else if (format == 'month') {
      return DateTime(time.year, time.month + 1);
    } else {
      return DateTime(time.year, time.month, time.day + 1);
    }
  }

  ///插入数据
  Future<void> bathInsert(List entitys) async {
    String path = await PeformanceDataHandle.docPath + '/peformance.db';
    GMDataBaseManager dbManager = GMDataBaseManager();
    await dbManager.openDataBase(path, tableName, sql);
    await dbManager.deleteTable();
    await dbManager.bathInsert(entitys);
    await dbManager.close();
  }

  ///查询业绩信息
  Future<List<Map<String, List<PerformanceEntity>>>> queryPerforDatas(
      PresentState state,
      {String sellItemgroupId = '0',
      int sellItemId = 0,
      Map<String, dynamic> requestMap}) async {
    // if (state == PresentState.PresentStateDate) {
    //   return await _queryWithDate(
    //       sellItemgroupId: sellItemgroupId,
    //       sellItemId: sellItemId,
    //       requestMap: requestMap);
    // }
    return await _queryWithOwer(
        sellItemgroupId: sellItemgroupId,
        sellItemId: sellItemId,
        requestMap: requestMap);
  }

  Future<List<Map<String, List<PerformanceEntity>>>> _queryWithOwer(
      {String sellItemgroupId = '0',
      int sellItemId = 0,
      Map<String, dynamic> requestMap}) async {
    List<List<String>> owerList = await queryOwnerNameList();
    final values = <Map<String, List<PerformanceEntity>>>[];
    String path = await docPath + '/peformance.db';
    GMDataBaseManager dbManager = GMDataBaseManager();
    await dbManager.openDataBase(path, tableName, sql);
    //店铺汇总
    List<PerformanceEntity> item = await queryShopAll(
        sellItemgroupId: sellItemgroupId,
        sellItemId: sellItemId,
        requestMap: requestMap,
        dbManager: dbManager);
    if (item.length > 0) {
      values.add({detailShopName(requestMap['type']): item});
    }
    for (List<String> ower in owerList) {
      List<PerformanceEntity> items = await _queryDatasGroupByOwer(
              sellItemgroupId: sellItemgroupId,
              sellItemId: sellItemId,
              requestMap: requestMap,
              dbManager: dbManager,
              ower: ower) ??
          <PerformanceEntity>[];
      values.add({ower[0]: items});
    }
    await dbManager.close();
    return values;
  }

//获取时间汇总
  Future<List<Map<String, List<PerformanceEntity>>>> queryWithDate(
      {String sellItemgroupId = '0',
      int sellItemId = 0,
      Map<String, dynamic> requestMap}) async {
    String format = requestMap['groupBy'];
    List<Map<String, dynamic>> dateList =
        await queryDateList(requestMap: requestMap);

    final values = <Map<String, List<PerformanceEntity>>>[];
    String path = await docPath + '/peformance.db';
    GMDataBaseManager dbManager = GMDataBaseManager();
    await dbManager.openDataBase(path, tableName, sql);
    double total = 0;
    for (Map<String, dynamic> item in dateList) {
      DateTime time = DateTime(int.parse(item['year'] ?? 0),
          int.parse(item['month'] ?? 0), int.parse(item['day'] ?? 0));
      List<PerformanceEntity> items = await _queryDatasGroupByDate(
              sellItemgroupId: sellItemgroupId,
              sellItemId: sellItemId,
              format: format,
              dbManager: dbManager,
              time: time,
              requestMap: requestMap) ??
          <PerformanceEntity>[];
      String date =
          translationDateFormatter(time.toString(), formatKey: format);
      values.add({date: items});
    }
    await dbManager.close();

    return values;
  }

  ///明细数据组装
  Future<TableData> detailDatas(
      PresentState state,
      List<Map<String, List<PerformanceEntity>>> performanceEnts,
      Map<String, dynamic> requestMap,
      {int type = 0}) async {
    return type == 0
        ? (state == PresentState.PresentStateDate
            ? await _detailDataAccodingtoDates(performanceEnts, requestMap)
            : _detailsAccodingtoOwers(performanceEnts, requestMap))
        : (state == PresentState.PresentStateDate
            ? await _assemblePercentageDates(performanceEnts, requestMap)
            : _assemblePercentageOwers(performanceEnts, requestMap));
  }

  //转化chart数据（绝对值）
  List<Map<String, List>> chartData(PresentState state, String groupBy,
      List<Map<String, List<PerformanceEntity>>> performanceEnts) {
    return state == PresentState.PresentStateDate
        ? _chartDataWithDate(performanceEnts)
        : _chartDataWithOwer(groupBy, performanceEnts);
  }

  List<Map<String, List>> _chartDataWithDate(
      List<Map<String, List<PerformanceEntity>>> performance) {
    // var performanceEnts = json.decode(json.encode(performance));
    List<Map<String, List<PerformanceEntity>>> performanceEnts =
        List.from(performance);

    performanceEnts.removeRange(0, 1); //去掉汇总数据
    if (performanceEnts.length > 0) {
      var allDate = performanceEnts[0].values.first;
      var res = allDate.map((element) {
        final result = <String, List>{};
        // List<PerformanceEntity> current = element;
        int index = allDate.indexOf(element);
        final values = performanceEnts.map((perfor) {
          var per = perfor.values.first[index];
          return {'domain': perfor.keys.first, 'measure': per.value};
        }).toList();
        result[element.transactionDate] = values;
        return result;
      }).toList();
      res.removeRange(0, 1); //移除汇总信息
      return res;
    }
    return [];
  }

  List<Map<String, List>> _chartDataWithOwer(
      String groupBy, List<Map<String, List<PerformanceEntity>>> performance) {
    List<Map<String, List<PerformanceEntity>>> performanceEnts =
        List.from(performance);
    performanceEnts.removeRange(0, 1);
    return performanceEnts.map((element) {
      final result = <String, List>{};
      List<PerformanceEntity> current = element.values.first.sublist(1);
      final values =
          current.where((item) => item.ownerableName != null).map((perfor) {
        return {'domain': perfor.transactionDate, 'measure': perfor.value};
      }).toList();
      result[element.keys.first] = values;
      return result;
    }).toList();
  }

  ///根据dates整理数据
  Future<TableData> _detailDataAccodingtoDates(
      List<Map<String, List<PerformanceEntity>>> performanceEnts,
      Map<String, dynamic> requestMap) async {
    final result = <Map<String, dynamic>>[];
    if (performanceEnts.length == 0) {
      return _changeDataToTable(result);
    }
    //先确定表头
    final titles = <String>[];
    List<Map<String, dynamic>> value =
        await queryShopByDate(requestMap: requestMap);
    titles.add(detailShopName(requestMap['type']));
    for (Map<String, dynamic> shop in value) {
      titles.add(shop['owner_name']);
    }
    result.add({'title': '日期', 'value': titles});

    // for (Map<String, List<PerformanceEntity>> item in performanceEnts) {
    //   List<PerformanceEntity> perfors = item.values.first;
    //   final elements = <String>[];
    //   String title = item.keys.first;
    //   for (var element in perfors) {
    //     elements.add(element.value ?? '0.000');
    //   }
    //   result.add({'title': title, 'value': elements});
    // }
    // return result;
    var allDate = performanceEnts.first.values.first;
    var res = allDate.map((element) {
      String title = element.transactionDate;
      int index = allDate.indexOf(element);
      final elements = performanceEnts.map((perfor) {
        return perfor.values.first[index].value;
      }).toList();
      return {'title': title, 'value': elements};
    }).toList();
    result.addAll(res);

    TableData data = _changeDataToTable(result);
    data.dataSource[0]['color'] = color;
    return data;
  }

  ///根据ower整理数据
  TableData _detailsAccodingtoOwers(
      List<Map<String, List<PerformanceEntity>>> performanceEnts,
      Map requestMap) {
    // final result = <Map<String, dynamic>>[];
    List<Map<String, dynamic>> header = new List();
    List<Map<String, dynamic>> dataSource = new List();

    String tableName = requestMap['type'] == 'shop' ? '店铺' : '员工';
    if (performanceEnts.length <= 1) {
      return TableData([], []);
    }

    final titles = <String>[];
    for (var element in performanceEnts[1].values.first) {
      titles.add(element.transactionDate);
    }
    // result.add({'title': tableName, 'value': titles});
    //组装后面所有标题
    header.add({
      'label': tableName,
      'prop': tableName,
      'sortable': true,
      'fixed': 'left'
    });
    titles.forEach((v) {
      Map<String, dynamic> mheader = {
        'label': v,
        'prop': v,
        'sortable': true,
      };
      header.add(mheader);
    });
    for (Map<String, List<PerformanceEntity>> item in performanceEnts) {
      List<PerformanceEntity> perfors = item.values.first;
      final elements = <String>[];
      String title = item.keys.first;
      for (var element in perfors) {
        elements.add(element.value ?? '0.000');
      }
      int index = 0;
      Map<String, dynamic> mdataSource = new Map();

      mdataSource[header.first['prop']] = title;
      perfors.forEach((v) {
        index++;
        mdataSource[header[index]['prop']] = v.value ?? '0.000';
      });
      mdataSource['id'] =
          performanceEnts.indexOf(item) == 0 ? null : perfors[0].ownerableId;
      dataSource.add(mdataSource);
      // result.add({'title': title, 'value': elements});
    }
    dataSource[0]['color'] = color;
    return TableData(header, dataSource);
  }

  //根据日期查询数据groupBy Date
  Future<List<PerformanceEntity>> _queryDatasGroupByOwer(
      {String sellItemgroupId,
      int sellItemId,
      Map<String, dynamic> requestMap,
      GMDataBaseManager dbManager,
      List<String> ower}) async {
    String format = requestMap['groupBy'];
    String start = requestMap['sday'];
    String end = requestMap['eday'];
    String type = requestMap['type'];
    String condition = format == 'day'
        ? 'transaction_year, transaction_month, transaction_day'
        : (format == 'month'
            ? 'transaction_year, transaction_month'
            : 'transaction_year');

    String groupCondition = 'A.transaction_year=B.transaction_year';
    groupCondition += format == 'month'
        ? ' AND A.transaction_month=B.transaction_month'
        : (format == 'day'
            ? ' AND A.transaction_month=B.transaction_month AND A.transaction_day=B.transaction_day'
            : '');
    List<Map<String, dynamic>> total = await dbManager.queryModelsWithSQL(
        sql:
            'SELECT  ownerable_id, ownerable_type, owner_name, sellitem_id, sellitem_code, sellitem_name, sellitemgroup_id, sellitemgroup_code, sellitemgroup_name, Round(ifnull(SUM(value),0.0),2) AS value, transaction_date, transaction_year, transaction_month, transaction_day, transaction_week, transaction_time FROM $type WHERE transaction_date between "$start" AND "$end" AND sellItemgroup_Id = ? AND sellitem_id = ? AND owner_name = ? AND ownerable_id = ?',
        arguments: [sellItemgroupId, sellItemId, ower[0], ower[1]]);

    List<Map<String, dynamic>> values = await dbManager.queryModelsWithSQL(
        sql: 'select "${ower[1]}" as ownerable_id, B.ownerable_type, "${ower[0]}" as owner_name, A.sellitem_id, A.sellitem_code, A.sellitem_name, A.sellitemgroup_id, A.sellitemgroup_code, A.sellitemgroup_name, Round(ifnull(B.value,0.0),2) as value, A.transaction_date, A.transaction_year, A.transaction_month, A.transaction_day, A.transaction_week, A.transaction_time  from' +
            '(select * from $type Where transaction_date Between "$start" And "$end" group by $condition) AS A left join' +
            '(SELECT ownerable_id, ownerable_type, owner_name, sellitem_id, sellitem_code, sellitem_name, sellitemgroup_id, sellitemgroup_code, sellitemgroup_name, SUM(value) AS value, transaction_date, transaction_year, transaction_month, transaction_day, transaction_week, transaction_time FROM $type WHERE transaction_date between "$start" AND "$end" AND sellItemgroup_Id = ? AND sellitem_id = ? AND owner_name = ?  AND ownerable_id = ? GROUP BY $condition) AS B ' +
            'on $groupCondition order by A.transaction_date',
        arguments: [sellItemgroupId, sellItemId, ower[0], ower[1]]);
    List<PerformanceEntity> totalPer = total.map((value) {
      final per = PerformanceEntity.fromJson(value);
      per.transactionDate = detailName;
      return per;
    }).toList();
    List<PerformanceEntity> itemPer = values.map((value) {
      final per = PerformanceEntity.fromJson(value);
      per.transactionDate =
          translationDateFormatter(per.transactionDate, formatKey: format);
      return per;
    }).toList();
    return (totalPer + itemPer);
  }

  //根据以日期查询数据groupBy Ower
  Future<List<PerformanceEntity>> _queryDatasGroupByDate(
      {String sellItemgroupId,
      int sellItemId,
      String format,
      GMDataBaseManager dbManager,
      DateTime time,
      Map<String, dynamic> requestMap}) async {
    List<dynamic> arguments = [sellItemgroupId, sellItemId];
    String condition;
    String type = requestMap['type'];
    switch (format) {
      case 'day':
        {
          condition =
              'transaction_year = ? AND transaction_month = ? AND transaction_day = ?';
          arguments.addAll([time.year, time.month, time.day]);
        }
        break;
      case 'month':
        {
          condition = 'transaction_year = ? AND transaction_month = ?';
          arguments.addAll([time.year, time.month]);
        }
        break;
      default:
        {
          condition = 'transaction_year = ?';
          arguments.addAll([time.year]);
        }
        break;
    }
    List<Map<String, dynamic>> totals = await dbManager.queryModelsWithSQL(
        sql:
            'SELECT ownerable_id, ownerable_type, owner_name, sellitem_id, sellitem_code, sellitem_name, sellitemgroup_id, sellitemgroup_code, sellitemgroup_name, SUM(value) AS value, transaction_date, transaction_year, transaction_month, transaction_day, transaction_week, transaction_time FROM $type WHERE sellItemgroup_Id = ? AND sellitem_id = ? AND $condition',
        arguments: arguments);
    String start = requestMap['sday'];
    String end = requestMap['eday'];
    String sql =
        'SELECT A.ownerable_id, A.ownerable_type, B.owner_name, B.sellitem_id, B.sellitem_code, B.sellitem_name, B.sellitemgroup_id, B.sellitemgroup_code, B.sellitemgroup_name,Round(ifnull(B.value,0.0),2) as value, B.transaction_date, B.transaction_year, B.transaction_month, B.transaction_day, B.transaction_week, B.transaction_time FROM ' +
            '(select * from $type Where transaction_date Between "$start" And "$end" group by ownerable_id)  A left join' +
            '(SELECT * FROM $type WHERE sellItemgroup_Id = ? AND sellitem_id = ? AND $condition GROUP BY ownerable_id)  B on A.ownerable_id=B.ownerable_id';
    List<Map<String, dynamic>> values =
        await dbManager.queryModelsWithSQL(sql: sql, arguments: arguments);
    // 'SELECT ownerable_id, ownerable_type, owner_name, sellitem_id, sellitem_code, sellitem_name, sellitemgroup_id, sellitemgroup_code, sellitemgroup_name, SUM(value) AS value, transaction_date, transaction_year, transaction_month, transaction_day, transaction_week, transaction_time FROM shop WHERE sellItemgroup_Id = ? AND sellitem_id = ? AND $condition GROUP BY ownerable_id',
    List<PerformanceEntity> totalPer = totals.map((value) {
      final per = PerformanceEntity.fromJson(value);
      per.ownerableName = detailShopName(requestMap['type']);
      return per;
    }).toList();

    List<PerformanceEntity> itemPer = values.map((value) {
      return PerformanceEntity.fromJson(value);
    }).toList();
    return (totalPer + itemPer);
  }

  ///查询所有的owers
  Future<List<List<String>>> queryOwnerNameList({bool asc = true}) async {
    String path = await docPath + '/peformance.db';
    GMDataBaseManager dbManager = GMDataBaseManager();
    await dbManager.openDataBase(path, tableName, sql);
    List<Map<String, dynamic>> values = await dbManager.queryModelsWithSQL(
        sql:
            'SELECT owner_name,ownerable_id FROM $tableName GROUP BY ownerable_id');
    await dbManager.close();
    return values.map((value) {
      List<String> res = [];
      res.add(value.values.first.toString());
      res.add(value['ownerable_id'].toString());
      return res;
    }).toList();
  }

  ///查询所有的日期表
  Future<List<Map<String, dynamic>>> queryDateList(
      {@required Map<String, dynamic> requestMap}) async {
    String formatter = requestMap['groupBy'];
    String condition = formatter == 'day'
        ? 'transaction_year, transaction_month, transaction_day'
        : (formatter == 'month'
            ? 'transaction_year, transaction_month'
            : 'transaction_year');
    String start = requestMap['sday'];
    String end = requestMap['eday'];
    String path = await docPath + '/peformance.db';
    GMDataBaseManager dbManager = GMDataBaseManager();
    await dbManager.openDataBase(path, tableName, sql);
    List<Map<String, dynamic>> values = await dbManager.queryModelsWithSQL(
        sql: 'SELECT transaction_year as year, transaction_month as month, transaction_day as day FROM $tableName ' +
            'Where transaction_date Between "$start" And "$end" GROUP BY $condition order by transaction_date');
    await dbManager.close();
    return values;
  }

//根据日期查询该日期内有哪些店铺有业绩（确定明细的表头）
  Future<List<Map<String, dynamic>>> queryShopByDate(
      {@required Map<String, dynamic> requestMap}) async {
    GMDataBaseManager dbManager = GMDataBaseManager();
    String start = requestMap['sday'];
    String end = requestMap['eday'];
    String type = requestMap['type'];
    String path = await docPath + '/peformance.db';
    await dbManager.openDataBase(path, tableName, sql);
    List<Map<String, dynamic>> values = await dbManager.queryModelsWithSQL(
        sql:
            'select owner_name,ownerable_id from $type Where transaction_date Between "$start" And "$end" group by ownerable_id;');
    await dbManager.close();
    return values;
  }

  //查询店铺汇总信息
  Future<List<PerformanceEntity>> queryShopAll(
      {String sellItemgroupId,
      int sellItemId,
      String format,
      GMDataBaseManager dbManager,
      Map<String, dynamic> requestMap}) async {
    List<dynamic> arguments = [sellItemgroupId, sellItemId];
    String condition;
    String format = requestMap['groupBy'];
    String start = requestMap['sday'];
    String end = requestMap['eday'];
    String type = requestMap['type'];
    String groupCondition = 'A.transaction_year=B.transaction_year';
    switch (format) {
      case 'day':
        {
          condition = 'transaction_year,transaction_month,transaction_day';
          groupCondition +=
              ' AND A.transaction_month=B.transaction_month AND A.transaction_day=B.transaction_day';
        }
        break;
      case 'month':
        {
          condition = 'transaction_year,transaction_month';
          groupCondition += ' AND A.transaction_month=B.transaction_month';
        }
        break;
      default:
        {
          condition = 'transaction_year';
        }
        break;
    }

    //店铺汇总
    List<Map<String, dynamic>> totals = await dbManager.queryModelsWithSQL(
        sql: 'select B.ownerable_id, B.ownerable_type, B.owner_name, B.sellitem_id,B.sellitem_code,B.sellitem_name, B.sellitemgroup_id, B.sellitemgroup_code, B.sellitemgroup_name, Round(ifnull(B.value,0.0),2) as value, A.transaction_date, A.transaction_year, A.transaction_month, A.transaction_day, A.transaction_week, A.transaction_time  from (select * from $type Where transaction_date Between "$start" And "$end" group by $condition) AS A left join' +
            '(SELECT ownerable_id, ownerable_type, ("${detailShopName(requestMap['type'])}") as owner_name, sellitem_id, sellitem_code, sellitem_name, ' +
            'sellitemgroup_id, sellitemgroup_code, sellitemgroup_name, Round(ifnull(SUM(value),0.0),2) AS value, transaction_date, transaction_year,' +
            ' transaction_month, transaction_day, transaction_week, transaction_time FROM $type WHERE  transaction_date between "$start" AND "$end" AND sellItemgroup_Id = ? AND ' +
            'sellitem_id = ?  group by $condition) AS B on $groupCondition order by A.transaction_date',
        arguments: arguments);

    //日期汇总
    List<Map<String, dynamic>> total = await dbManager.queryModelsWithSQL(
        sql: 'SELECT ownerable_id, ownerable_type, owner_name, sellitem_id, sellitem_code, sellitem_name, sellitemgroup_id, sellitemgroup_code, sellitemgroup_name, ' +
            'Round(ifnull(SUM(value),0.0),2) AS value,("$detailName") transaction_date, transaction_year, transaction_month, transaction_day, transaction_week, transaction_time FROM $type WHERE  ' +
            ' transaction_date between "$start" AND "$end" AND sellItemgroup_Id = ? AND sellitem_id = ? ',
        arguments: arguments);
    List<PerformanceEntity> itemPer = [];
    List<PerformanceEntity> all = totals.map((value) {
      final per = PerformanceEntity.fromJson(value);
      per.transactionDate =
          translationDateFormatter(per.transactionDate, formatKey: format);
      return per;
    }).toList();
    PerformanceEntity totalData = PerformanceEntity.fromJson(total[0]);
    if (totalData.ownerableId != null ||
        totalData.transactionDate == detailName) {
      itemPer.add(totalData);
    }
    itemPer.addAll(all);
    return itemPer;
  }

  ///汇总数据组装
  Future<TableData> assembleTotal(
      List<Map<String, List<PerformanceEntity>>> performanceEnts,
      Map<String, dynamic> requestMap) async {
    final result = <Map<String, dynamic>>[];

    if (performanceEnts == null || performanceEnts.length == 0) {
      return _changeDataToTable(result);
    }
    var getData = await _detailDataAccodingtoDates(performanceEnts, requestMap);
    // getData.dataSource.removeRange(0, 1);
    final titles = <String>[];
    titles.add(performanceEnts[0].values.first.first.sellitemName);
    result.add({'title': '日期', 'value': titles});

    for (Map<String, dynamic> item in getData.dataSource) {
      var perfors = item[detailShopName(tableName)];

      final elements = <String>[];
      String title = item.values.first;
      // for (var element in perfors) {
      elements.add(perfors ?? '0.000');
      // }
      result.add({'title': title, 'value': elements});
    }
    TableData data = _changeDataToTable(result);
    data.dataSource[0]['color'] = color;
    return data;
  }

  ///日期格式计算百分比
  Future<TableData> _assemblePercentageDates(
      List<Map<String, List<PerformanceEntity>>> performanceEnts,
      Map<String, dynamic> requestMap) async {
    final result = <Map<String, dynamic>>[];
    if (performanceEnts.length == 0) {
      return _changeDataToTable(result);
    }
    //先确定表头
    final titles = <String>[];
    List<Map<String, dynamic>> value =
        await queryShopByDate(requestMap: requestMap);
    // titles.add(detailShopName);
    for (Map<String, dynamic> shop in value) {
      titles.add(shop['owner_name']);
    }
    result.add({'title': '日期', 'value': titles});
    var allDate = performanceEnts.first.values.first;
    var res = allDate.map((element) {
      String title = element.transactionDate;
      int index = allDate.indexOf(element);
      final elements = performanceEnts.map((perfor) {
        // var total = performanceEnts.first.values.first[index].value;
        var total = perfor.values.first.first.value; //取出每行的总金额

        if (double.parse(total) == 0.0) {
          return '0.0%';
        }
        var item = perfor.values.first[index].value;
        var res = double.parse(item) / double.parse(total) * 100;
        return res.toStringAsFixed(1).toString() + '%';
      }).toList();
      elements.removeRange(0, 1); //去掉汇总
      return {'title': title, 'value': elements};
    }).toList();
    res.removeRange(0, 1);
    result.addAll(res);
    return _changeDataToTable(result);
  }

  ///根据ower整理百分比数据
  TableData _assemblePercentageOwers(
      List<Map<String, List<PerformanceEntity>>> performanceEnts,
      Map requestMap) {
    // final result = <Map<String, dynamic>>[];
    List<Map<String, dynamic>> header = new List();
    List<Map<String, dynamic>> dataSource = new List();

    String tableName = requestMap['type'] == 'shop' ? '店铺' : '员工';
    if (performanceEnts.length <= 1) {
      return TableData([], []);
    }

    final titles = <String>[];
    for (var element in performanceEnts[1].values.first) {
      titles.add(element.transactionDate);
    }
    titles.removeRange(0, 1);
    header.add({
      'label': tableName,
      'prop': tableName,
      'sortable': true,
      'fixed': 'left'
    });
    titles.forEach((v) {
      Map<String, dynamic> mheader = {
        'label': v,
        'prop': v,
        'sortable': true,
      };
      header.add(mheader);
    });
    // result.add({'title': tableName, 'value': titles});
    for (Map<String, List<PerformanceEntity>> item in performanceEnts) {
      //去掉所选日期汇总
      if (performanceEnts.indexOf(item) != 0) {
        List<PerformanceEntity> perfors = item.values.first;

        // final elements = <String>[];
        String title = item.keys.first;
        Map<String, dynamic> mdataSource = new Map();

        mdataSource[header.first['prop']] = title;
        mdataSource[header[0]['prop']] = title;
        int index = 0;
        for (var element in perfors) {
          var total = performanceEnts.first.values.first[index].value;

          if (index != 0) {
            var item = element.value ?? '0.000';

            if (double.tryParse(total).toInt() == 0) {
              mdataSource[header[index]['prop']] = '0.0%';
            } else {
              var res = double.parse(item) / double.parse(total) * 100;
              mdataSource[header[index]['prop']] =
                  res.toStringAsFixed(1).toString() + '%';
            }
            mdataSource['id'] = element.ownerableId;
          }
          index++;
        }
        dataSource.add(mdataSource);
        // result.add({'title': title, 'value': elements});
      }
    }
    return TableData(header, dataSource);
  }

  //转化chart数据（百分比）
  List<Map<String, List>> percentChartData(List<Map<String, dynamic>> datas) {
    // print('ee');
    var domain = datas.first;
    List<Map<String, List>> result = [];
    for (var element in datas) {
      if (datas.indexOf(element) != 0) {
        final res = <String, List>{};
        List<String> current = element['value'];
        int index = 0;
        final values = current.map((perfor) {
          var item = {'domain': domain['value'][index], 'measure': perfor};
          index++;
          return item;
        }).toList();
        res[element['title']] = values;
        // return result;
        result.add(res);
      }
    }
    return result;
  }

  ///把数据组装成table兼容的格式
  TableData _changeDataToTable(List<Map<String, dynamic>> items) {
    List<Map<String, dynamic>> header = new List();
    List<Map<String, dynamic>> dataSource = new List();
    Map<String, List<Map<String, dynamic>>> result = new Map();
    items.forEach((item) {
      //组装header
      if (items.indexOf(item) == 0) {
        //��装第一个标题
        Map<String, dynamic> mheader = {
          'label': item['title'],
          'prop': item['title'],
          'sortable': true,
          'fixed': 'left'
        };
        header.add(mheader);
        //组装后面所有标题
        item['value'].forEach((v) {
          Map<String, dynamic> mheader = {
            'label': v,
            'prop': v,
            'sortable': true,
          };
          header.add(mheader);
        });
      }
      //组装dataSource
      else {
        Map<String, dynamic> mdataSource = new Map();
        //组装第一条数据
        mdataSource[header[0]['prop']] = item['title'];
        List dataItem = List.from(item['value']);
        int index = 0;
        dataItem.forEach((v) {
          index++;

          mdataSource[header[index]['prop']] = v;
        });
        dataSource.add(mdataSource);
      }
    });

    return TableData(header, dataSource);
  }
}

class TableData {
  List<Map<String, dynamic>> header;
  List<Map<String, dynamic>> dataSource;

  TableData(this.header, this.dataSource);
}
