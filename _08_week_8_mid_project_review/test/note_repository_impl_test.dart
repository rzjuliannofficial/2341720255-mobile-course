import 'package:_08_week_8_mid_project_review/core/clock.dart';
import 'package:_08_week_8_mid_project_review/core/failures.dart';
import 'package:_08_week_8_mid_project_review/features/notes/data/datasources/database_helper.dart';
import 'package:_08_week_8_mid_project_review/features/notes/data/repositories/note_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test(
    'NoteRepositoryImpl persists, reads, and deletes via in-memory SQLite',
    () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1, onCreate: createNotesSchema),
      );
      addTearDown(db.close);

      final fixedTime = DateTime(2026, 10, 20, 14, 30);
      final repo = NoteRepositoryImpl(
        openDb: () async => db,
        clock: FixedClock(fixedTime),
      );

      final added = await repo.addNote(
        title: 'Audit SQLite',
        body: 'Verifikasi clock terinjeksi',
      );
      expect(added.failure, isNull);
      expect(added.note?.updatedAt, fixedTime);
      expect(added.note?.dirty, isTrue);

      final fetched = await repo.fetchNotes();
      expect(fetched.notes.length, 1);
      expect(fetched.notes.first.title, 'Audit SQLite');

      final deleted = await repo.deleteNote(added.note!.id!);
      expect(deleted.success, isTrue);

      final missingDelete = await repo.deleteNote(999);
      expect(missingDelete.success, isFalse);
      expect(missingDelete.failure, isA<LocalFailure>());
    },
  );
}
