import 'package:flutter/material.dart';

/// Displays the mid-project readiness overview banner.
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
              Icons.fact_check_outlined,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Status Mid-Project Review: Struktur feature-first Clean Architecture, perbaikan hasil peer code review, linter ketat, dan CI check siap diverifikasi.',
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

/// Summarizes peer code review findings resolved in Week 8.
class PeerReviewFindingsCard extends StatelessWidget {
  const PeerReviewFindingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        children: [
          _ReviewItemTile(
            tag: 'Kebenaran',
            title: 'Dispose TextEditingController pada dialog tambah catatan',
            detail: 'Diekstrak ke StatefulWidget AddNoteDialog agar controller dibersihkan saat dialog ditutup.',
          ),
          Divider(height: 1),
          _ReviewItemTile(
            tag: 'Kebenaran',
            title: 'Konfirmasi hapus dan injeksi AppClock',
            detail: 'Menghapus ketergantungan langsung DateTime.now() di repository dan mencegah hapus tidak sengaja.',
          ),
          Divider(height: 1),
          _ReviewItemTile(
            tag: 'Arsitektur',
            title: 'Propagasi Failure bertipe ke AsyncError & widget const',
            detail: 'Menghindari pembungkusan ulang Exception mentah dan memecah helper build menjadi class widget.',
          ),
          Divider(height: 1),
          _ReviewItemTile(
            tag: 'Quality Gate',
            title: 'Linter ketat, dart format, dan GitHub Actions CI',
            detail: 'Mengaktifkan strict-casts, strict-raw-types, dan workflow ci.yml otomatis per Pull Request.',
          ),
        ],
      ),
    );
  }
}

class _ReviewItemTile extends StatelessWidget {
  const _ReviewItemTile({
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

/// Maps Week 5-6 legacy modules against Week 7-8 Clean Architecture layers.
class LayerMappingCard extends StatelessWidget {
  const LayerMappingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBg = theme.brightness == Brightness.dark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);
    final borderColor = theme.colorScheme.outlineVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          border: TableBorder.all(color: borderColor, width: 0.8),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(0.9),
            2: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: headerBg),
              children: const [
                _TableCellText('File Awal', bold: true),
                _TableCellText('Asal', bold: true),
                _TableCellText('Target Review', bold: true),
              ],
            ),
            const TableRow(
              children: [
                _TableCellText('notes_page.dart', mono: true),
                _TableCellText('Presentation'),
                _TableCellText('ConsumerWidget + AddNoteDialog + NoteCard'),
              ],
            ),
            const TableRow(
              children: [
                _TableCellText('note_repository.dart', mono: true),
                _TableCellText('Data + Kontrak'),
                _TableCellText('Interface di Domain, Impl + Clock di Data'),
              ],
            ),
            const TableRow(
              children: [
                _TableCellText('audit_page.dart', mono: true),
                _TableCellText('Helper _build'),
                _TableCellText('Class StatelessWidget const terpisah'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCellText extends StatelessWidget {
  const _TableCellText(this.text, {this.bold = false, this.mono = false});

  final String text;
  final bool bold;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: mono ? 'monospace' : null,
        ),
      ),
    );
  }
}

/// Lists automated sterility and CI checks verified for the mid-project review.
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
          title: 'Domain & Core bebas package eksternal',
          detail: 'Pure Dart: hanya mengimpor core/ dan sesama domain/',
          badge: '0 Pelanggaran',
        ),
        SizedBox(height: 8),
        _StatusCard(
          title: 'Static Analysis, Format & Automated Test',
          detail: 'flutter analyze + dart format + flutter test',
          badge: 'Lolos CI Gate',
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
              'presentation (Widget, Notifier, Router)\n'
              '      |\n'
              '      v  bergantung ke\n'
              'domain (Entity, Repository Interface, Use Case)\n'
              '      ^\n'
              '      |  diimplementasikan oleh\n'
              'data (Model, Repository Impl, SQLite, Remote)',
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
