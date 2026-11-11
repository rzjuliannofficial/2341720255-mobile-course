import 'package:flutter/material.dart';

import '../../../../core/clock.dart';
import '../../../../core/format.dart';
import '../../domain/entities/note.dart';

/// Displays a single note with sync badge, relative timestamp, and delete action.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.clock,
    required this.onDelete,
  });

  final Note note;
  final AppClock clock;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final badgeBg = note.dirty
        ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
        : (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5));
    final badgeBorder = note.dirty
        ? (isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309))
        : (isDark ? const Color(0xFF34D399) : const Color(0xFF047857));
    final badgeText = note.dirty
        ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFF78350F))
        : (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF064E3B));

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: note.dirty
                      ? 'Status catatan belum tersinkron'
                      : 'Status catatan tersinkron',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeBorder, width: 0.9),
                    ),
                    child: Text(
                      note.dirty ? 'Offline / Dirty' : 'Tersinkron',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeText,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  tooltip: 'Hapus Catatan',
                  onPressed: onDelete,
                ),
              ],
            ),
            if (note.body.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                note.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  formatTimeAgo(note.updatedAt, clock: clock),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: #${note.id ?? '-'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
