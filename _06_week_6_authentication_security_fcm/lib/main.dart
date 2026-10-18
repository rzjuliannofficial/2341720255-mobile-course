import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase Core (jika google-services.json tersedia)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Core skipped or already initialized: $e');
  }

  // Daftarkan background handler top-level dengan @pragma('vm:entry-point')
  PushService.registerBackgroundHandler();

  // Inisialisasi local notification untuk banner foreground
  await PushService.instance.initLocalNotifications();

  // Minta izin runtime notifikasi (Android 13+ & iOS)
  await PushService.instance.requestNotificationPermission();

  // Ambil token FCM awal, daftarkan onTokenRefresh, dan subscribe topik default
  await PushService.instance.initFcmToken(
    onToken: (token) async {
      // Backend registration endpoint (POST /devices)
      debugPrint(
        'FCM Token terdaftar ke backend: ${PushService.formatTruncatedToken(token)}',
      );
    },
  );

  runApp(
    const ProviderScope(
      child: CampusNotifyApp(),
    ),
  );
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: AppRoutes.home,
      redirect: (context, state) {
        final authState = ref.read(authStateProvider);
        final loggedIn = authState.value ?? false;
        final goingLogin = state.matchedLocation == AppRoutes.login;

        if (!loggedIn && !goingLogin) return AppRoutes.login;
        if (loggedIn && goingLogin) return AppRoutes.home;
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.announcementPattern,
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '1';
            return AnnouncementPage(id: id);
          },
        ),
      ],
    );

    // Hubungkan event notifikasi FCM (Foreground, Background Click, dan Terminated) ke GoRouter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushService.instance.listenForeground((route) {
        _router.go(route);
      });
      PushService.instance.handleTerminated((route) {
        _router.go(route);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch status autentikasi agar router refresh otomatis saat login/logout
    ref.listen<AsyncValue<bool>>(authStateProvider, (previous, next) {
      _router.refresh();
    });

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E40AF),
          primary: const Color(0xFF1E40AF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      routerConfig: _router,
    );
  }
}
