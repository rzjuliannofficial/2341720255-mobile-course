import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notes/presentation/providers/notes_providers.dart';
import '../../data/datasources/announcements_remote_source.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';

/// Remote data source provider using shared [appClockProvider].
final announcementsRemoteSourceProvider = Provider<AnnouncementsRemoteSource>((
  ref,
) {
  return MockAnnouncementsRemoteSource(clock: ref.watch(appClockProvider));
});

/// Repository implementation provider for announcements.
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(
    remoteSource: ref.watch(announcementsRemoteSourceProvider),
  );
});

/// Domain use case provider for retrieving filtered announcements.
final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

/// Holds the active category filter chip in the Announcements tab.
class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Semua';

  void select(String category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(
      SelectedCategoryNotifier.new,
    );

/// ViewModel managing announcement list state and typed domain failures.
class AnnouncementsNotifier extends AsyncNotifier<List<Announcement>> {
  @override
  Future<List<Announcement>> build() async {
    final category = ref.watch(selectedCategoryProvider);
    return _load(category);
  }

  Future<List<Announcement>> _load(String category) async {
    final result = await ref
        .read(getAnnouncementsProvider)
        .call(category: category);
    if (result.failure != null) {
      throw result.failure!;
    }
    return result.announcements;
  }

  Future<void> refresh() async {
    final category = ref.read(selectedCategoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(category));
  }
}

final announcementsNotifierProvider =
    AsyncNotifierProvider<AnnouncementsNotifier, List<Announcement>>(
      AnnouncementsNotifier.new,
    );
