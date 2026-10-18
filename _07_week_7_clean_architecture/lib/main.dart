import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: CleanArchitectureApp(),
    ),
  );
}

class CleanArchitectureApp extends StatelessWidget {
  const CleanArchitectureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Minggu 7: Clean Architecture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo.shade700,
          secondary: Colors.teal.shade600,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
