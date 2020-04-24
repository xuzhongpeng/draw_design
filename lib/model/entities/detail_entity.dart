import 'package:json_annotation/json_annotation.dart';

import '../database_model.dart';

@JsonSerializable()
class DetailEntity extends GMDataBaseModel {
  int id;

  @JsonKey(name: 'ownerable_id', nullable: false)
  String ownerableId;

  @override
  Map toMap() {
    return null;
  }
}
