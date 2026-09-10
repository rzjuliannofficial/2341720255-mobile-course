import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_03_week_3_navigation_state_management/providers/stats_provider.dart';

/// Test Notifier turunan untuk menguji kondisi deterministic Success
class TestSuccessStatsNotifier extends StatsNotifier {
  @override
  Future<List<StatItem>> build() async {
    return const [
      StatItem(label: 'Total Pengguna Aktif', value: '1.420 User'),
      StatItem(label: 'Total Transaksi Selesai', value: '385 Transaksi'),
      StatItem(label: 'Tingkat Kepuasan Layanan', value: '98.5%'),
    ];
  }
}

void main() {
  group('StatsNotifier Unit Tests', () {
    test('Initial state bernilai loading lalu menjadi AsyncData saat sukses', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => TestSuccessStatsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      // Pastikan state awal adalah AsyncLoading
      expect(
        container.read(statsProvider),
        isA<AsyncLoading<List<StatItem>>>(),
      );

      // Tunggu hingga build notifier selesai
      final stats = await container.read(statsProvider.future);

      // Verifikasi data success
      expect(stats.length, 3);
      expect(stats[0].label, 'Total Pengguna Aktif');
      expect(container.read(statsProvider), isA<AsyncData<List<StatItem>>>());
    });

    test('State bernilai AsyncError saat error terjadi', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => TestSuccessStatsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      // Pastikan state awal data berhasil
      await container.read(statsProvider.future);
      expect(container.read(statsProvider), isA<AsyncData<List<StatItem>>>());

      // Set state menjadi error menggunakan guard
      container.read(statsProvider.notifier).state =
          await AsyncValue.guard<List<StatItem>>(() async {
        throw Exception('Simulasi kegagalan 30%');
      });

      // Verifikasi bahwa state saat ini adalah AsyncError
      final state = container.read(statsProvider);
      expect(state, isA<AsyncError<List<StatItem>>>());
      expect(state.error.toString(), contains('Simulasi kegagalan 30%'));
    });

    test('Retry method dapat memicu pembaruan state secara aman', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => TestSuccessStatsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(statsProvider.future);
      expect(container.read(statsProvider), isA<AsyncData<List<StatItem>>>());

      // Panggil method retry
      await container.read(statsProvider.notifier).retry();
      expect(container.read(statsProvider).hasValue, isTrue);
    });
  });
}
