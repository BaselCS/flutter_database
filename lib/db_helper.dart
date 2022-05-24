import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//TODO:The DataBaseName:
const String _dataBaseName = 'model';
//TODO:Add columns You want:
const String _tableName = 'models';
const String columnIdName = 'id';
const String columnTitleName = 'title';
const String columnDescriptionName = 'description';

int _idOfDataBase = 0;
//########################################################## Models ##############################################################

class Model {
  //TODO: add variables To fill the columns
  int id;
  String title;
  String description;

  //TODO: initialize variable
  Model({
    required this.id,
    required this.title,
    required this.description,
  });

  //TODO: Give the columns the values
  Map<String, dynamic> toMap() {
    return {
      columnIdName: id,
      columnTitleName: title,
      columnDescriptionName: description,
    };
  }

  //TODO: Fill the values from columns
  Model.fromMap(Map<String, dynamic> res)
      : id = res[columnIdName],
        title = res[columnTitleName],
        description = res[columnDescriptionName];

  @override
  String toString() {
    return '$_tableName{$columnIdName: $id, $columnTitleName: $title, $columnDescriptionName: $description}';
  }

  static List<T> modelBuilder<M, T>(List<M> models, T Function(int index, M model) builder) =>
      models.asMap().map<int, T>((index, model) => MapEntry(index, builder(index, model))).values.toList();
}

//######################################################### DataBase #############################################################
const String idQuery = 'INTEGER PRIMARY KEY';
const String stringQuery = 'text not null';
// const String intQuery = 'integer not null';

class DatabaseHandler {
  Future<Database> openDB([String filepath = _dataBaseName]) async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, '${filepath}database.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE $_tableName(id $idQuery, title $stringQuery, description $stringQuery)',
        );
      },
      version: 1,
    );
  }

  Future<void> addToDB(Model model) async {
    final db = await openDB();
    _idOfDataBase += 1;
    model.id = _idOfDataBase;
    await db.insert(
      _tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Model>> showDB() async {
    final db = await openDB();
    final List<Map<String, dynamic>> queryResult = await db.query(_tableName, orderBy: columnIdName);
    return queryResult.map((e) => Model.fromMap(e)).toList();
  }

  Future<int> update(Model model) async {
    final db = await openDB();
    return await db.update(_tableName, model.toMap(), where: '$columnIdName = ?', whereArgs: [model.id]);
  }

  Future<void> deleteModel(int id) async {
    final db = await openDB();
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await openDB();
    db.close();
  }
}
