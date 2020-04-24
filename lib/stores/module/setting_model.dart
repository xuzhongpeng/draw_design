/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-08-15 19:54:12
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-08-16 10:15:44
 * @Description: 设置功能的状态
 */
// import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:staff_performance/stores/provider/provider.dart';

import 'package:gm_uikit/gm_uikit.dart';
import 'package:staff_performance/model/entities/sell_item_group_entity.dart';
import 'package:staff_performance/utils/log.dart';

import 'package:staff_performance/model/entities/goal_entity.dart';
import 'package:staff_performance/config/services.dart';

class SettingModel extends GmProvider {
  List<GoalEntity> goalList = <GoalEntity>[];
  List<IndicatorClass> indicatorClazz = <IndicatorClass>[];
  List<Staff> staffs = <Staff>[];
  var sellTargetsList = <SellTargetsEntity>[];
  var sellItemGroupsList = <SellItemGroupEntity>[];
  var staffEntitys = <StaffEntity>[];

  getIndicatorClass() {
    indicatorClazz = List();
    L.p("sellItemGroupsList:$sellItemGroupsList");
    for (var item in sellItemGroupsList) {
      IndicatorClass indicatorClass = IndicatorClass()
        ..id = item.id
        ..name = item.name;
      indicatorClass.indicators = List();
      for (var i = 0; i < (item.sellitems?.length ?? 0); i++) {
        var sellItem = item.sellitems[i];
        if (sellItem.status == "1") {
          indicatorClass.indicators.add(Indicator()
            ..id = sellItem.id
            ..name = sellItem.name
            ..isPercent = sellItem.type == "percent"
            ..status = sellItem.status);
        }
      }
      indicatorClazz.add(indicatorClass);
    }
    // indicatorClazz.add(IndicatorClass()..id = 1..name = "销售相关"..indicators =List.generate(13, (index){
    //   return Indicator()..id = index ..name = "营业额";
    // }));
    // indicatorClazz.add(IndicatorClass()..id = 2..name = "流水相关"..indicators =List.generate(3, (index){
    //   return Indicator()..id = index ..name = "净流水金额"..isPercent = true;
    // }));
    // indicatorClazz.add(IndicatorClass()..id = 2..name = "目标提成"..indicators =List.generate(3, (index){
    //   return Indicator()..id = index ..name = "mubiaoqicheng"..isPercent = true;
    // }));
    // indicatorClazz.add(IndicatorClass()..id = 2..name = "商品相关"..indicators =List.generate(3, (index){
    //   return Indicator()..id = index ..name = "shop"..isPercent = true;
    // }));
    // indicatorClazz.add(IndicatorClass()..id = 2..name = "客户相关"..indicators =List.generate(3, (index){
    //   return Indicator()..id = index ..name = "sldjflsdjfljsd"..isPercent = true;
    // }));
    // notifyListeners();
  }

  //获取目标列表
  Future getSelltargetsList() async {
    final response = await Services.requestSelltargetList();
    if (response.data['code'] == 0) {
      sellTargetsList = (response.data['result']['data'] as List)
          .map((item) => SellTargetsEntity.fromJson(item))
          .toList();
      goalList = GoalEntity.getGoalEntity(sellTargetsList);
      notifyListeners();
    }
  }

  //获取所有指标列表后取可用列表
  Future<void> getSellItemGroupsInGoalCreatePage() async {
    bool isSuccess = await getSellItemGroups();
    if (isSuccess) {
      getIndicatorClass();
      // notifyListeners();
    }
  }

  //获取所有指标列表
  Future<bool> getSellItemGroups() async {
    final response = await Services.requestSellitemGroup();
    if (response.data['code'] == 0) {
      sellItemGroupsList = (response.data['result']['data'] as List)
          .map((item) => SellItemGroupEntity.fromJson(item))
          .toList();
      return true;
    }
    return false;
  }

  //获取员工列表
  Future<void> getStaffs() async {
    final response = await Services.requestGetStaff();
    if (response.data['code'] == 0) {
      staffEntitys = (response.data['result']['data'] as List)
          .map((item) => StaffEntity.fromJson(item))
          .toList();
      List<Staff> staff = List();
      staffs = List<Staff>();
      for (var item in staffEntitys) {
        staffs.add(Staff()
          ..id = item.id
          ..name = item.name
          ..selected = false);
      }
      // notifyListeners();
    }
    // staffs = List<Staff>()..add(Staff()..id =0 ..name = "苏大强"..selected = false)..add(Staff()..id = 1..name = "怒号"..selected = false);
  }

  //设置目标值
  Future<bool> setSellTargets(GoalEntity goalEntity) async {
    Map data = Map();
    data['name'] = goalEntity.title; //指标名称
    data['start_date'] = goalEntity.getParamsStartDate(); //开始日期
    data['end_date'] = goalEntity.getParamsEndDate(); //结束日期
    data['sellitem_id'] = goalEntity.indicator.id; //指标id
    if (goalEntity.indicator.isPercent) {
      data['value'] = (goalEntity.goalValue / 100).toStringAsFixed(2); //目标值
    } else {
      data['value'] = (goalEntity.goalValue).toStringAsFixed(2);
    }
    if (goalEntity.dateType == DateTimeSelectType.BY_YEAR.index) {
      data['date_type'] = "year";
    } else if (goalEntity.dateType == DateTimeSelectType.BY_MONTH.index) {
      data['date_type'] = "month";
    } else {
      data['date_type'] = "day";
    }

    List<Map> details = List();
    for (var staff in goalEntity.staffs) {
      Map detail = Map();
      detail['ownerable_id'] = staff.id;
      detail['ownerable_type'] = "staff";
      details.add(detail);
    }
    data['details'] = details;
    L.p("setSellTargets data:${data}");
    final response = await Services.requestSelltargets(data);
    if (response.data['code'] == 0) {
      return true;
    } else {
      return false;
    }
  }

  //设置指标值
  Future<bool> setSellitems(Map<int, List<SellItemEntity>> choice,
      Map<int, List<SellItemEntity>> unChoice) async {
    List<Map> data = List();
    for (var i = 0; i < choice.length; i++) {
      var choiceList = choice[i];
      var unChoiceList = unChoice[i];
      int sort = 0;
      for (var choiceItem in choiceList) {
        data.add(
            {"id": choiceItem.id, "sort": sort, "status": choiceItem.status});
        sort++;
      }
      for (var unChoiceItem in unChoiceList) {
        data.add({
          "id": unChoiceItem.id,
          "sort": sort,
          "status": unChoiceItem.status
        });
        sort++;
      }
    }
    L.p("setSellitems data:$data");
    final response = await Services.requestSellItems(data);
    if (response.data['code'] == 0) {
      return true;
    } else {
      return false;
    }
  }

  //查看目标详情
  Future<bool> getSellTargetsDetail(int id, int companyId) async {
    final response =
        await Services.requestSellTargetByStaff(id, {"company_id": companyId});
    if (response.data['code'] == 0) {
      return true;
    } else {
      return false;
    }
  }
}
