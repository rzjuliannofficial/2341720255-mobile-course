import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MidProjectReviewApp()));
}

class MidProjectReviewApp extends ConsumerWidget {
  const MidProjectReviewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Minggu 8: Mid-Project Review',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
