import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/features/home/home_screen.dart';
import 'package:reminder/features/settings/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('HomeScreen renders sidebar items', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Upcoming'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('HomeScreen shows FAB', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('New Reminder'), findsOneWidget);
  });

  testWidgets('HomeScreen renders search icon', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });
}
