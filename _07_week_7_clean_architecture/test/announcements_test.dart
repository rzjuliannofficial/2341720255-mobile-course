import 'package:flutter_test/flutter_test.dart';
import 'package:_07_week_7_clean_architecture/core/failures.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/data/models/announcement_model.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/domain/entities/announcement.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:_07_week_7_clean_architecture/features/announcements/domain/usecases/get_announcements.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository({this.items = const [], this.fail = false});

  final List<Announcement> items;
  final bool fail;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements({String? category}) async {
    if (fail) {
      return (
        announcements: const <Announcement>[],
        failure: const NetworkFailure('Koneksi terputus'),
      );
    }
    if (category != null && category.isNotEmpty && category != 'Semua') {
      final filtered = items
          .where((a) => a.category.toLowerCase() == category.toLowerCase())
          .toList();
      return (announcements: filtered, failure: null);
    }
    return (announcements: items, failure: null);
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> getAnnouncementById(
      int id) async {
    final match = items.where((a) => a.id == id).firstOrNull;
    if (match == null) {
      return (
        announcement: null,
        failure: const LocalFailure('Tidak ditemukan'),
      );
    }
    return (announcement: match, failure: null);
  }
}

void main() {
  final sampleItems = [
    Announcement(
      id: 1,
      title: 'Jadwal UTS',
      content: 'Mulai pekan depan',
      category: 'Akademik',
      publishedAt: DateTime(2026, 10, 18),
      isUrgent: true,
    ),
    Announcement(
      id: 2,
      title: 'Beasiswa Djarum',
      content: 'Batas akhir pendaftaran',
      category: 'Beasiswa',
      publishedAt: DateTime(2026, 10, 17),
      isUrgent: false,
    ),
  ];

  group('GetAnnouncements Use Case', () {
    test('Mengambil semua pengumuman tanpa filter kategori', () async {
      final repo = FakeAnnouncementRepository(items: sampleItems);
      final useCase = GetAnnouncements(repo);
      final result = await useCase.call();

      expect(result.failure, isNull);
      expect(result.announcements.length, 2);
    });

    test('Memfilter pengumuman berdasarkan kategori', () async {
      final repo = FakeAnnouncementRepository(items: sampleItems);
      final useCase = GetAnnouncements(repo);
      final result = await useCase.call(category: 'Beasiswa');

      expect(result.failure, isNull);
      expect(result.announcements.length, 1);
      expect(result.announcements.first.category, 'Beasiswa');
    });

    test('Meneruskan NetworkFailure saat terjadi kendala jaringan', () async {
      final repo = FakeAnnouncementRepository(fail: true);
      final useCase = GetAnnouncements(repo);
      final result = await useCase.call();

      expect(result.failure, isA<NetworkFailure>());
      expect(result.announcements, isEmpty);
    });
  });

  group('AnnouncementModel Data Layer Mapping', () {
    test('Serialisasi fromMap dan toMap menghasilkan data konsisten', () {
      final map = {
        'id': 10,
        'title': 'Pengumuman Libur',
        'content': 'Libur nasional',
        'category': 'Umum',
        'published_at': '2026-10-18T10:00:00.000',
        'is_urgent': true,
      };

      final model = AnnouncementModel.fromMap(map);
      expect(model.id, 10);
      expect(model.title, 'Pengumuman Libur');
      expect(model.isUrgent, isTrue);

      final toMapResult = model.toMap();
      expect(toMapResult['id'], 10);
      expect(toMapResult['title'], 'Pengumuman Libur');
      expect(toMapResult['is_urgent'], isTrue);
    });
  });
}
