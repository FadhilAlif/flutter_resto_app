import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initializeDatabase() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI for Windows and Linux
    sqfliteFfiInit();
    // Change the default factory for these platforms
    databaseFactory = databaseFactoryFfi;
  }
}

Future<Database> openAppDatabase() async {
  final dbPath = await getDatabasePath();
  final path = join(dbPath, 'restaurant.db');

  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorites (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          pictureId TEXT NOT NULL,
          city TEXT NOT NULL,
          rating REAL NOT NULL
        )
      ''');
    },
  );
}

Future<String> getDatabasePath() async {
  if (Platform.isWindows || Platform.isLinux) {
    // For desktop platforms, store in app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    return appDir.path;
  } else {
    // For mobile platforms, use the default database location
    return await getDatabasesPath();
  }
}
