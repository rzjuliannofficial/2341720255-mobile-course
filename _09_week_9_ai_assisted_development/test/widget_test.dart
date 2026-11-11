import 'package:_09_week_9_ai_assisted_development/core/clock.dart';
import 'package:_09_week_9_ai_assisted_development/core/failures.dart';
import 'package:_09_week_9_ai_assisted_development/core/theme/app_theme.dart';
import 'package:_09_week_9_ai_assisted_development/features/announcements/domain/entities/announcement.dart';
import 'package:_09_week_9_ai_assisted_development/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:_09_week_9_ai_assisted_development/features/announcements/presentation/pages/announcements_page.dart';
import 'package:_09_week_9_ai_assisted_development/features/announcements/presentation/providers/announcements_providers.dart';
import 'package:_09_week_9_ai_assisted_development/features/audit/presentation/pages/audit_page.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/domain/entities/note.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/domain/repositories/note_repository.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/presentation/pages/notes_page.dart';
import 'package:_09_week_9_ai_assisted_development/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class StubNoteRepository implements NoteRepository {
  StubNoteRepository({this.notes = const [], this.fail = false});

  final List<Note> notes;
  bool fail;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('Database sedang terkunci'),
      );
    }
    return (notes: notes, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final added = Note(
      id: notes.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 10, 23, 10, 0),
      dirty: true,
    );
    return (note: added, failure: null);
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    return (success: true, failure: null);
  }
}

class StubAnnouncementRepository implements AnnouncementRepository {
  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAnnouncements({String? category}) async {
    return (
      announcements: [
        Announcement(
          id: 1,
          title: 'Klinik Prompt Engineering Flutter',
          content: 'Verifikasi API dan unit test wajib dilakukan.',
          category: 'Akademik',
          publishedAt: DateTime(2026, 10, 23, 9, 0),
          isUrgent: true,
        ),
      ],
      failure: null,
    );
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> getAnnouncementById(
    int id,
  ) async {
    return (announcement: null, failure: null);
  }
}

void main() {
  final fixedClock = FixedClock(DateTime(2026, 10, 23, 12, 0));

  testWidgets('NotesPage shows empty state when no notes exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appClockProvider.overrideWithValue(fixedClock),
          noteRepositoryProvider.overrideWithValue(StubNoteRepository()),
        ],
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clean Architecture Notes'), findsOneWidget);
    expect(find.text('Belum ada catatan.'), findsOneWidget);
  });

  testWidgets(
    'NotesPage filters search query, shows EmptySearchState, and resets',
    (tester) async {
      final sampleNotes = [
        Note(
          id: 1,
          title: 'Belajar Riverpod 3',
          body: 'Migrasi StateProvider ke NotifierProvider',
          updatedAt: DateTime(2026, 10, 23, 11, 0),
          dirty: true,
        ),
        Note(
          id: 2,
          title: 'Belanja Alat Lab',
          body: 'Adaptor dan kabel data',
          updatedAt: DateTime(2026, 10, 22, 10, 0),
          dirty: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appClockProvider.overrideWithValue(fixedClock),
            noteRepositoryProvider.overrideWithValue(
              StubNoteRepository(notes: sampleNotes),
            ),
          ],
          child: const MaterialApp(home: NotesPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belajar Riverpod 3'), findsOneWidget);
      expect(find.text('Belanja Alat Lab'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('notes-search-field')),
        'riverpod',
      );
      await tester.pumpAndSettle();

      expect(find.text('Belajar Riverpod 3'), findsOneWidget);
      expect(find.text('Belanja Alat Lab'), findsNothing);

      await tester.enterText(
        find.byKey(const Key('notes-search-field')),
        'zzz-tidak-ada',
      );
      await tester.pumpAndSettle();

      expect(find.text('Hasil Pencarian Kosong'), findsOneWidget);
      expect(
        find.text('Tidak ada catatan yang cocok dengan "zzz-tidak-ada".'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('reset-search-button')));
      await tester.pumpAndSettle();

      expect(find.text('Belajar Riverpod 3'), findsOneWidget);
      expect(find.text('Belanja Alat Lab'), findsOneWidget);
    },
  );

  testWidgets('NotesPage sync chip filters dirty notes', (tester) async {
    final sampleNotes = [
      Note(
        id: 1,
        title: 'Catatan Offline Baru',
        updatedAt: DateTime(2026, 10, 23, 11, 0),
        dirty: true,
      ),
      Note(
        id: 2,
        title: 'Catatan Sudah Sync',
        updatedAt: DateTime(2026, 10, 22, 10, 0),
        dirty: false,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appClockProvider.overrideWithValue(fixedClock),
          noteRepositoryProvider.overrideWithValue(
            StubNoteRepository(notes: sampleNotes),
          ),
        ],
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Belum Sinkron'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Offline Baru'), findsOneWidget);
    expect(find.text('Catatan Sudah Sync'), findsNothing);
  });

  testWidgets('AnnouncementsPage renders filter chips and announcement cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appClockProvider.overrideWithValue(fixedClock),
          announcementRepositoryProvider.overrideWithValue(
            StubAnnouncementRepository(),
          ),
        ],
        child: const MaterialApp(home: AnnouncementsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pengumuman Kampus'), findsOneWidget);
    expect(find.text('Klinik Prompt Engineering Flutter'), findsOneWidget);
  });

  testWidgets('AuditPage displays Week 9 AI verification sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AuditPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI Verification & Audit'), findsOneWidget);
    expect(
      find.text('1. Verifikasi Hasil Kode AI (6 Langkah)'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Lolos Verifikasi'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('0 Pelanggaran'), findsNWidgets(2));
    expect(find.text('Lolos Verifikasi'), findsOneWidget);
  });

  test('ThemeModeNotifier toggles between light and dark modes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);
    container.read(themeModeProvider.notifier).toggle();
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });
}
