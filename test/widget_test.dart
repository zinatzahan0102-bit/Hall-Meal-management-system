import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meal_management/main.dart';

void main() {
  testWidgets('Firebase not available screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(firebaseInitialized: false));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
