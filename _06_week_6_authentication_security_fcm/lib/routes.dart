class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcementPattern = '/pengumuman/:id';

  static String announcement(String id) => '/pengumuman/$id';
}

/// Parsing RemoteMessage data payload ke route navigasi aplikasi.
/// Fungsi murni yang mudah diuji secara independen tanpa dependensi Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route']?.toString().trim() ?? '';
  if (route.isEmpty) {
    // Jika tidak ada route tapi ada id pengumuman, arahkan ke pengumuman/:id
    final id = data['id']?.toString().trim();
    if (id != null && id.isNotEmpty) {
      return AppRoutes.announcement(id);
    }
    return AppRoutes.home;
  }
  return route.startsWith('/') ? route : '/$route';
}
