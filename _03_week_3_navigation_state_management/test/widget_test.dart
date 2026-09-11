import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_03_week_3_navigation_state_management/main.dart';

void main() {
  testWidgets('menambah tugas baru pada aplikasi ToDo', (WidgetTester tester) async {
    // 1. Render aplikasi terbungkus ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // 2. Verifikasi state awal kosong
    expect(find.text('Belum ada tugas'), findsOneWidget);

    // 3. Tekan tombol tambah (FloatingActionButton)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 4. Masukkan teks tugas baru dan tekan tombol Tambah
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // 5. Verifikasi bahwa item tugas baru muncul di ListView
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}
