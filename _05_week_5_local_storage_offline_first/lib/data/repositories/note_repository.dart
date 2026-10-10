import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) => NoteRepository());

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notesProvider);
  return ref.watch(noteRepositoryProvider).countDirty();
});

class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  // In-memory store untuk lingkungan Web jika WebAssembly WASM MIME tidak didukung server dev
  static final List<Note> _webNotes = [
    Note(
      id: 1,
      title: 'Rencana Belajar Offline-First',
      body: 'Mempelajari SQLite, Dirty Flag, dan SharedPreferences.',
      updatedAt: DateTime.now(),
      dirty: true,
    ),
    Note(
      id: 2,
      title: 'Catatan Rapat Sinkronisasi',
      body: 'Pastikan conflict resolution menggunakan aturan Last-Write-Wins.',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      dirty: true,
    ),
  ];
  static int _nextWebId = 3;

  Future<List<Note>> fetchNotes() async {
    if (kIsWeb) {
      final list = List<Note>.from(_webNotes);
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    }
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> getNoteById(int id) async {
    if (kIsWeb) {
      final matches = _webNotes.where((n) => n.id == id);
      return matches.isNotEmpty ? matches.first : null;
    }
    final db = await _openDb();
    final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );

    if (kIsWeb) {
      final created = note.copyWith(id: _nextWebId++);
      _webNotes.add(created);
      return created;
    }

    final db = await _openDb();
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  Future<void> updateNote(Note note) async {
    final updated = note.copyWith(
      updatedAt: DateTime.now(),
      dirty: true,
    );

    if (kIsWeb) {
      final index = _webNotes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _webNotes[index] = updated;
      }
      return;
    }

    final db = await _openDb();
    await db.update(
      'notes',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    if (kIsWeb) {
      _webNotes.removeWhere((n) => n.id == id);
      return;
    }

    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countDirty() async {
    if (kIsWeb) {
      return _webNotes.where((n) => n.dirty).length;
    }

    final db = await _openDb();
    final rows = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  Future<void> markAllSynced() async {
    if (kIsWeb) {
      for (int i = 0; i < _webNotes.length; i++) {
        if (_webNotes[i].dirty) {
          _webNotes[i] = _webNotes[i].copyWith(dirty: false);
        }
      }
      return;
    }

    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }

  Future<void> markNoteSynced(int id) async {
    if (kIsWeb) {
      final index = _webNotes.indexWhere((n) => n.id == id);
      if (index != -1) {
        _webNotes[index] = _webNotes[index].copyWith(dirty: false);
      }
      return;
    }

    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'id = ?', whereArgs: [id]);
  }
}

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() {
    return ref.watch(noteRepositoryProvider).fetchNotes();
  }

  Future<void> addNote({required String title, String body = ''}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
      return ref.read(noteRepositoryProvider).fetchNotes();
    });
  }

  Future<void> updateNote(Note note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).updateNote(note);
      return ref.read(noteRepositoryProvider).fetchNotes();
    });
  }

  Future<void> deleteNote(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).deleteNote(id);
      return ref.read(noteRepositoryProvider).fetchNotes();
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(noteRepositoryProvider).fetchNotes();
    });
  }
}