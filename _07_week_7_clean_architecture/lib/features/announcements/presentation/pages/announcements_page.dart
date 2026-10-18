import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format.dart';
import '../../domain/entities/announcement.dart';
import '../providers/announcements_providers.dart';

/// Clean Architecture Announcements Screen.
/// Free of raw Dio / JSON manipulation, consuming domain entities via Riverpod.
class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  static const _categories = ['Semua', 'Akademik', 'Beasiswa', 'Event', 'Umum'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsNotifierProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengumuman Kampus',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Clean Architecture: Announcements Feature',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
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
          // Filter category chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.teal.shade50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      selectedColor: Colors.teal.shade700,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.teal.shade900,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .select(cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Content
          Expanded(
            child: state.when(
              loading: () => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text('Memuat data pengumuman...'),
                  ],
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Gagal Memuat Pengumuman',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$err',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.teal.shade700),
                        onPressed: () => ref
                            .read(announcementsNotifierProvider.notifier)
                            .refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada pengumuman pada kategori "$selectedCategory".',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: Colors.teal,
                  onRefresh: () => ref
                      .read(announcementsNotifierProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (ctx, index) {
                      final item = items[index];
                      return _AnnouncementCard(announcement: item);
                    },
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

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: announcement.isUrgent
            ? BorderSide(color: Colors.red.shade300, width: 1.2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade300),
                  ),
                  child: Text(
                    announcement.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ),
                if (announcement.isUrgent) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.priority_high,
                            size: 11, color: Colors.red.shade800),
                        Text(
                          'PENTING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  formatTimeAgo(announcement.publishedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              announcement.content,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
