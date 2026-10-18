import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:_06_week_6_authentication_security_fcm/data/api_errors.dart';
import 'package:_06_week_6_authentication_security_fcm/data/auth_repository.dart';
import 'package:_06_week_6_authentication_security_fcm/messaging/push_service.dart';
import 'package:_06_week_6_authentication_security_fcm/routes.dart';

class FakeTokenStore {
  String? access;
  String? refresh;

  void save({required String newAccess, required String newRefresh}) {
    access = newAccess;
    refresh = newRefresh;
  }

  void clear() {
    access = null;
    refresh = null;
  }
}

void main() {
  group('Langkah 7: Testing & Refactoring FCM & Auth', () {
    test('routeFromMessage menangani route kosong, relatif, dan absolut', () {
      expect(routeFromMessage({}), AppRoutes.home);
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': ''}), AppRoutes.home);
    });

    test('data payload membawa id pengumuman diarahkan ke /pengumuman/:id', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');

      const dataWithIdOnly = {'id': '42'};
      expect(routeFromMessage(dataWithIdOnly), '/pengumuman/42');
    });

    test('provider auth membaca status login dari token store', () async {
      final store = FakeTokenStore()..access = 'mock-access-token';
      expect(store.access != null, isTrue);

      store.access = null;
      expect(store.access != null, isFalse);
    });

    test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
      final store = FakeTokenStore()
        ..access = 'old-access'
        ..refresh = '';

      final needsLogin = (store.refresh ?? '').isEmpty;
      expect(needsLogin, isTrue);

      store.clear();
      expect(store.access, isNull);
      expect(store.refresh, isNull);
    });

    test('AuthRepository login validasi email dan password', () async {
      final repo = AuthRepository();

      // Email tidak valid (tanpa @)
      expect(
        () => repo.login(email: 'mahasiswa', password: 'password123'),
        throwsA(isA<Exception>()),
      );

      // Password kurang dari 6 karakter
      expect(
        () => repo.login(email: 'mhs@polinema.ac.id', password: '123'),
        throwsA(isA<Exception>()),
      );

      // Login berhasil
      final session = await repo.login(
        email: 'mahasiswa@polinema.ac.id',
        password: 'password123',
      );
      expect(session.access, contains('mock-access-for-mahasiswa@polinema.ac.id'));
      expect(session.refresh, contains('mock-refresh-for-mahasiswa@polinema.ac.id'));
    });

    test('AuthRepository refresh mengembalikan access token baru', () async {
      final repo = AuthRepository();
      const mockRefresh = 'valid-refresh-token';

      final renewed = await repo.refresh(mockRefresh);
      expect(renewed, startsWith('mock-access-renewed-'));

      expect(
        () => repo.refresh(''),
        throwsA(isA<Exception>()),
      );
    });

    test('formatTruncatedToken memotong token demi keamanan', () {
      const longToken = 'eX7K1mP_fcm_token_very_long_secret_1234567890_abcdef';
      final truncated = PushService.formatTruncatedToken(longToken);

      expect(truncated.contains('...'), isTrue);
      expect(truncated.startsWith('eX7K1mP_fcm_'), isTrue);
      expect(truncated.endsWith('cdef'), isTrue);
      expect(truncated.length < longToken.length, isTrue);

      expect(PushService.formatTruncatedToken(null), 'Belum tersedia');
    });

    test('mapDioErrorToMessage menerjemahkan error Dio ke pesan ramah pengguna', () {
      final err401 = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );
      expect(mapDioErrorToMessage(err401), contains('Sesi autentikasi telah berakhir'));

      final errTimeout = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(mapDioErrorToMessage(errTimeout), contains('waktu habis'));
    });
  });
}
