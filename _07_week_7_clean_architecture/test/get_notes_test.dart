import 'package:flutter_test/flutter_test.dart';
import 'package:_07_week_7_clean_architecture/core/failures.dart';
import 'package:_07_week_7_clean_architecture/features/notes/domain/entities/note.dart';
import 'package:_07_week_7_clean_architecture/features/notes/domain/repositories/note_repository.dart';
import 'package:_07_week_7_clean_architecture/features/notes/domain/usecases/add_note.dart';
import 'package:_07_week_7_clean_architecture/features/notes/domain/usecases/delete_note.dart';
import 'package:_07_week_7_clean_architecture/features/notes/domain/usecases/get_notes.dart';

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
      updatedAt: DateTime(2026, 10, 18),
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
    test('GetNotes meneruskan daftar dari repository', () async {
      final repo = FakeNoteRepository(items: [
        Note(id: 1, title: 'Catatan A', updatedAt: DateTime(2026, 9, 27)),
        Note(id: 2, title: 'Catatan B', updatedAt: DateTime(2026, 9, 28)),
      ]);
      final result = await GetNotes(repo).call();

      expect(result.failure, isNull);
      expect(result.notes.length, 2);
      expect(result.notes.first.title, 'Catatan A');
    });

    test('GetNotes meneruskan failure tanpa melempar exception', () async {
      final repo = FakeNoteRepository(fail: true);
      final result = await GetNotes(repo).call();

      expect(result.failure, isA<LocalFailure>());
      expect(result.failure?.message, contains('db locked'));
      expect(result.notes, isEmpty);
    });
  });

  group('AddNote Use Case', () {
    test('AddNote menolak judul kosong dengan ValidationFailure', () async {
      final repo = FakeNoteRepository();
      final result = await AddNote(repo).call(title: '   ');

      expect(result.note, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('tidak boleh kosong'));
      expect(repo.items, isEmpty);
    });

    test('AddNote menolak judul lebih dari 100 karakter', () async {
      final repo = FakeNoteRepository();
      final longTitle = 'a' * 105;
      final result = await AddNote(repo).call(title: longTitle);

      expect(result.note, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('maksimal 100 karakter'));
    });

    test('AddNote berhasil menyimpan catatan valid', () async {
      final repo = FakeNoteRepository();
      final result = await AddNote(repo).call(
        title: 'Review Clean Architecture',
        body: 'Memastikan dependensi ke arah dalam',
      );

      expect(result.failure, isNull);
      expect(result.note, isNotNull);
      expect(result.note?.title, 'Review Clean Architecture');
      expect(repo.items.length, 1);
    });
  });

  group('DeleteNote Use Case', () {
    test('DeleteNote menolak ID tidak valid (<= 0)', () async {
      final repo = FakeNoteRepository();
      final result = await DeleteNote(repo).call(0);

      expect(result.success, isFalse);
      expect(result.failure, isA<ValidationFailure>());
    });

    test('DeleteNote berhasil menghapus item dengan ID valid', () async {
      final note = Note(id: 1, title: 'Catatan Hapus', updatedAt: DateTime.now());
      final repo = FakeNoteRepository(items: [note]);
      final result = await DeleteNote(repo).call(1);

      expect(result.success, isTrue);
      expect(repo.items, isEmpty);
    });
  });
}
