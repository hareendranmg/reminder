import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/features/home/widgets/sidebar.dart';
import 'package:reminder/features/settings/preferences_provider.dart';
import 'package:reminder/providers/reminder_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUpAll(() {
    // Suppress drift multiple database warnings in tests
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget({bool expanded = true}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sidebarExpandedProvider.overrideWith((ref) => expanded),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: Row(children: [Expanded(child: Sidebar())]),
        ),
      ),
    );
  }

  testWidgets('Sidebar renders filter items when expanded', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Upcoming'), findsWidgets);
    expect(find.text('Past'), findsWidgets);
    expect(find.text('All Reminders'), findsWidgets);
  });

  testWidgets('Sidebar renders Settings text in footer', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Sidebar renders filter icons', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.today_rounded), findsOneWidget);
    expect(find.byIcon(Icons.upcoming_rounded), findsOneWidget);
    expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
  });

  testWidgets('Tapping filter item does not crash', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('All Reminders'));
    await tester.pump(const Duration(milliseconds: 300));
    // No crash = success
  });
}
