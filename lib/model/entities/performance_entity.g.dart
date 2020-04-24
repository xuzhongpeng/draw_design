// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PerformanceEntity _$PerformanceEntityFromJson(Map<String, dynamic> json) {
  return PerformanceEntity()
    ..id = json['id'] as int
    ..ownerableId = json['ownerable_id'] as String
    ..ownerableType = json['ownerable_type'] as String
    ..ownerableName = json['owner_name'] as String
    ..sellitemId = int.parse((json['sellitem_id'] ?? '0').toString())
    ..sellitemCode = json['sellitem_code'] as String
    ..sellitemName = json['sellitem_name'] as String
    ..sellitemGroupId = json['sellitemgroup_id'] as String
    ..sellitemGroupCode = json['sellitemgroup_code'] as String
    ..sellitemGroupName = json['sellitemgroup_name'] as String
    ..value = json['value'] == null
        ? null
        : PerformanceEntity._valueFromJson(json['value'])
    ..transactionDate = json['transaction_date'] as String
    ..transactionYear = json['transaction_year'] as String
    ..transactionMonth = json['transaction_month'] as String
    ..transactionDay = json['transaction_day'] as String
    ..transactionWeek = json['transaction_week'] as String
    ..timestamp = json['transaction_time'] as int;
}

Map<String, dynamic> _$PerformanceEntityToJson(PerformanceEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerable_id': instance.ownerableId,
      'ownerable_type': instance.ownerableType,
      'owner_name': instance.ownerableName,
      'sellitem_id': instance.sellitemId,
      'sellitem_code': instance.sellitemCode,
      'sellitem_name': instance.sellitemName,
      'sellitemgroup_id': instance.sellitemGroupId,
      'sellitemgroup_code': instance.sellitemGroupCode,
      'sellitemgroup_name': instance.sellitemGroupName,
      'value': instance.value,
      'transaction_date': instance.transactionDate,
      'transaction_year': instance.transactionYear,
      'transaction_month': instance.transactionMonth,
      'transaction_day': instance.transactionDay,
      'transaction_week': instance.transactionWeek,
      'transaction_time': instance.timestamp
    };
