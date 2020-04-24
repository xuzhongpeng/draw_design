import 'package:json_annotation/json_annotation.dart';

import 'package:staff_performance/utils/database_model.dart';

part 'performance_entity.g.dart';

@JsonSerializable()
class PerformanceEntity extends GMDataBaseModel {
  int id;

  @JsonKey(name: 'ownerable_id', nullable: false)
  String ownerableId;

  ///员工/店铺
  @JsonKey(name: 'ownerable_type')
  String ownerableType;

  @JsonKey(name: 'owner_name')
  String ownerableName;

  @JsonKey(name: 'sellitem_id')
  int sellitemId;

  @JsonKey(name: 'sellitem_code')
  String sellitemCode;

  @JsonKey(name: 'sellitem_name')
  String sellitemName;

  @JsonKey(name: 'sellitemgroup_id')
  String sellitemGroupId;

  @JsonKey(name: 'sellitemgroup_code')
  String sellitemGroupCode;

  @JsonKey(name: 'sellitemgroup_name')
  String sellitemGroupName;

  @JsonKey(fromJson: _valueFromJson, defaultValue: '0')
  String value;

  static _valueFromJson(json) {
    return json.toString();
  }

  @JsonKey(name: 'transaction_date')
  String transactionDate;

  @JsonKey(name: 'transaction_year')
  String transactionYear;

  @JsonKey(name: 'transaction_month')
  String transactionMonth;

  @JsonKey(name: 'transaction_day')
  String transactionDay;

  @JsonKey(name: 'transaction_week')
  String transactionWeek;

  @JsonKey(name: 'transaction_time')
  int timestamp;

  @override
  Map toMap() {
    return this.toJson();
  }

  PerformanceEntity();
  factory PerformanceEntity.fromJson(json) => _$PerformanceEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceEntityToJson(this);
}
