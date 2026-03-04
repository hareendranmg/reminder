import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reminder/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App E2E Test - Boot, Navigate, and Validate', (tester) async {
    // Start the app
    await app.main([]);

    // Wait for app to render and settle
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify Main Window loaded "Today"
    expect(find.text('Today'), findsOneWidget);

    // Navigate to Settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify Settings page loaded
    expect(find.text('General'), findsOneWidget);

    // Toggle Sound Notification
    final switchFinder = find.byType(Switch).first;
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Navigate back to Today
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    // Open Add Reminder Bottom Sheet or Dialog
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Enter a title
      await tester.enterText(find.byType(TextField).first, 'E2E Test Reminder');

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Check if it appears in the list
      expect(find.text('E2E Test Reminder'), findsWidgets);
    }
  });
}
