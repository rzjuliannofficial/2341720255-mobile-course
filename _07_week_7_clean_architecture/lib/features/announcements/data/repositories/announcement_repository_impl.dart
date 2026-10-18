import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcements_remote_source.dart';

/// Implementation of [AnnouncementRepository].
/// Decoupled from the UI, converting raw exceptions to domain [Failure].
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl({required this.remoteSource});

  final AnnouncementsRemoteSource remoteSource;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements({String? category}) async {
    try {
      final models = await remoteSource.getAnnouncements();
      var entities = models.map((m) => m.toEntity()).toList();

      if (category != null && category.isNotEmpty && category != 'Semua') {
        entities = entities
            .where((a) => a.category.toLowerCase() == category.toLowerCase())
            .toList();
      }

      return (announcements: entities, failure: null);
    } on Failure catch (f) {
      return (announcements: const <Announcement>[], failure: f);
    } catch (e) {
      return (
        announcements: const <Announcement>[],
        failure: NetworkFailure('Gagal memuat pengumuman: $e'),
      );
    }
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> getAnnouncementById(
      int id) async {
    try {
      final models = await remoteSource.getAnnouncements();
      final match = models.where((m) => m.id == id).firstOrNull;
      if (match == null) {
        return (
          announcement: null,
          failure: const LocalFailure('Pengumuman tidak ditemukan.'),
        );
      }
      return (announcement: match.toEntity(), failure: null);
    } catch (e) {
      return (
        announcement: null,
        failure: NetworkFailure('Gagal membaca detail pengumuman: $e'),
      );
    }
  }
}
