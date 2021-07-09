import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:to_do_list/Business.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE Business ("
              "id INTEGER PRIMARY KEY,"
              "text TEXT,"
              "blocked BIT"
              ")");
        });
  }

  newBusiness(Business newBusiness) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Business");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Business (id,text,blocked)"
            " VALUES (?,?,?)",
        [id, newBusiness.text, newBusiness.blocked]);
    return raw;
  }

  blockOrUnblock(Business newBusiness) async {
    final db = await database;
    Business blocked = Business(
        id: newBusiness.id,
        text: newBusiness.text,
        blocked: !newBusiness.blocked);
    var res = await db.update("Business", blocked.toMap(),
        where: "id = ?", whereArgs: [newBusiness.id]);
    return res;
  }

  updateBusiness(Business newBusiness) async {
    final db = await database;
    var res = await db.update("Business", newBusiness.toMap(),
        where: "id = ?", whereArgs: [newBusiness.id]);
    return res;
  }

  getBusiness(int id) async {
    final db = await database;
    var res = await db.query("Business", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Business.fromMap(res.first) : null;
  }

  Future<List<Business>> getBlockedBusiness() async {
    final db = await database;

    print("works");
    // var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    var res = await db.query("Business", where: "blocked = ? ", whereArgs: [1]);

    List<Business> list =
    res.isNotEmpty ? res.map((c) => Business.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Business>> getAllBusiness() async {
    final db = await database;
    var res = await db.query("Business");
    List<Business> list =
    res.isNotEmpty ? res.map((c) => Business.fromMap(c)).toList() : [];
    return list;
  }

  deleteBusiness(int id) async {
    final db = await database;
    return db.delete("Business", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Business");
  }
}
