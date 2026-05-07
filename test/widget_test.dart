// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meal_management/main.dart';

void main() {
  testWidgets('Firebase not available screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(firebaseInitialized: false));

    expect(find.text('Firebase Not Available'), findsOneWidget);
    expect(find.text('Running in offline mode for development.\nSome features may not work.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Continue Anyway'), findsOneWidget);
  });
}
