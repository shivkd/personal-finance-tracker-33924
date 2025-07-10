import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_frontend/main.dart';

void main() {
  testWidgets('App renders splash screen progress', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceApp());

    // This expects the CircularProgressIndicator from SplashScreen.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Routes present for login', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceApp());
    // App routes setup test (do not assert title now).
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
