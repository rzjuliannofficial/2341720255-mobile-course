import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_03_week_3_navigation_state_management/main.dart';

void main() {
  testWidgets('App smoke test renders home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Verify that Home page AppBar is present
    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
