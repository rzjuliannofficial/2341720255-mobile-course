import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/announcements_remote_source.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';

// DATA LAYER DI: Remote data source
final announcementsRemoteSourceProvider =
    Provider<AnnouncementsRemoteSource>((ref) {
  return MockAnnouncementsRemoteSource();
});

// DATA LAYER DI: Repository implementation
final announcementRepositoryProvider =
    Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(
    remoteSource: ref.watch(announcementsRemoteSourceProvider),
  );
});

// DOMAIN LAYER DI: Use Case
final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

// PRESENTATION: Selected filter category
class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Semua';

  void select(String category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(
        SelectedCategoryNotifier.new);

// PRESENTATION: Reactive AsyncNotifier for Announcements UI
class AnnouncementsNotifier extends AsyncNotifier<List<Announcement>> {
  @override
  Future<List<Announcement>> build() async {
    final category = ref.watch(selectedCategoryProvider);
    final useCase = ref.watch(getAnnouncementsProvider);
    final result = await useCase.call(category: category);

    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.announcements;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final category = ref.read(selectedCategoryProvider);
      final result =
          await ref.read(getAnnouncementsProvider).call(category: category);
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      return result.announcements;
    });
  }
}

final announcementsNotifierProvider =
    AsyncNotifierProvider<AnnouncementsNotifier, List<Announcement>>(
        AnnouncementsNotifier.new);
