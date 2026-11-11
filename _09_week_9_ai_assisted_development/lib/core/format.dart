/// Pure Dart formatting and routing helpers with zero Flutter dependencies.
library;

import 'clock.dart';

/// Formats [dateTime] as `YYYY-MM-DD HH:mm`.
String formatDateTime(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

/// Formats relative elapsed time using an injected [clock] or explicit [now].
String formatTimeAgo(
  DateTime dateTime, {
  AppClock clock = const SystemClock(),
  DateTime? now,
}) {
  final current = now ?? clock.now();
  final difference = current.difference(dateTime);

  if (difference.isNegative || difference.inSeconds < 60) {
    return 'Baru saja';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit lalu';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} jam lalu';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} hari lalu';
  }
  return formatDateTime(dateTime);
}

/// Normalizes a route path so it always starts with `/` and drops trailing `/`.
String normalizeRoute(String rawRoute) {
  final trimmed = rawRoute.trim();
  if (trimmed.isEmpty) return '/';
  final withSlash = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return withSlash.length > 1 && withSlash.endsWith('/')
      ? withSlash.substring(0, withSlash.length - 1)
      : withSlash;
}

/// Extracts an integer ID from the last segment of [path], or null if invalid.
int? parseIdFromPath(String path) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return null;
  return int.tryParse(segments.last);
}
