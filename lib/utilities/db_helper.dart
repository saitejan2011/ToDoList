import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ToDoList/models/to_do_model.dart';

class DatabaseHelper {
  String tableName = "to_do_list_table";
  String id = "id";
  String title = "title";
  String description = "description";
  String status = "status";
  String date = "date";

  static DatabaseHelper _databaseHelper;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Database _database;

  get database async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return _database;
  }

  Future<Database> initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "my_to_do_list.db";
    return openDatabase(path, version: 1, onCreate: createDatabase);
  }

  createDatabase(Database database, int version) async {
    String query = "CREATE TABLE $tableName"
        "("
        "$id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$title TEXT,"
        "$description TEXT,"
        "$status TEXT,"
        "$date TEXT"
        ")";
    return await database.execute(query);
  }

  Future<List<Map<String, dynamic>>> getMapDataFromDB() async {
    Database database = await this.database;
    return database.query(tableName,
        columns: ["id", "title", "description", "status", "date"]);
  }

  Future<List<ToDo>> getDataModelsFromMapList() async {
    List<Map<String, dynamic>> mapList = await getMapDataFromDB();
    List<ToDo> todoList = new List<ToDo>();
    for (var mapItem in mapList) {
      todoList.add(ToDo.fromMap(mapItem));
    }
    return todoList;
  }

  Future<int> insertItemInDB(ToDo toDoObj) async {
    Database database = await this.database;
    var results = database.insert(tableName, toDoObj.toMap());
    print("Data inserted");
    return results;
  }

  Future<int> udpateItemInDB(ToDo toDoObj) async {
    Database database = await this.database;
    return database.update(tableName, toDoObj.toMap(),
        where: "$id=?", whereArgs: [toDoObj.id]);
  }

  Future<int> deleteItemFromDB(ToDo toDoObj) async {
    Database database = await this.database;
    return database
        .delete(tableName, where: "$id= ? ", whereArgs: [toDoObj.id]);
  }
}
