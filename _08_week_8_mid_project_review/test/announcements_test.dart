import 'package:_08_week_8_mid_project_review/core/failures.dart';
import 'package:_08_week_8_mid_project_review/features/announcements/data/models/announcement_model.dart';
import 'package:_08_week_8_mid_project_review/features/announcements/domain/entities/announcement.dart';
import 'package:_08_week_8_mid_project_review/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:_08_week_8_mid_project_review/features/announcements/domain/usecases/get_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

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
    int id,
  ) async {
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
      title: 'Jadwal Mid Review',
      content: 'Dilaksanakan pekan ke-8',
      category: 'Akademik',
      publishedAt: DateTime(2026, 10, 20),
      isUrgent: true,
    ),
    Announcement(
      id: 2,
      title: 'Beasiswa Unggulan',
      content: 'Batas akhir minggu ini',
      category: 'Beasiswa',
      publishedAt: DateTime(2026, 10, 19),
    ),
  ];

  group('GetAnnouncements Use Case', () {
    test('returns all items when category is omitted', () async {
      final useCase = GetAnnouncements(
        FakeAnnouncementRepository(items: sampleItems),
      );
      final result = await useCase.call();

      expect(result.failure, isNull);
      expect(result.announcements.length, 2);
    });

    test('filters items by category', () async {
      final useCase = GetAnnouncements(
        FakeAnnouncementRepository(items: sampleItems),
      );
      final result = await useCase.call(category: 'Beasiswa');

      expect(result.failure, isNull);
      expect(result.announcements.length, 1);
      expect(result.announcements.first.title, 'Beasiswa Unggulan');
    });

    test('forwards NetworkFailure when repository fails', () async {
      final useCase = GetAnnouncements(FakeAnnouncementRepository(fail: true));
      final result = await useCase.call();

      expect(result.failure, isA<NetworkFailure>());
      expect(result.announcements, isEmpty);
    });
  });

  group('AnnouncementModel Mapping', () {
    test('round-trips fromMap and toMap consistently', () {
      final map = <String, Object?>{
        'id': 10,
        'title': 'Pengumuman Libur',
        'content': 'Libur nasional',
        'category': 'Umum',
        'published_at': '2026-10-20T10:00:00.000',
        'is_urgent': true,
      };
      final model = AnnouncementModel.fromMap(map);
      expect(model.id, 10);
      expect(model.isUrgent, isTrue);
      expect(model.toMap()['title'], 'Pengumuman Libur');
    });
  });
}
