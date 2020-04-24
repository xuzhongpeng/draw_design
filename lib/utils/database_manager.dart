import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:staff_performance/utils/database_model.dart';

class GMDataBaseManager<T extends GMDataBaseModel> {
  Database _db;
  String _tableName;

  ///打开一张表 没有就创建一个新的
  Future<void> openDataBase(String path, String tableName, String sql) async {
    _tableName = tableName;
    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''create table $tableName ($sql)''');
    });
    var res = await queryModelsWithSQL(
        sql:
            "SELECT COUNT(*) as CNT FROM sqlite_master WHERE type = 'table' AND name = ?",
        arguments: [tableName]);
    if (res.first.values.first == 0) {
      await queryModelsWithSQL(sql: 'create table $tableName ($sql)');
    }
    print('---db=$_db');
  }

  ///插入
  Future<void> insert(T model) async {
    await _db.insert(
      _tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///批量插入
  Future<void> bathInsert(List<T> models) async {
    print('---bathInsert');
    Batch batch = _db.batch();
    for (var model in models) {
      batch.insert(
        _tableName,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  ///批量执行某个操作
  Future<void> bath(Function opretion) async {
    Batch batch = _db.batch();
    opretion();
    await batch.commit();
    await _db.close();
  }

  ///封装查询
  Future<List<Map>> queryModels(
      {bool distinct,
      List<String> columns,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {
    final List<Map<String, dynamic>> maps = await _db.query(_tableName,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
    return maps;
  }

  ///原生SQL查询
  Future<List<Map>> queryModelsWithSQL(
      {@required String sql, List<dynamic> arguments}) async {
    List<Map<String, dynamic>> maps;
    try {
      maps = await _db.rawQuery(sql, arguments);
    } catch (e) {
      return [];
    }
    return maps;
  }

  ///改
  Future<void> updateDatabase(T model, String where, List whereArgs) async {
    await _db.update(
      _tableName,
      model.toMap(),
      where: where,
      whereArgs: whereArgs,
    );
  }

  ///删
  Future<void> deleteModel(String where, List whereArgs) async {
    if (_db != null && _tableName != null) {
      await _db.delete(
        _tableName,
        where: where,
        whereArgs: whereArgs,
      );
    }
  }

  ///删表
  Future<void> deleteTable() async {
    if (_db != null && _tableName != null) {
      await _db.delete(
        _tableName,
      );
    }
  }

  ///关闭
  Future<void> close() async {
    if (_db != null && _tableName != null) {
      await _db.close();
    }
  }
}
