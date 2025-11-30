import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_smart_presence/main.dart';

void main() {
  testWidgets('App launches and displays login screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen is displayed
    expect(find.text('Smart Presence Login'), findsOneWidget);

    // Verify that email and password fields are present
    expect(
      find.byType(TextFormField),
      findsNWidgets(3),
    ); // email, password, role

    // Verify that login button is present
    expect(find.text('Login'), findsOneWidget);

    // Verify that student login button is present
    expect(find.text('Student Login'), findsOneWidget);
  });

  testWidgets('Student can navigate to student login screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap the student login button
    await tester.tap(find.text('Student Login'));
    await tester.pumpAndSettle();

    // Verify that we are on the student login screen
    expect(find.text('Student Login'), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
  });

  testWidgets('User can navigate back from student login', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap the student login button
    await tester.tap(find.text('Student Login'));
    await tester.pumpAndSettle();

    // Tap the back button
    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();

    // Verify that we are back on the main login screen
    expect(find.text('Smart Presence Login'), findsOneWidget);
  });
}
