import 'package:flutter_test/flutter_test.dart';
import 'package:_07_week_7_clean_architecture/core/format.dart';

void main() {
  group('Format Pure Functions Test', () {
    test('formatDateTime memformat DateTime ke format standar YYYY-MM-DD HH:mm', () {
      final dt = DateTime(2026, 10, 18, 14, 30);
      expect(formatDateTime(dt), '2026-10-18 14:30');
    });

    test('formatTimeAgo menghitung selisih waktu secara akurat', () {
      final now = DateTime(2026, 10, 18, 12, 0);

      final justNow = DateTime(2026, 10, 18, 11, 59, 30);
      expect(formatTimeAgo(justNow, now: now), 'Baru saja');

      final tenMinutesAgo = DateTime(2026, 10, 18, 11, 50);
      expect(formatTimeAgo(tenMinutesAgo, now: now), '10 menit lalu');

      final twoHoursAgo = DateTime(2026, 10, 18, 10, 0);
      expect(formatTimeAgo(twoHoursAgo, now: now), '2 jam lalu');

      final twoDaysAgo = DateTime(2026, 10, 16, 12, 0);
      expect(formatTimeAgo(twoDaysAgo, now: now), '2 hari lalu');
    });

    test('normalizeRoute menormalkan path dan slash awalan/akhiran', () {
      expect(normalizeRoute('notes'), '/notes');
      expect(normalizeRoute('/notes/'), '/notes');
      expect(normalizeRoute('   /announcements   '), '/announcements');
      expect(normalizeRoute(''), '/');
    });

    test('parseIdFromPath mengekstrak ID integer dari rute REST / URI', () {
      expect(parseIdFromPath('/announcements/42'), 42);
      expect(parseIdFromPath('notes/7'), 7);
      expect(parseIdFromPath('/invalid/abc'), isNull);
      expect(parseIdFromPath(''), isNull);
    });
  });
}
