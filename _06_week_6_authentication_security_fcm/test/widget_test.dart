import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:_06_week_6_authentication_security_fcm/pages/login_page.dart';
import 'package:_06_week_6_authentication_security_fcm/providers/auth_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<bool> build() async => false;
}

void main() {
  testWidgets('LoginPage renders email, password inputs, and login button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(FakeAuthNotifier.new),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Campus Notify'), findsOneWidget);
    expect(find.text('Email Kampus'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk ke Aplikasi'), findsOneWidget);
  });
}
