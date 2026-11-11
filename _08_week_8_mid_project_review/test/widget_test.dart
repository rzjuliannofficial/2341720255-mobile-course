import 'package:_08_week_8_mid_project_review/core/clock.dart';
import 'package:_08_week_8_mid_project_review/core/failures.dart';
import 'package:_08_week_8_mid_project_review/core/theme/app_theme.dart';
import 'package:_08_week_8_mid_project_review/features/announcements/domain/entities/announcement.dart';
import 'package:_08_week_8_mid_project_review/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:_08_week_8_mid_project_review/features/announcements/presentation/pages/announcements_page.dart';
import 'package:_08_week_8_mid_project_review/features/announcements/presentation/providers/announcements_providers.dart';
import 'package:_08_week_8_mid_project_review/features/audit/presentation/pages/audit_page.dart';
import 'package:_08_week_8_mid_project_review/features/notes/domain/entities/note.dart';
import 'package:_08_week_8_mid_project_review/features/notes/domain/repositories/note_repository.dart';
import 'package:_08_week_8_mid_project_review/features/notes/presentation/pages/notes_page.dart';
import 'package:_08_week_8_mid_project_review/features/notes/presentation/providers/notes_providers.dart';
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
      updatedAt: DateTime(2026, 10, 20, 10, 0),
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
          title: 'Review Kode PR #12',
          content: 'Pastikan flutter analyze bersih.',
          category: 'Akademik',
          publishedAt: DateTime(2026, 10, 20, 9, 0),
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
  final fixedClock = FixedClock(DateTime(2026, 10, 20, 12, 0));

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

  testWidgets('NotesPage shows typed failure and recovers on retry', (
    tester,
  ) async {
    final repo = StubNoteRepository(
      fail: true,
      notes: [
        Note(
          id: 1,
          title: 'Catatan Pulih',
          updatedAt: DateTime(2026, 10, 20, 11, 30),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appClockProvider.overrideWithValue(fixedClock),
          noteRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Database sedang terkunci'), findsOneWidget);

    repo.fail = false;
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Pulih'), findsOneWidget);
    expect(find.text('30 menit lalu'), findsOneWidget);
  });

  testWidgets('AddNoteDialog validates blank title before closing', (
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

    await tester.tap(find.byKey(const Key('add-note-fab')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('save-note-button')));
    await tester.pump();

    expect(find.text('Judul tidak boleh kosong'), findsOneWidget);
    expect(find.text('Tambah Catatan Baru'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Catatan Baru'), findsNothing);
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
    expect(find.widgetWithText(FilterChip, 'Akademik'), findsOneWidget);
    expect(find.text('Review Kode PR #12'), findsOneWidget);
    expect(find.text('PENTING'), findsOneWidget);
  });

  testWidgets('AuditPage displays peer review and sterility sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AuditPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mid-Project Review & Audit'), findsOneWidget);
    expect(find.text('1. Tindak Lanjut Peer Code Review'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Lolos CI Gate'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('0 Pelanggaran'), findsNWidgets(2));
    expect(find.text('Lolos CI Gate'), findsOneWidget);
  });

  test('ThemeModeNotifier toggles between light and dark modes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);
    container.read(themeModeProvider.notifier).toggle();
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });
}
