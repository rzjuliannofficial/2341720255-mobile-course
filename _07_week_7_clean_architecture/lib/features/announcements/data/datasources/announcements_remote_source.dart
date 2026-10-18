import '../../../../core/failures.dart';
import '../models/announcement_model.dart';

/// Data source interface for announcements.
abstract class AnnouncementsRemoteSource {
  Future<List<AnnouncementModel>> getAnnouncements();
}

/// Simulated campus announcement remote source with realistic academic data.
class MockAnnouncementsRemoteSource implements AnnouncementsRemoteSource {
  final List<Map<String, dynamic>> _mockData = [
    {
      'id': 1,
      'title': 'Jadwal Ujian Tengah Semester (UTS) Genap 2025/2026',
      'content':
          'Pelaksanaan UTS akan diselenggarakan mulai 20 Oktober 2026. Seluruh mahasiswa wajib mencetak kartu ujian dan mematuhi tata tertib ruang.',
      'category': 'Akademik',
      'published_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'is_urgent': true,
    },
    {
      'id': 2,
      'title': 'Pendaftaran Beasiswa Unggulan Prestasi Mahasiswa',
      'content':
          'Pendaftaran beasiswa prestasi dibuka untuk mahasiswa semester 3-5 dengan IPK minimal 3.50. Berkas dapat dikumpulkan ke bagian kemahasiswaan.',
      'category': 'Beasiswa',
      'published_at': DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
      'is_urgent': false,
    },
    {
      'id': 3,
      'title': 'Workshop Clean Architecture & State Management Flutter',
      'content':
          'Jurusan Teknologi Informasi mengadakan workshop arsitektur perangkat lunak mobile pada hari Sabtu, 24 Oktober 2026 di Auditorium Utama.',
      'category': 'Event',
      'published_at': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
      'is_urgent': false,
    },
    {
      'id': 4,
      'title': 'Pemberitahuan Pemeliharaan Server Portal SIAKAD Kampus',
      'content':
          'Server SIAKAD akan mengalami downtime sementara pada hari Minggu pukul 01.00 - 05.00 WIB untuk pemeliharaan rutin infrastruktur database.',
      'category': 'Umum',
      'published_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'is_urgent': true,
    },
  ];

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    // Simulate slight network latency
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _mockData.map(AnnouncementModel.fromMap).toList();
    } catch (e) {
      throw ServerFailure('Gagal mengurai respons pengumuman: $e');
    }
  }
}
