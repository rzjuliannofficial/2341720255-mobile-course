import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/announcements/presentation/pages/announcements_page.dart';
import 'features/audit/presentation/pages/audit_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';

abstract class AppRoutes {
  static const notes = '/';
  static const announcements = '/announcements';
  static const audit = '/audit';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.notes,
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
                icon: Icon(Icons.architecture_outlined),
                selectedIcon: Icon(Icons.architecture),
                label: 'Audit Clean',
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
              builder: (context, state) => const NotesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.announcements,
              builder: (context, state) => const AnnouncementsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.audit,
              builder: (context, state) => const AuditPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
