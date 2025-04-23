import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mad_competition/app.dart';
import 'package:mad_competition/main.dart';

void main() {
  testWidgets('Tutor dashboard screen loads with title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Wait for the widget tree to build
    await tester.pumpAndSettle();

    // Look for "Tutor Dashboard" in the app bar
    expect(find.text('Tutor Dashboard'), findsOneWidget);
  });
}
