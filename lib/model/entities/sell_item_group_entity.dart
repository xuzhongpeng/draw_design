import 'package:json_annotation/json_annotation.dart';
part 'sell_item_group_entity.g.dart';

@JsonSerializable()
class SellItemGroupEntity{
  int id;
  String name;
  @JsonKey(fromJson: _fromSellItem)
  List<SellItemEntity> sellitems;

  SellItemGroupEntity(this.sellitems){}
  static _fromSellItem(json){
    if (json != null) {
      return (json['data'] as List).map((item) => SellItemEntity.fromJson(item)).toList();
    }
    return null;
  }
  factory SellItemGroupEntity.fromJson(json) => _$SellItemGroupEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SellItemGroupEntityToJson(this);
}

@JsonSerializable()
class SellItemEntity{
  int id;
  String name;
  String type;
  @JsonKey(name: "sellitemgroup_id")
  var sellitemgroupId;
  String remark;
  String status;
  SellItemEntity(){}
  factory SellItemEntity.fromJson(json) => _$SellItemEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SellItemEntityToJson(this);

  @override
  String toString() {
    // TODO: implement toString
    return "id:$id name:$name status:$status";
  }

  isPercent() => type == "percent";
}