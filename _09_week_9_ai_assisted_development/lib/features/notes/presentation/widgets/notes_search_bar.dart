import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notes_query.dart';
import '../providers/notes_providers.dart';

/// Search input, sync status filter chips, and sort toggle for notes.
class NotesSearchBar extends ConsumerStatefulWidget {
  const NotesSearchBar({super.key});

  @override
  ConsumerState<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _NotesSearchBarState extends ConsumerState<NotesSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncControllerWithState(String currentQuery) {
    if (_controller.text != currentQuery) {
      _controller.value = TextEditingValue(
        text: currentQuery,
        selection: TextSelection.collapsed(offset: currentQuery.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(notesQueryProvider);
    _syncControllerWithState(query.query);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('notes-search-field'),
                  controller: _controller,
                  onChanged: (value) =>
                      ref.read(notesQueryProvider.notifier).setQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Cari judul atau isi catatan...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.query.isNotEmpty
                        ? IconButton(
                            key: const Key('clear-search-button'),
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            tooltip: 'Hapus Kata Kunci',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _controller.clear();
                              ref
                                  .read(notesQueryProvider.notifier)
                                  .setQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: 'Ubah urutan catatan',
                child: OutlinedButton.icon(
                  key: const Key('sort-notes-button'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final next = query.sortOrder == NoteSortOrder.newestFirst
                        ? NoteSortOrder.titleAsc
                        : NoteSortOrder.newestFirst;
                    ref.read(notesQueryProvider.notifier).setSortOrder(next);
                  },
                  icon: const Icon(Icons.sort, size: 18),
                  label: Text(
                    query.sortOrder == NoteSortOrder.newestFirst
                        ? 'Terbaru'
                        : 'A-Z',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SyncChip(
                  label: 'Semua',
                  selected: query.syncFilter == NoteSyncFilter.all,
                  onSelected: () => ref
                      .read(notesQueryProvider.notifier)
                      .setSyncFilter(NoteSyncFilter.all),
                ),
                const SizedBox(width: 8),
                _SyncChip(
                  label: 'Belum Sinkron',
                  selected: query.syncFilter == NoteSyncFilter.dirtyOnly,
                  onSelected: () => ref
                      .read(notesQueryProvider.notifier)
                      .setSyncFilter(NoteSyncFilter.dirtyOnly),
                ),
                const SizedBox(width: 8),
                _SyncChip(
                  label: 'Tersinkron',
                  selected: query.syncFilter == NoteSyncFilter.syncedOnly,
                  onSelected: () => ref
                      .read(notesQueryProvider.notifier)
                      .setSyncFilter(NoteSyncFilter.syncedOnly),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncChip extends StatelessWidget {
  const _SyncChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
