import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../notes/presentation/providers/notes_providers.dart';
import '../providers/announcements_providers.dart';
import '../widgets/announcement_card.dart';

/// Announcements screen displaying filtered campus announcements.
class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  static const _categories = ['Semua', 'Akademik', 'Beasiswa', 'Event', 'Umum'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsNotifierProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final clock = ref.watch(appClockProvider);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengumuman Kampus',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Minggu 8: Clean Architecture Announcements',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Ubah Tema',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Pengumuman',
            onPressed: () =>
                ref.read(announcementsNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      selectedColor: theme.colorScheme.secondary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).select(cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat pengumuman kampus...'),
                  ],
                ),
              ),
              error: (error, _) {
                final message = error is Failure ? error.message : '$error';
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal Memuat Pengumuman',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => ref
                              .read(announcementsNotifierProvider.notifier)
                              .refresh(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada pengumuman pada kategori "$selectedCategory".',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(announcementsNotifierProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (_, index) => AnnouncementCard(
                      announcement: items[index],
                      clock: clock,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
