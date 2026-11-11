import 'package:flutter/material.dart';

import '../../../../core/clock.dart';
import '../../../../core/format.dart';
import '../../domain/entities/announcement.dart';

/// Renders an academic announcement card with category and urgency indicators.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.clock,
  });

  final Announcement announcement;
  final AppClock clock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryBg = isDark
        ? const Color(0xFF134E4A)
        : const Color(0xFFCCFBF1);
    final categoryFg = isDark
        ? const Color(0xFF99F6E4)
        : const Color(0xFF115E59);
    final urgentBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
    final urgentFg = isDark ? const Color(0xFFFECACA) : const Color(0xFF991B1B);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: announcement.isUrgent
            ? BorderSide(color: theme.colorScheme.error, width: 1.2)
            : BorderSide(color: theme.colorScheme.outlineVariant, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: categoryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    announcement.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: categoryFg,
                    ),
                  ),
                ),
                if (announcement.isUrgent) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: urgentBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.priority_high, size: 12, color: urgentFg),
                        const SizedBox(width: 2),
                        Text(
                          'PENTING',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: urgentFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  formatTimeAgo(announcement.publishedAt, clock: clock),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              announcement.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              announcement.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
