import 'package:_09_week_9_ai_assisted_development/features/notes/domain/entities/note.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/domain/entities/notes_query.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/domain/usecases/search_notes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const searchNotes = SearchNotes();
  final sampleNotes = [
    Note(
      id: 1,
      title: 'Belajar Flutter Riverpod',
      body: 'Memahami NotifierProvider v3 dan derivasi state.',
      updatedAt: DateTime(2026, 10, 22, 10, 0),
      dirty: true,
    ),
    Note(
      id: 2,
      title: 'Belanja Kebutuhan Lab',
      body: 'Kabel USB-C dan adaptor daya.',
      updatedAt: DateTime(2026, 10, 21, 9, 0),
      dirty: false,
    ),
    Note(
      id: 3,
      title: 'Agenda Clean Architecture',
      body: 'Pisahkan layer domain agar steril dari flutter.',
      updatedAt: DateTime(2026, 10, 23, 8, 0),
      dirty: false,
    ),
  ];

  group('SearchNotes Domain Use Case', () {
    test('ignores case and trims surrounding whitespace', () {
      final results = searchNotes(
        sampleNotes,
        const NotesQuery(query: '  FLUTTER  '),
      );

      expect(results.length, 2);
      expect(results.first.title, 'Agenda Clean Architecture');
    });

    test('returns empty list when no note matches query', () {
      final results = searchNotes(
        sampleNotes,
        const NotesQuery(query: 'zzz-tak-ada'),
      );

      expect(results, isEmpty);
    });

    test('filters by sync status dirtyOnly and syncedOnly', () {
      final dirty = searchNotes(
        sampleNotes,
        const NotesQuery(syncFilter: NoteSyncFilter.dirtyOnly),
      );
      expect(dirty.length, 1);
      expect(dirty.first.id, 1);

      final synced = searchNotes(
        sampleNotes,
        const NotesQuery(syncFilter: NoteSyncFilter.syncedOnly),
      );
      expect(synced.length, 2);
    });

    test('sorts alphabetically by title without mutating input list', () {
      final snapshotIds = sampleNotes.map((e) => e.id).toList();
      final sorted = searchNotes(
        sampleNotes,
        const NotesQuery(sortOrder: NoteSortOrder.titleAsc),
      );

      expect(sorted.map((e) => e.title).toList(), [
        'Agenda Clean Architecture',
        'Belajar Flutter Riverpod',
        'Belanja Kebutuhan Lab',
      ]);
      expect(sampleNotes.map((e) => e.id).toList(), snapshotIds);
    });
  });
}
