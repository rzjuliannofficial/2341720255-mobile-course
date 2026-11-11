import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/audit_widgets.dart';

/// Displays the Week 8 Mid-Project Review, peer review fixes, and sterility audit.
class AuditPage extends ConsumerWidget {
  const AuditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mid-Project Review & Audit',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Git Flow, Code Review & Sterilitas Layer',
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
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MidReviewSummaryBanner(),
          const SizedBox(height: 16),
          Text(
            '1. Tindak Lanjut Peer Code Review',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          const PeerReviewFindingsCard(),
          const SizedBox(height: 20),
          Text(
            '2. Pemetaan Layer Hasil Refactor',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          const LayerMappingCard(),
          const SizedBox(height: 20),
          Text(
            '3. Verifikasi Sterilitas & CI Gate',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          const SterilityStatusList(),
          const SizedBox(height: 20),
          const DependencyRuleCard(),
        ],
      ),
    );
  }
}
