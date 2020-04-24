// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sell_group_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellGroupEntity _$SellGroupEntityFromJson(Map<String, dynamic> json) {
  return SellGroupEntity(
      id: json['id'] as int,
      name: json['name'] as String,
      sort: json['sort'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      sellItems: json['sellitems'] == null
          ? null
          : SellGroupEntity._getSellItems(json['sellitems']) ?? [])
    ..currentItem = json['currentItem'] == null
        ? null
        : SellItem.fromJson(json['currentItem'] as Map<String, dynamic>);
}

Map<String, dynamic> _$SellGroupEntityToJson(SellGroupEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sort': instance.sort,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'sellitems': instance.sellItems,
      'currentItem': instance.currentItem
    };

SellItem _$SellItemFromJson(Map<String, dynamic> json) {
  return SellItem(
      json['id'] as int,
      json['code'] as String,
      json['name'] as String,
      json['type'] as String,
      json['sellitemgroup_id'] as String,
      json['sort'] as String,
      json['status'] as String,
      json['remark'] as String,
      json['created_at'] as String,
      json['updated_at'] as String);
}

Map<String, dynamic> _$SellItemToJson(SellItem instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'type': instance.type,
      'sellitemgroup_id': instance.sellitemgroupId,
      'sort': instance.sort,
      'status': instance.status,
      'remark': instance.remark,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt
    };
