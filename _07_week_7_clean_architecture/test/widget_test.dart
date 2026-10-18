import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_07_week_7_clean_architecture/core/failures.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/domain/entities/announcement.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/presentation/pages/announcements_page.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/presentation/providers/announcements_providers.dart';
import 'package:_07_week_7_clean_architecture/features/audit/presentation/pages/audit_page.dart';
import 'package:_07_week_7_clean_architecture/features/notes/domain/entities/note.dart';
import 'package:_07_week_7_clean_architecture/features/notes/domain/repositories/note_repository.dart';
import 'package:_07_week_7_clean_architecture/features/notes/presentation/pages/notes_page.dart';
import 'package:_07_week_7_clean_architecture/features/notes/presentation/providers/notes_providers.dart';

class MockNoteRepository implements NoteRepository {
  MockNoteRepository({this.notes = const []});
  final List<Note> notes;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: notes, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote(
      {required String title, String body = ''}) async {
    return (
      note: Note(title: title, body: body, updatedAt: DateTime.now()),
      failure: null
    );
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    return (success: true, failure: null);
  }
}

class MockAnnouncementRepo implements AnnouncementRepository {
  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements({String? category}) async {
    return (
      announcements: [
        Announcement(
          id: 1,
          title: 'Pengumuman Kuliah Pengganti',
          content: 'Dilaksanakan secara daring',
          category: 'Akademik',
          publishedAt: DateTime(2026, 10, 18),
        ),
      ],
      failure: null
    );
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> getAnnouncementById(
      int id) async {
    return (announcement: null, failure: null);
  }
}

void main() {
  testWidgets('NotesPage menampilkan antarmuka dan empty state saat daftar kosong',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider
              .overrideWithValue(MockNoteRepository(notes: [])),
        ],
        child: const MaterialApp(home: NotesPage()),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Clean Architecture Notes'), findsOneWidget);
    expect(find.text('Belum ada catatan.'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('NotesPage menampilkan daftar kartu saat data catatan tersedia',
      (WidgetTester tester) async {
    final sampleNotes = [
      Note(
        id: 101,
        title: 'Materi Clean Architecture',
        body: 'Mempelajari Entity, Use Case, dan Repository',
        updatedAt: DateTime.now(),
        dirty: false,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider
              .overrideWithValue(MockNoteRepository(notes: sampleNotes)),
        ],
        child: const MaterialApp(home: NotesPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Materi Clean Architecture'), findsOneWidget);
    expect(find.text('Tersinkron'), findsOneWidget);
    expect(find.text('ID: #101'), findsOneWidget);
  });

  testWidgets('AnnouncementsPage menampilkan filter kategori dan kartu pengumuman',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          announcementRepositoryProvider
              .overrideWithValue(MockAnnouncementRepo()),
        ],
        child: const MaterialApp(home: AnnouncementsPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Pengumuman Kampus'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Akademik'), findsOneWidget);
    expect(find.text('Pengumuman Kuliah Pengganti'), findsOneWidget);
  });

  testWidgets('AuditPage menampilkan tabel audit layer dan kartu sterilitas',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AuditPage()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Audit Layer & SOLID'), findsOneWidget);
    expect(find.text('1. Pemetaan Layer Project Lama ke Target'), findsOneWidget);
    expect(find.text('2. Status Tiga Pelanggaran Klasik (Grep Sterilitas)'),
        findsOneWidget);
    expect(find.text('0 Pelanggaran (Lolos)'), findsWidgets);
  });
}
