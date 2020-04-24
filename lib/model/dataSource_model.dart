import 'package:flutter/material.dart';
// import 'dart:developer';

import 'package:scoped_model/scoped_model.dart';
import 'package:gm_networking/gm_networking.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:staff_performance/model/entities/performance_entity.dart';
import 'package:staff_performance/model/peformance_data_manager.dart';
import 'package:staff_performance/model/entities/sell_group_entity.dart';

class DataModels extends ShopDataModel {}

class ShopDataModel extends DataModel {
  static ShopDataModel of(BuildContext context) =>
      ScopedModel.of<ShopDataModel>(context);
}

//
class StaffDataModel extends DataModel {
  static StaffDataModel of(BuildContext context) =>
      ScopedModel.of<StaffDataModel>(context);
}

class DataModel extends Model {
  ///shop_performance
  //数据处理类
  PeformanceDataHandle dataHandle;
  ScrollController controller;
  AnimationController animationController;
  CurvedAnimation curved;
  bool isFirst = true; //判断是否是第一次加载
  ///图标是明细还是汇总 0表示明细1表示汇总
  int selectIndex = 0;

//loading 状态
  bool showLoading = false;
//动画是否前进执行
  bool forward = true;

  BuildContext _context;
//默认展示时间还是店铺
  PresentState option = PresentState.PresentStateOwer;
  //请求接口所需要的参数
  final requestMap = <String, dynamic>{};

//当前界面展示的数据选项
  final presentParamMap = <String, dynamic>{};
  //缓存查询出来的所有有效数据（由它解析成其它数据）
  List<Map<String, List<PerformanceEntity>>> performances = new List();
// 分类名称集合
  var sellGroups = <String>[];
//
  SellGroupEntity selectEntity = SellGroupEntity();

  //数据明细
  TableData detailDatas;

  //数据明细
  var chartData = <Map<String, List>>[];

  //数据汇总
  var summaryData = <Map<String, List<dynamic>>>[];
  //绝对值百分比
  var selectPercentage = 0;
  //数据明细展示的数据
  var dataDetail;
  TabController tabController;
  TickerProvider ticker;

  ///分类
  var sellGroupEntitys = <SellGroupEntity>[];
  DateRange oldDate;
  DioWrapper _dio;
  PeformanceRequestManager get peformanceRM =>
      PeformanceRequestManager(dio: _dio);
  DataSourceModel() {}
  void initState(String table, String sql, TickerProvider ticker1,
      DioWrapper dio, BuildContext context) {
    if (isFirst == true || sellGroups.length == 0) {
      detailDatas = new TableData([], []);
      _context = context;
      _dio = dio; //初始化dio
      ticker = ticker1;
      dataHandle = PeformanceDataHandle(tableName: table, sql: sql);
      controller = ScrollController();
      animationController = AnimationController(
          duration: Duration(milliseconds: 250), vsync: ticker)
        ..addListener(() {
          if (animationController.status == AnimationStatus.completed ||
              animationController.status == AnimationStatus.dismissed) {
            option = option == PresentState.PresentStateDate
                ? PresentState.PresentStateOwer
                : PresentState.PresentStateDate;
            assembleData();
            // setState(() {});
          }
        });
      curved =
          CurvedAnimation(parent: animationController, curve: Curves.linear);

      List<String> date = PeformanceDataHandle.getCurrentTimeSpan();
      requestMap.addAll({
        'type': table,
        'groupBy': 'month',
        'sday': '${date.first}',
        'eday': '${date.last}',
        'date_type': 'custom',
      });
      oldDate = new DateRange(date.last, date.last, 'month');
      refreshData();
      // initAllData(ticker, first: true);
      initialTabController(0, 0);
      isFirst = false;
    }
  }

  void initAllData(TickerProvider ticker, {first = false}) async {
    //当前时间
    DateTime sday = DateTime.parse(requestMap['sday']);
    DateTime eday = DateTime.parse(requestMap['eday']);
    //接口请求的时间范围
    DateTime beginDate = DateTime.parse(oldDate.beginDate);
    DateTime overDate = DateTime.parse(oldDate.overDate);
    if (sday.compareTo(beginDate) < 0 ||
        eday.compareTo(overDate) > 0 ||
        requestMap['groupBy'] != oldDate.type) {
      await requestPeformanceData(requestMap).then((entitys) async {
        if (entitys == null || entitys.length == 0) {
          return;
        }
        oldDate = new DateRange(
            requestMap['sday'], requestMap['eday'], requestMap['groupBy']);
        await dataHandle.bathInsert(entitys);
        if (first) {
          sellGroups = sellGroupEntitys.map((entity) {
            return entity.name;
          }).toList();
          selectEntity = sellGroupEntitys?.first;
          selectEntity.currentItem = selectEntity.sellItems?.first;
          initialTabController(0, selectEntity.sellItems.length);
        }
      });
    }
    quetyDataFromDataBase();
  }

  void initialTabController(int initialIndex, int length) {
    tabController = TabController(
        initialIndex: initialIndex,
        length: selectEntity != null ? selectEntity.sellItems.length : 0,
        vsync: ticker);
  }

  void quetyDataFromDataBase() async {
    _showLoading();
    performances = await dataHandle.queryPerforDatas(option,
        sellItemgroupId: '${selectEntity.id}',
        sellItemId: selectEntity.currentItem.id,
        requestMap: requestMap);

    //获取汇总数据
    summaryData = await dataHandle.queryWithDate(
        sellItemgroupId: '${selectEntity.id}',
        sellItemId: selectEntity.currentItem.id,
        requestMap: requestMap);
    _closeLoading();
    assembleData();
  }

  //组装展示的数据
  void assembleData() async {
    if (performances?.length != 0) {
      // _showLoading();
      detailDatas = selectIndex == 1
          ? await dataHandle.assembleTotal(performances, requestMap)
          : await dataHandle.detailDatas(option, performances, requestMap,
              type: selectPercentage);
      chartData =
          dataHandle.chartData(option, requestMap['groupBy'], performances);
      // _closeLoading();
    }
    notifyListeners();
  }

  ///拿所有数据的接口
  Future<List<PerformanceEntity>> requestPeformanceData(
      Map<String, dynamic> param) async {
    _showLoading();
    notifyListeners();
    Map result = new Map();
    try {
      result = await peformanceRM.requestPeformanceData(param);
    } catch (e) {
      Fluttertoast.showToast(msg: '网络错误,请等会再试');
      _closeLoading();
      return null;
    }
    sellGroupEntitys = result['sellGroupEntitys'];
    _closeLoading();
    return result['entitys'];
  }

  //刷新数据
  void refreshData() {
    //当还没加载员工时就不刷新员工数据
    if (requestMap.isNotEmpty) {
      requestPeformanceData(requestMap).then((entitys) async {
        if (entitys == null) {
          notifyListeners();
          return;
        }
        oldDate = new DateRange(
            requestMap['sday'], requestMap['eday'], requestMap['groupBy']);
        await dataHandle.bathInsert(entitys);
        sellGroups = sellGroupEntitys.map((entity) {
          return entity.name;
        }).toList();
        selectEntity = sellGroupEntitys?.first;
        selectEntity.currentItem = selectEntity.sellItems?.first;
        initialTabController(0, selectEntity.sellItems.length);
        quetyDataFromDataBase();
      });
    }
  }

  //店铺日期转化的动画
  void animatChange() {
    if (forward) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
    forward = !forward;
  }

  //开启loading
  void _showLoading() {
    showLoading = true;
    notifyListeners();
  }

  //关闭loading
  void _closeLoading() {
    showLoading = false;
  }
}

class DateRange {
  /// eg: 2019-7-24
  String beginDate;

  /// eg: 2019-7-24
  String overDate;

  ///eg:'year' 'month' 'day'
  String type;
  DateRange(this.beginDate, this.overDate, this.type);
}
