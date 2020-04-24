// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellTargetsEntity _$SellTargetsEntityFromJson(Map<String, dynamic> json) {
  return SellTargetsEntity(
      sellitem: json['sellitem'] == null
          ? null
          : SellTargetsEntity._fromSellItemData(json['sellitem']),
      selltargetdetails: json['selltargetdetails'] == null
          ? null
          : SellTargetsEntity._fromSellTargetDetailsData(
              json['selltargetdetails']))
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..startDate = json['start_date'] as String
    ..endDate = json['end_date'] as String
    ..sellitemId = json['sellitem_id'] as String
    ..value = json['value'] as String
    ..actualValue = json['actual_value'] as String
    ..dateType = json['date_type'] as String;
}

Map<String, dynamic> _$SellTargetsEntityToJson(SellTargetsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'sellitem_id': instance.sellitemId,
      'value': instance.value,
      'date_type': instance.dateType,
      'sellitem': instance.sellitem,
      'selltargetdetails': instance.selltargetdetails
    };

SellTargetDetailsEntity _$SellTargetDetailsEntityFromJson(
    Map<String, dynamic> json) {
  return SellTargetDetailsEntity()
    ..id = json['id'] as int
    ..value = json['value'] as String
    ..staff = json['staff'] == null
        ? null
        : SellTargetDetailsEntity._fromStaffData(json['staff']);
}

Map<String, dynamic> _$SellTargetDetailsEntityToJson(
        SellTargetDetailsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'staff': instance.staff
    };

StaffEntity _$StaffEntityFromJson(Map<String, dynamic> json) {
  return StaffEntity()
    ..id = json['id'] as int
    ..name = json['name'] as String;
}

Map<String, dynamic> _$StaffEntityToJson(StaffEntity instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
