import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:_05_week_5_local_storage_offline_first/data/local/note.dart';
import 'package:_05_week_5_local_storage_offline_first/data/repositories/note_repository.dart';
import 'package:_05_week_5_local_storage_offline_first/data/sync.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({List<Note>? items, this.throwError = false})
      : items = items ?? [],
        super(openDb: () => throw UnimplementedError());

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulasi)');
    return items;
  }

  @override
  Future<Note?> getNoteById(int id) async {
    if (throwError) throw Exception('db locked (simulasi)');
    final matches = items.where((n) => n.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<int> countDirty() =>
      Future.value(items.where((n) => n.dirty).length);

  @override
  Future<void> markAllSynced() async {
    for (int i = 0; i < items.length; i++) {
      if (items[i].dirty) {
        items[i] = items[i].copyWith(dirty: false);
      }
    }
  }
}

void main() {
  group('Model Note Unit Tests', () {
    test('fromMap aman terhadap field yang hilang', () {
      final note = Note.fromMap({'title': 'Belanja'});
      expect(note.title, 'Belanja');
      expect(note.body, '');
      expect(note.dirty, isFalse);
    });

    test('flag dirty bertahan pada serialisasi', () {
      final note = Note(
        title: 'a',
        updatedAt: DateTime(2026, 9, 18),
        dirty: true,
      );
      final restored = Note.fromMap(note.toMap());
      expect(restored.dirty, isTrue);
      expect(restored.title, 'a');
    });

    test('copyWith memperbarui field dengan benar', () {
      final note = Note(
        id: 1,
        title: 'Judul Asli',
        body: 'Isi Asli',
        updatedAt: DateTime(2026, 9, 18),
        dirty: true,
      );
      final updated = note.copyWith(title: 'Judul Baru', dirty: false);
      expect(updated.id, 1);
      expect(updated.title, 'Judul Baru');
      expect(updated.body, 'Isi Asli');
      expect(updated.dirty, isFalse);
    });
  });

  group('Provider dengan FakeNoteRepository Tests', () {
    test('provider sukses dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(items: [
              Note(id: 1, title: 'Tes', updatedAt: DateTime.now()),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notes = await container.read(notesProvider.future);
      expect(notes.length, 1);
      expect(notes.first.title, 'Tes');
    });

    test('provider error dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final completer = Completer<Object?>();
      final sub = container.listen<AsyncValue<List<Note>>>(
        notesProvider,
        (previous, next) {
          if (next.hasError && !completer.isCompleted) {
            completer.complete(next.error);
          }
        },
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final error = await completer.future;
      expect(error, isA<Exception>());
      expect(error.toString(), contains('db locked'));
    });

    test('syncNotes berhasil membersihkan catatan berstatus dirty', () async {
      final fakeRepo = FakeNoteRepository(
        items: [
          Note(
            id: 1,
            title: 'Catatan Kotor 1',
            updatedAt: DateTime.now(),
            dirty: true,
          ),
          Note(
            id: 2,
            title: 'Catatan Kotor 2',
            updatedAt: DateTime.now(),
            dirty: true,
          ),
          Note(
            id: 3,
            title: 'Catatan Bersih',
            updatedAt: DateTime.now(),
            dirty: false,
          ),
        ],
      );

      final dirtyBefore = await fakeRepo.countDirty();
      expect(dirtyBefore, 2);

      final syncedCount = await syncNotes(fakeRepo);
      expect(syncedCount, 2);

      final dirtyAfter = await fakeRepo.countDirty();
      expect(dirtyAfter, 0);
    });
  });
}
