import 'package:json_annotation/json_annotation.dart';

part 'sell_group_entity.g.dart';

@JsonSerializable()
class SellGroupEntity extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'sort')
  String sort;

  @JsonKey(name: 'status')
  String status;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(
      name: 'sellitems', fromJson: _getSellItems, defaultValue: <SellItem>[])
  List<SellItem> sellItems;

  ///选中的item
  SellItem currentItem;

  static _getSellItems(json) {
    return ((json['data'] as List).map((elment) {
      return SellItem.fromJson(elment);
    }).toList());
  }

  SellGroupEntity(
      {this.id,
      this.name,
      this.sort,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.sellItems = const <SellItem>[]});

  factory SellGroupEntity.fromJson(Map<String, dynamic> srcJson) =>
      _$SellGroupEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SellGroupEntityToJson(this);
}

@JsonSerializable()
class SellItem extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'code')
  String code;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'sellitemgroup_id')
  String sellitemgroupId;

  @JsonKey(name: 'sort')
  String sort;

  @JsonKey(name: 'status')
  String status;

  @JsonKey(name: 'remark')
  String remark;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  SellItem(
    this.id,
    this.code,
    this.name,
    this.type,
    this.sellitemgroupId,
    this.sort,
    this.status,
    this.remark,
    this.createdAt,
    this.updatedAt,
  );

  factory SellItem.fromJson(Map<String, dynamic> srcJson) =>
      _$SellItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SellItemToJson(this);
}
