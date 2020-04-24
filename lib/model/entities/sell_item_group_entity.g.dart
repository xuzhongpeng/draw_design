// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sell_item_group_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellItemGroupEntity _$SellItemGroupEntityFromJson(Map<String, dynamic> json) {
  return SellItemGroupEntity(json['sellitems'] == null
      ? null
      : SellItemGroupEntity._fromSellItem(json['sellitems']))
    ..id = json['id'] as int
    ..name = json['name'] as String;
}

Map<String, dynamic> _$SellItemGroupEntityToJson(
        SellItemGroupEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sellitems': instance.sellitems
    };

SellItemEntity _$SellItemEntityFromJson(Map<String, dynamic> json) {
  return SellItemEntity()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..type = json['type'] as String
    ..sellitemgroupId = json['sellitemgroup_id']
    ..remark = json['remark'] as String
    ..status = json['status'] as String;
}

Map<String, dynamic> _$SellItemEntityToJson(SellItemEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'sellitemgroup_id': instance.sellitemgroupId,
      'remark': instance.remark,
      'status': instance.status
    };
