import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/announcements/presentation/pages/announcements_page.dart';
import 'features/audit/presentation/pages/audit_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';

abstract final class AppRoutes {
  static const notes = '/';
  static const announcements = '/announcements';
  static const audit = '/audit';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.notes,
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route_outlined, size: 48),
            const SizedBox(height: 12),
            Text('Rute "${state.uri}" tidak terdaftar.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.notes),
              child: const Text('Kembali ke Catatan'),
            ),
          ],
        ),
      ),
    ),
  ),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.note_alt_outlined),
                selectedIcon: Icon(Icons.note_alt),
                label: 'Catatan',
              ),
              NavigationDestination(
                icon: Icon(Icons.campaign_outlined),
                selectedIcon: Icon(Icons.campaign),
                label: 'Pengumuman',
              ),
              NavigationDestination(
                icon: Icon(Icons.fact_check_outlined),
                selectedIcon: Icon(Icons.fact_check),
                label: 'Review & Audit',
              ),
            ],
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.notes,
              builder: (_, _) => const NotesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.announcements,
              builder: (_, _) => const AnnouncementsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.audit,
              builder: (_, _) => const AuditPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
