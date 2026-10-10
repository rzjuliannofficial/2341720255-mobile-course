import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Database? _cachedDb;

Future<Database> openNotesDb() async {
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
    p.join(dir, 'offline_notes.db'),
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
  await db.execute('''
    CREATE TABLE cached_posts(
      id INTEGER PRIMARY KEY,
      title TEXT NOT NULL DEFAULT '',
      body TEXT NOT NULL DEFAULT '',
      payload TEXT NOT NULL,
      cached_at TEXT NOT NULL
    )
  ''');

  // Data awal untuk demonstrasi offline-first
  await db.insert('notes', {
    'title': 'Rencana Belajar Offline-First',
    'body': 'Mempelajari SQLite, Dirty Flag, dan SharedPreferences.',
    'updated_at': DateTime.now().toIso8601String(),
    'dirty': 1,
  });
  await db.insert('notes', {
    'title': 'Catatan Rapat Sinkronisasi',
    'body': 'Pastikan conflict resolution menggunakan aturan Last-Write-Wins.',
    'updated_at':
        DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
    'dirty': 1,
  });
  await db.insert('cached_posts', {
    'id': 1,
    'title': 'sunt aut facere repellat provident occaecati excepturi optio',
    'body': 'quia et suscipit suscipit recusandae consequuntur expedita et cum',
    'payload':
        '{"id":1,"title":"sunt aut facere repellat provident occaecati excepturi optio","body":"quia et suscipit suscipit recusandae consequuntur expedita et cum"}',
    'cached_at': DateTime.now().toIso8601String(),
  });
  await db.insert('cached_posts', {
    'id': 2,
    'title': 'qui est esse',
    'body':
        'est rerum tempore vitae sequi sint nihil reprehenderit dolor beatae ea',
    'payload':
        '{"id":2,"title":"qui est esse","body":"est rerum tempore vitae sequi sint nihil reprehenderit dolor beatae ea"}',
    'cached_at': DateTime.now().toIso8601String(),
  });
}