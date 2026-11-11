import 'package:_09_week_9_ai_assisted_development/core/clock.dart';
import 'package:_09_week_9_ai_assisted_development/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pure Format & Routing Utilities', () {
    test('formatDateTime formats DateTime into YYYY-MM-DD HH:mm', () {
      final dt = DateTime(2026, 10, 20, 9, 5);
      expect(formatDateTime(dt), '2026-10-20 09:05');
    });

    test('formatTimeAgo uses injected FixedClock deterministically', () {
      final fixedNow = DateTime(2026, 10, 20, 12, 0);
      final clock = FixedClock(fixedNow);

      expect(
        formatTimeAgo(
          fixedNow.subtract(const Duration(seconds: 20)),
          clock: clock,
        ),
        'Baru saja',
      );
      expect(
        formatTimeAgo(
          fixedNow.subtract(const Duration(minutes: 15)),
          clock: clock,
        ),
        '15 menit lalu',
      );
      expect(
        formatTimeAgo(
          fixedNow.subtract(const Duration(hours: 3)),
          clock: clock,
        ),
        '3 jam lalu',
      );
      expect(
        formatTimeAgo(fixedNow.subtract(const Duration(days: 2)), clock: clock),
        '2 hari lalu',
      );
      expect(
        formatTimeAgo(
          fixedNow.subtract(const Duration(days: 10)),
          clock: clock,
        ),
        '2026-10-10 12:00',
      );
    });

    test('normalizeRoute adds leading slash and drops trailing slash', () {
      expect(normalizeRoute(''), '/');
      expect(normalizeRoute('  /  '), '/');
      expect(normalizeRoute('pengumuman/3/'), '/pengumuman/3');
    });

    test('parseIdFromPath extracts integer ID or null', () {
      expect(parseIdFromPath('/pengumuman/42'), 42);
      expect(parseIdFromPath('/pengumuman/abc'), isNull);
    });
  });
}
