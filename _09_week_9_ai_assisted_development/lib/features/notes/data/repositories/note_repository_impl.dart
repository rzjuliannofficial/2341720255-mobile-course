import 'package:sqflite/sqflite.dart';

import '../../../../core/clock.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

/// SQLite implementation of [NoteRepository] with injected database opener and clock.
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({required this.openDb, this.clock = const SystemClock()});

  final Future<Database> Function() openDb;
  final AppClock clock;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes = rows.map((r) => NoteModel.fromMap(r).toEntity()).toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await openDb();
      final now = clock.now();
      final id = await db.insert(
        'notes',
        NoteModel(
          title: title,
          body: body,
          updatedAt: now,
          dirty: true,
        ).toMap(),
      );
      return (
        note: Note(
          id: id,
          title: title,
          body: body,
          updatedAt: now,
          dirty: true,
        ),
        failure: null,
      );
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal menyimpan catatan: $e'));
    }
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    try {
      final db = await openDb();
      final count = await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      if (count == 0) {
        return (
          success: false,
          failure: const LocalFailure('Catatan tidak ditemukan.'),
        );
      }
      return (success: true, failure: null);
    } catch (e) {
      return (
        success: false,
        failure: LocalFailure('Gagal menghapus catatan: $e'),
      );
    }
  }
}
