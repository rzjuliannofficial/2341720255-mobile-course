/// Pure Dart formatting and parsing utilities.
/// Pure functions with zero Flutter framework dependencies.
library;

/// Formats [DateTime] into a standard readable date string (YYYY-MM-DD HH:mm).
String formatDateTime(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

/// Formats relative time (time ago) with an optional injected [now] reference.
String formatTimeAgo(DateTime dateTime, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final difference = current.difference(dateTime);

  if (difference.isNegative || difference.inSeconds < 60) {
    return 'Baru saja';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit lalu';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} jam lalu';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} hari lalu';
  } else {
    return formatDateTime(dateTime);
  }
}

/// Normalizes route string, guaranteeing a leading slash and trimming trailing slashes.
String normalizeRoute(String rawRoute) {
  final trimmed = rawRoute.trim();
  if (trimmed.isEmpty) return '/';
  final withSlash = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return withSlash.length > 1 && withSlash.endsWith('/')
      ? withSlash.substring(0, withSlash.length - 1)
      : withSlash;
}

/// Safely extracts an integer ID from a path segment (e.g., '/pengumuman/42' -> 42).
int? parseIdFromPath(String path) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return null;
  return int.tryParse(segments.last);
}
