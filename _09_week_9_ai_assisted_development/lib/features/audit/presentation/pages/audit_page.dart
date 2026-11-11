import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/audit_widgets.dart';

/// Displays Week 9 AI-Assisted Development verification and Clean Architecture checks.
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
              'AI Verification & Audit',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Minggu 9: Prompt 5-Slot, Verify & Refactor',
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
            '1. Verifikasi Hasil Kode AI (6 Langkah)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          const PeerReviewFindingsCard(),
          const SizedBox(height: 20),
          Text(
            '2. Sterilitas Clean Architecture & Test',
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
