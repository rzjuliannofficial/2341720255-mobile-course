import '../../../../core/clock.dart';
import '../../../../core/failures.dart';
import '../models/announcement_model.dart';

/// Data source interface for announcements.
abstract interface class AnnouncementsRemoteSource {
  Future<List<AnnouncementModel>> getAnnouncements();
}

/// Simulated campus announcement remote source using an injected [AppClock].
class MockAnnouncementsRemoteSource implements AnnouncementsRemoteSource {
  const MockAnnouncementsRemoteSource({this.clock = const SystemClock()});

  final AppClock clock;

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final anchor = clock.now();
    final rawItems = <Map<String, Object?>>[
      {
        'id': 1,
        'title': 'Jadwal Evaluasi Tengah Semester (Mid-Project Review)',
        'content': 'Review tengah semester wajib melampirkan bukti PR kecil, hasil flutter analyze bersih, dan seluruh unit/widget test hijau.',
        'category': 'Akademik',
        'published_at': anchor
            .subtract(const Duration(hours: 3))
            .toIso8601String(),
        'is_urgent': true,
      },
      {
        'id': 2,
        'title': 'Pendaftaran Beasiswa Unggulan Prestasi Mahasiswa',
        'content': 'Pendaftaran beasiswa prestasi dibuka untuk mahasiswa semester 3-5 dengan IPK minimal 3.50 di bagian kemahasiswaan.',
        'category': 'Beasiswa',
        'published_at': anchor
            .subtract(const Duration(hours: 18))
            .toIso8601String(),
        'is_urgent': false,
      },
      {
        'id': 3,
        'title': 'Workshop Git Flow & Peer Code Review JTI Polinema',
        'content': 'Jurusan Teknologi Informasi mengadakan klinik code review Flutter pada hari Sabtu di Auditorium Utama.',
        'category': 'Event',
        'published_at': anchor
            .subtract(const Duration(days: 1, hours: 2))
            .toIso8601String(),
        'is_urgent': false,
      },
      {
        'id': 4,
        'title': 'Pemeliharaan Terjadwal Server Portal SIAKAD',
        'content': 'Server SIAKAD mengalami pemeliharaan rutin pada hari Minggu pukul 01.00 - 05.00 WIB.',
        'category': 'Umum',
        'published_at': anchor
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'is_urgent': true,
      },
    ];

    try {
      return rawItems.map(AnnouncementModel.fromMap).toList();
    } catch (e) {
      throw ServerFailure('Gagal mengurai respons pengumuman: $e');
    }
  }
}
