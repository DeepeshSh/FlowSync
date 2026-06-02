import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inventory2/screens/splash_screen.dart';

void main() {
  testWidgets('Splash Screen loads correctly',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.text('Loading...'), findsOneWidget);

    expect(
      find.text(
        'Manage your sanitary business\nsmarter, faster, better.',
      ),
      findsOneWidget,
    );

    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );
  });
}