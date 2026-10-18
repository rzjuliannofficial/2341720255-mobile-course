import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes.dart';

final FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

/// Background handler wajib berupa fungsi top-level (bukan method class)
/// dan dianotasi @pragma('vm:entry-point') karena berjalan di Dart isolate terpisah.
/// PENTING: Dilarang mengakses BuildContext atau provider UI di sini.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hanya melakukan pencatatan atau penyimpanan lokal ringan jika diperlukan.
  // Navigasi UI hanya boleh dijalankan saat pengguna mengklik banner.
  debugPrint('FCM Background message received: ${message.messageId}');
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  bool _isInitialized = false;
  String? _cachedFcmToken;
  bool _subscribedToCampus = true;

  bool get isInitialized => _isInitialized;
  String? get cachedToken => _cachedFcmToken;
  bool get isSubscribedToCampus => _subscribedToCampus;

  /// Memotong token untuk keperluan tampilan debug/laporan.
  /// PRINSIP KEAMANAN: Jangan pernah menampilkan token penuh di screenshot atau log.
  static String formatTruncatedToken(String? token) {
    if (token == null || token.isEmpty) return 'Belum tersedia';
    if (token.length <= 16) return token;
    return '${token.substring(0, 12)}...${token.substring(token.length - 4)}';
  }

  /// Mendaftarkan background handler ke Firebase Messaging.
  static void registerBackgroundHandler() {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Background handler registration skipped: $e');
    }
  }

  /// Meminta izin notifikasi runtime (Wajib untuk Android 13+ & iOS).
  Future<bool> requestNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Request permission error (fallback to local): $e');
      return true;
    }
  }

  /// Menginisialisasi flutter_local_notifications untuk banner notifikasi saat foreground.
  Future<void> initLocalNotifications({
    void Function(String route)? onSelectNotification,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);

    await localNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          pendingDeepLink = payload;
          if (onSelectNotification != null) {
            onSelectNotification(payload);
          }
        }
      },
    );
  }

  /// Mengelola lifecycle token: mengambil token awal, mendaftarkan listener rotasi,
  /// serta subscribe ke topik pengumuman kampus default.
  Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
  }) async {
    try {
      // 1. Ambil token saat ini
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _cachedFcmToken = token;
        await onToken(token);
      }

      // 2. Listener rotasi token (Wajib agar backend tidak menyimpan token basi saat reinstall/clear data)
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        _cachedFcmToken = newToken;
        await onToken(newToken);
      });

      // 3. Langganan topik kampus
      await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
      _subscribedToCampus = true;
    } catch (e) {
      debugPrint('FCM token init skipped/mock mode: $e');
      // Simulasi token untuk environment tanpa Google Play Services
      _cachedFcmToken = 'mock-fcm-token-${DateTime.now().millisecondsSinceEpoch}-campus';
      await onToken(_cachedFcmToken!);
    }
    _isInitialized = true;
  }

  /// Mendengarkan notifikasi masuk saat aplikasi di FOREGROUND dan BACKGROUND (klik).
  void listenForeground(void Function(String route) go) {
    try {
      // FOREGROUND: Sistem Android/iOS TIDAK menampilkan banner otomatis saat app dibuka,
      // sehingga WAJIB ditampilkan manual melalui flutter_local_notifications.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final route = routeFromMessage(message.data);
        const androidDetails = AndroidNotificationDetails(
          'pengumuman',
          'Pengumuman Kampus',
          channelDescription: 'Saluran pengumuman akademik dan kegiatan kampus',
          importance: Importance.high,
          priority: Priority.high,
        );
        const notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(),
        );

        final title = message.notification?.title ?? 'Pengumuman Baru';
        final body = message.notification?.body ?? 'Ada pembaruan informasi akademik.';

        await localNotificationsPlugin.show(
          id: message.hashCode,
          title: title,
          body: body,
          notificationDetails: notificationDetails,
          payload: route,
        );
      });

      // BACKGROUND: Ketika notifikasi sistem diklik dan aplikasi kembali ke foreground
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final route = routeFromMessage(message.data);
        go(route);
      });
    } catch (e) {
      debugPrint('Foreground listener init error: $e');
    }
  }

  /// Menangani aplikasi dibuka dari state TERMINATED (aplikasi mati total lalu dibuka dari klik notifikasi).
  Future<void> handleTerminated(void Function(String route) go) async {
    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        final route = routeFromMessage(initial.data);
        go(route);
        return;
      }
    } catch (e) {
      debugPrint('handleTerminated getInitialMessage error: $e');
    }

    if (pendingDeepLink != null) {
      final route = pendingDeepLink!;
      pendingDeepLink = null;
      go(route);
    }
  }

  /// Berlangganan topik FCM
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('Mock subscribeToTopic: $topic');
    }
    if (topic == 'pengumuman-kampus') _subscribedToCampus = true;
  }

  /// Berhenti langganan topik FCM
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('Mock unsubscribeFromTopic: $topic');
    }
    if (topic == 'pengumuman-kampus') _subscribedToCampus = false;
  }

  /// Simulasi notifikasi masuk (sangat berguna untuk pengujian mandiri di emulator/desktop)
  Future<void> triggerSimulatedNotification({
    required String title,
    required String body,
    required String route,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      channelDescription: 'Saluran pengumuman akademik kampus',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await localNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: route,
    );
  }
}
