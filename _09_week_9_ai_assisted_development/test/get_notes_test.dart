import 'package:_09_week_9_ai_assisted_development/core/failures.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/domain/entities/note.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/domain/repositories/note_repository.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/domain/usecases/add_note.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/domain/usecases/delete_note.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/domain/usecases/get_notes.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  List<Note> items;
  final bool fail;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    if (fail) {
      return (
        note: null,
        failure: const LocalFailure('Gagal simpan (simulasi)'),
      );
    }
    final newNote = Note(
      id: items.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 10, 20),
      dirty: true,
    );
    items = [...items, newNote];
    return (note: newNote, failure: null);
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    if (fail) {
      return (
        success: false,
        failure: const LocalFailure('Gagal hapus (simulasi)'),
      );
    }
    items = items.where((n) => n.id != id).toList();
    return (success: true, failure: null);
  }
}

void main() {
  group('GetNotes Use Case', () {
    test('returns notes list from repository', () async {
      final repo = FakeNoteRepository(
        items: [
          Note(id: 1, title: 'Catatan A', updatedAt: DateTime(2026, 10, 19)),
          Note(id: 2, title: 'Catatan B', updatedAt: DateTime(2026, 10, 20)),
        ],
      );
      final result = await GetNotes(repo).call();

      expect(result.failure, isNull);
      expect(result.notes.length, 2);
    });

    test('propagates LocalFailure without throwing', () async {
      final repo = FakeNoteRepository(fail: true);
      final result = await GetNotes(repo).call();

      expect(result.failure, isA<LocalFailure>());
      expect(result.notes, isEmpty);
    });
  });

  group('AddNote Use Case', () {
    test('rejects blank title with ValidationFailure', () async {
      final repo = FakeNoteRepository();
      final result = await AddNote(repo).call(title: '   ');

      expect(result.note, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(repo.items, isEmpty);
    });

    test('accepts 100-char title and rejects 101-char title', () async {
      final repo = FakeNoteRepository();
      final exact = await AddNote(repo).call(title: 'a' * 100);
      expect(exact.failure, isNull);

      final tooLong = await AddNote(repo).call(title: 'a' * 101);
      expect(tooLong.failure, isA<ValidationFailure>());
    });
  });

  group('DeleteNote Use Case', () {
    test('rejects non-positive ID', () async {
      final repo = FakeNoteRepository();
      final result = await DeleteNote(repo).call(0);

      expect(result.success, isFalse);
      expect(result.failure, isA<ValidationFailure>());
    });

    test('deletes existing note by ID', () async {
      final repo = FakeNoteRepository(
        items: [Note(id: 1, title: 'Hapus', updatedAt: DateTime(2026, 10, 20))],
      );
      final result = await DeleteNote(repo).call(1);

      expect(result.success, isTrue);
      expect(repo.items, isEmpty);
    });
  });
}
