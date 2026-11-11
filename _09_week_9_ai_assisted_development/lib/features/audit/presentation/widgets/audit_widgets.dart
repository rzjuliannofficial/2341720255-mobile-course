import 'package:flutter/material.dart';

/// Displays the Week 9 AI-Assisted verification summary banner.
class MidReviewSummaryBanner extends StatelessWidget {
  const MidReviewSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF);
    final border = isDark ? const Color(0xFF475569) : const Color(0xFFC7D2FE);

    return Card(
      color: bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Siklus AI Terkendali: Prompt 5-Slot -> Generate -> Verify API -> Red-Green Test -> Refactor ke SearchNotes Use Case murni.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summarizes hallucinations and bugs caught during AI verification in Week 9.
class PeerReviewFindingsCard extends StatelessWidget {
  const PeerReviewFindingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        children: [
          _AuditTile(
            tag: 'API Ditolak',
            title: 'StateProvider Riverpod v2 diganti NotifierProvider v3',
            detail: 'Draf AI memakai StateProvider yang tidak kompatibel dengan standar Riverpod 3.4.3.',
          ),
          Divider(height: 1),
          _AuditTile(
            tag: 'Bug Logika',
            title: 'Case-sensitive filter & spasi tepi diperbaiki lewat test',
            detail: 'SearchNotes menormalkan .trim().toLowerCase() agar pencarian "  flutter  " tetap cocok.',
          ),
          Divider(height: 1),
          _AuditTile(
            tag: 'Refactor Layer',
            title: 'Logika filter dipindah dari Widget ke SearchNotes',
            detail: 'Widget hanya merender NotesSearchBar dan EmptySearchState tanpa manipulasi list.',
          ),
        ],
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({
    required this.tag,
    required this.title,
    required this.detail,
  });

  final String tag;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        child: Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
      ),
      title: Text(
        '[$tag] $title',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          detail,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Lists automated sterility and static analysis status for Week 9.
class SterilityStatusList extends StatelessWidget {
  const SterilityStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _StatusCard(
          title: 'Presentation steril dari data mentah',
          detail: 'Bebas panggilan HTTP, DB lokal, & parser JSON mentah',
          badge: '0 Pelanggaran',
        ),
        SizedBox(height: 8),
        _StatusCard(
          title: 'SearchNotes murni di Domain Layer',
          detail: 'Pure Dart: bebas package Flutter/SQLite/Dio',
          badge: '0 Pelanggaran',
        ),
        SizedBox(height: 8),
        _StatusCard(
          title: 'Static Analysis, Format & Search Tests',
          detail: 'flutter analyze + dart format + search_notes_test.dart',
          badge: 'Lolos Verifikasi',
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.detail,
    required this.badge,
  });

  final String title;
  final String detail;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final badgeBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
    final badgeFg = isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: badgeBg,
          child: Icon(Icons.verified, color: badgeFg, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          detail,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: badgeFg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Visualizes the inward-pointing Dependency Rule.
class DependencyRuleCard extends StatelessWidget {
  const DependencyRuleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: Color(0xFF0F172A),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Arah Dependensi (The Dependency Rule)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'presentation (NotesSearchBar, NotesQueryNotifier)\n'
              '      |\n'
              '      v  bergantung ke\n'
              'domain (NotesQuery, SearchNotes Use Case)\n'
              '      ^\n'
              '      |  diimplementasikan oleh\n'
              'data (NoteModel, NoteRepositoryImpl, SQLite)',
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
