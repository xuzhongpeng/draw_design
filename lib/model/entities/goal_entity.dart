import 'package:gm_uikit/gm_uikit.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staff_performance/model/entities/sell_item_group_entity.dart';
import 'package:staff_performance/utils/log.dart';
import 'package:staff_performance/utils/number_format_util.dart';
part 'goal_entity.g.dart';

class GoalEntity {
  String title;
  String startDate;
  DateTime startDateTime;
  DateTime endDateTime;
  String endDate;
  Indicator indicator;
  double goalValue;
  double reachValue;
  int dateType;
  List<Staff> staffs = <Staff>[];

  String getDefaultDate() {
    var dateTime = DateTime.now();
    startDateTime = DateTime(dateTime.year, dateTime.month + 1, 1);
    endDateTime = DateTime(dateTime.year, dateTime.month + 2, 0);
    dateType = DateTimeSelectType.BY_MONTH.index;
    startDate = DateUtil.getDateStrByDateTime(dateTime,
        format: GMDateFormat.ZH_YEAR_MONTH);
    endDate = DateUtil.getDateStrByDateTime(dateTime,
        format: GMDateFormat.ZH_YEAR_MONTH);
    return startDate;
  }

  String getNetDate() {
    return "$startDate ~ $endDate";
  }

  getGoalValue() {
    if (indicator.isPercent) {
      return "${(goalValue * 100).toStringAsFixed(0)}%";
    } else {
      return goalValue.toStringAsFixed(2);
    }
  }

  getParamsStartDate() {
    if (dateType == DateTimeSelectType.BY_DAY.index) {
      return DateUtil.getDateStrByDateTime(startDateTime,
          format: GMDateFormat.YEAR_MONTH_DAY);
    } else if (dateType == DateTimeSelectType.BY_MONTH.index) {
      return DateUtil.getDateStrByDateTime(startDateTime,
          format: GMDateFormat.YEAR_MONTH_DAY);
    } else if (dateType == DateTimeSelectType.BY_YEAR.index) {
      return DateUtil.getDateStrByDateTime(startDateTime,
          format: GMDateFormat.YEAR_MONTH_DAY);
    }
    return DateUtil.getDateStrByDateTime(startDateTime,
        format: GMDateFormat.YEAR_MONTH_DAY);
  }

  getParamsEndDate() {
    if (dateType == DateTimeSelectType.BY_DAY.index) {
      return DateUtil.getDateStrByDateTime(endDateTime,
          format: GMDateFormat.YEAR_MONTH_DAY);
    } else if (dateType == DateTimeSelectType.BY_MONTH.index) {
      return DateUtil.getDateStrByDateTime(endDateTime,
          format: GMDateFormat.YEAR_MONTH_DAY);
    } else if (dateType == DateTimeSelectType.BY_YEAR.index) {
      return DateUtil.getDateStrByDateTime(endDateTime,
          format: GMDateFormat.YEAR_MONTH_DAY);
    }
    return DateUtil.getDateStrByDateTime(endDateTime,
        format: GMDateFormat.YEAR_MONTH_DAY);
  }

  isValidGoalValue() {
    L.p("goalValue:$goalValue");
    if (goalValue == null) {
      return false;
    }
    if (goalValue == 0.00) {
      return false;
    }
    int lastIndex = goalValue.toString().lastIndexOf(".");
    L.p("lastIndex:$lastIndex");
    if (lastIndex != -1) {
      String lastPart = goalValue.toString().substring(lastIndex + 1);
      L.p("lastPart$lastPart");
      if (lastPart.length > 2) {
        return false;
      }
    }
    return true;
  }

  String getDate() {
    String date;
    if (startDateTime == null || endDateTime == null) {
      return date;
    }
    if (startDateTime.compareTo(endDateTime) > 0) {
      return date;
    }
    if (dateType == DateTimeSelectType.BY_DAY.index) {
      startDate = DateUtil.getDateStrByDateTime(startDateTime,
          format: GMDateFormat.ZH_YEAR_MONTH_DAY);
      endDate = DateUtil.getDateStrByDateTime(endDateTime,
          format: GMDateFormat.ZH_YEAR_MONTH_DAY);
    } else if (dateType == DateTimeSelectType.BY_MONTH.index) {
      startDate = DateUtil.getDateStrByDateTime(startDateTime,
          format: GMDateFormat.ZH_YEAR_MONTH);
      endDate = DateUtil.getDateStrByDateTime(endDateTime,
          format: GMDateFormat.ZH_YEAR_MONTH);
    } else if (dateType == DateTimeSelectType.BY_YEAR.index) {
      startDate = DateUtil.getDateStrByDateTime(startDateTime,
          format: GMDateFormat.ZH_YEAR);
      endDate = DateUtil.getDateStrByDateTime(endDateTime,
          format: GMDateFormat.ZH_YEAR);
    } else {
      return date;
    }
    if (startDate.compareTo(endDate) == 0) {
      date = startDate;
    } else {
      date = getThird();
    }
    return date;
  }

  String getSecond() {
    if (indicator.isPercent) {
      return "${indicator.name}: ${(reachValue * 100).truncate()}%/${(goalValue * 100).truncate()}%";
    } else {
      return "${indicator.name}: ${reachValue.toStringAsFixed(3)}/${goalValue.toStringAsFixed(3)}";
    }
  }

  String getThird() {
    return "$startDate ~ $endDate";
  }

  String getStaffName() {
    if (staffs != null && staffs.length > 0) {
      return staffs[0].name;
    }
    return "";
  }

  double getPercent() {
    return (reachValue / goalValue * 100).truncate() / 100;
  }

  String getPercentWithSymbol() {
    return "${(reachValue / goalValue * 1000).truncate() / 10}%";
  }

  //List<SellTargetsEntity> 转List<GoalEntity>
  static getGoalEntity(List<SellTargetsEntity> sellTargetsList) {
    List<GoalEntity> goalList = List();
    for (var item in sellTargetsList) {
      GoalEntity goalEntity;
      if (item.selltargetdetails != null && item.selltargetdetails.length > 0) {
        for (var sellTargetDetails in item.selltargetdetails) {
          goalEntity = GoalEntity();
          goalEntity.reachValue = item.getReachValue();
          goalEntity.title = item.name;
          goalEntity.indicator = Indicator()
            ..isPercent = item.sellitem.isPercent()
            ..name = item.sellitem.name
            ..id = item.sellitem.id;
          goalEntity.goalValue = item.getGoalValue();
          goalEntity.startDateTime = DateTime.parse(item.startDate);
          goalEntity.endDateTime = DateTime.parse(item.endDate);
          if (item.dateType == "year") {
            goalEntity.dateType = DateTimeSelectType.BY_YEAR.index;
          } else if (item.dateType == "month") {
            goalEntity.dateType = DateTimeSelectType.BY_MONTH.index;
          } else {
            goalEntity.dateType = DateTimeSelectType.BY_DAY.index;
          }
          var staff = Staff();
          staff.id = sellTargetDetails.staff?.id;
          staff.name = sellTargetDetails.staff?.name;
          goalEntity.staffs = [staff];
          goalList.add(goalEntity);
        }
      }
    }
    return goalList;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "title:$title startDate:$startDate endDate:$endDate";
  }
}

class Staff {
  int id;
  String name;
  bool selected = false;
}

class Indicator {
  int id;
  String name;
  bool isPercent;
  bool selected;
  String status;
}

class IndicatorClass {
  int id;
  String name;
  List<Indicator> indicators;
}

@JsonSerializable()
class SellTargetsEntity {
  int id;
  String name;
  @JsonKey(name: "start_date")
  String startDate;
  @JsonKey(name: "end_date")
  String endDate;
  @JsonKey(name: "sellitem_id")
  String sellitemId;
  String value;
  @JsonKey(name: "actual_value")
  String actualValue;
  @JsonKey(name: "date_type")
  String dateType;
  @JsonKey(fromJson: _fromSellItemData)
  SellItemEntity sellitem;
  @JsonKey(fromJson: _fromSellTargetDetailsData)
  List<SellTargetDetailsEntity> selltargetdetails;

  SellTargetsEntity({
    this.sellitem,
    this.selltargetdetails,
  });

  static _fromSellItemData(json) {
    if (json != null) {
      return SellItemEntity.fromJson(json['data']);
    }
    return null;
  }

  static _fromSellTargetDetailsData(json) {
    if (json != null) {
      return (json['data'] as List)
          .map((item) => SellTargetDetailsEntity.fromJson(item))
          .toList();
    }
    return null;
  }

  factory SellTargetsEntity.fromJson(json) => _$SellTargetsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SellTargetsEntityToJson(this);

  double getGoalValue() {
    return double.parse(NumberFormatUtil.strToDouStrAsFixed2(value));
  }

  double getReachValue() {
    return double.parse(NumberFormatUtil.strToDouStrAsFixed2(actualValue));
  }

  String getStartDateTime() {
    var startDateTime = DateTime.parse(startDate);
    return DateUtil.getDateStrByDateTime(startDateTime,
        format: GMDateFormat.ZH_YEAR_MONTH_DAY);
  }

  String getEndDateTime() {
    var endDateTime = DateTime.parse(endDate);
    return DateUtil.getDateStrByDateTime(endDateTime,
        format: GMDateFormat.ZH_YEAR_MONTH_DAY);
  }
}

@JsonSerializable()
class SellTargetDetailsEntity {
  int id;

  String value;

  @JsonKey(fromJson: _fromStaffData)
  StaffEntity staff;

  SellTargetDetailsEntity() {}

  static _fromStaffData(json) {
    if (json != null) {
      return StaffEntity.fromJson(json['data']);
    }
    return null;
  }

  factory SellTargetDetailsEntity.fromJson(json) =>
      _$SellTargetDetailsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SellTargetDetailsEntityToJson(this);

  double getReachValue() {
    return double.parse(NumberFormatUtil.strToDouStrAsFixed2(value));
  }
}

@JsonSerializable()
class StaffEntity {
  int id;
  String name;
  StaffEntity() {}
  factory StaffEntity.fromJson(json) => _$StaffEntityFromJson(json);

  Map<String, dynamic> toJson() => _$StaffEntityToJson(this);
}
