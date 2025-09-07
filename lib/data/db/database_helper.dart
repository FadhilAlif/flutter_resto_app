import 'package:flutter_resto_app/data/models/restaurant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal() {
    _instance = this;
  }

  factory DatabaseHelper() => _instance ?? DatabaseHelper._internal();

  static const String _tblFavorite = 'favorites';

  Future<Database> _initializeDb() async {
    var path = await getDatabasesPath();
    var db = openDatabase(
      join(path, 'restaurant_db.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE $_tblFavorite (
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          pictureId TEXT,
          city TEXT,
          rating REAL
        )''');
      },
      version: 1,
    );

    return db;
  }

  Future<Database?> get database async {
    _database ??= await _initializeDb();
    return _database;
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await database;
    await db?.insert(
      _tblFavorite,
      restaurant.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db?.query(_tblFavorite) ?? [];
    return results.map((res) => Restaurant.fromJson(res)).toList();
  }

  Future<Restaurant?> getFavoriteById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> results =
        await db?.query(_tblFavorite, where: 'id = ?', whereArgs: [id]) ?? [];

    if (results.isNotEmpty) {
      return Restaurant.fromJson(results.first);
    }
    return null;
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db?.delete(_tblFavorite, where: 'id = ?', whereArgs: [id]);
  }
}
