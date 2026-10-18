import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Database? _cachedDb;

/// Opens the SQLite database with cross-platform support (Android, iOS, Web, Desktop).
Future<Database> openNotesDb({String dbName = 'clean_architecture_notes.db'}) async {
  if (_cachedDb != null && _cachedDb!.isOpen) {
    return _cachedDb!;
  }

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreateDb,
      ),
    );
    _cachedDb = db;
    return db;
  }

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final dir = await getDatabasesPath();
  final db = await openDatabase(
    p.join(dir, dbName),
    version: 1,
    onCreate: _onCreateDb,
  );
  _cachedDb = db;
  return db;
}

Future<void> _onCreateDb(Database db, int version) async {
  await db.execute('''
    CREATE TABLE notes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      body TEXT NOT NULL DEFAULT '',
      updated_at TEXT NOT NULL,
      dirty INTEGER NOT NULL DEFAULT 0
    )
  ''');
}

/// Closes cached database instance (useful for testing and reset).
Future<void> closeNotesDb() async {
  if (_cachedDb != null && _cachedDb!.isOpen) {
    await _cachedDb!.close();
    _cachedDb = null;
  }
}
