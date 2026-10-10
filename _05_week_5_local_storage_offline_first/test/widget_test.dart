import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:_05_week_5_local_storage_offline_first/data/local/note.dart';
import 'package:_05_week_5_local_storage_offline_first/pages/settings_page.dart';
import 'package:_05_week_5_local_storage_offline_first/widgets/note_tile.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'dark_mode': false,
      'last_opened_at': '2026-10-08T19:20:00.000Z',
    });
  });

  group('Widget Tests', () {
    testWidgets('NoteTile renders correctly with dirty badge',
        (WidgetTester tester) async {
      final note = Note(
        id: 1,
        title: 'Catatan Rapat Offline',
        body: 'Membahas arsitektur offline-first SQLite.',
        updatedAt: DateTime(2026, 10, 8, 14, 30),
        dirty: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteTile(note: note),
          ),
        ),
      );

      expect(find.text('Catatan Rapat Offline'), findsOneWidget);
      expect(
        find.text('Membahas arsitektur offline-first SQLite.'),
        findsOneWidget,
      );
      expect(find.text('Belum Tersinkron'), findsOneWidget);
      expect(find.byIcon(Icons.sync_problem), findsOneWidget);
    });

    testWidgets('NoteTile renders correctly with synced badge',
        (WidgetTester tester) async {
      final note = Note(
        id: 2,
        title: 'Catatan Sudah Sinkron',
        body: 'Sudah tersimpan di remote server.',
        updatedAt: DateTime(2026, 10, 8, 15, 0),
        dirty: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteTile(note: note),
          ),
        ),
      );

      expect(find.text('Catatan Sudah Sinkron'), findsOneWidget);
      expect(find.text('Tersinkron'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('SettingsPage renders theme switch and last opened section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Mode Gelap (Dark Mode)'), findsOneWidget);
      expect(find.text('Waktu Terakhir Dibuka'), findsOneWidget);
    });
  });
}
