import 'package:flutter/material.dart';

/// Empty state displayed when active search or filter yields zero matches.
class EmptySearchState extends StatelessWidget {
  const EmptySearchState({
    super.key,
    required this.queryText,
    required this.onReset,
  });

  final String queryText;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmed = queryText.trim();
    final message = trimmed.isEmpty
        ? 'Tidak ada catatan dengan status filter yang dipilih.'
        : 'Tidak ada catatan yang cocok dengan "$trimmed".';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 60,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Hasil Pencarian Kosong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('reset-search-button'),
              onPressed: onReset,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Reset Pencarian'),
            ),
          ],
        ),
      ),
    );
  }
}
