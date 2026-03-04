import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/data/models/reminder.dart';
import 'package:reminder/services/window_service.dart';

void main() {
  group('WindowService Unit Tests', () {
    test('isAlertWindow returns true for correct args', () {
      final jsonArgs = jsonEncode({'type': 'alert', 'data': 'something'});
      expect(WindowService.isAlertWindow([jsonArgs]), isTrue);
    });

    test('isAlertWindow returns false for mismatch args', () {
      final jsonArgs = jsonEncode({'type': 'summary', 'data': 'something'});
      expect(WindowService.isAlertWindow([jsonArgs]), isFalse);
      expect(WindowService.isAlertWindow([]), isFalse);
    });

    test('isSummaryWindow returns true for correct args', () {
      final jsonArgs = jsonEncode({'type': 'summary', 'data': 'something'});
      expect(WindowService.isSummaryWindow([jsonArgs]), isTrue);
    });

    test('parseAlertWindowArgs correctly parses valid args', () {
      final reminder = ReminderModel(
        id: 1,
        name: 'Test Reminder',
        dateTime: DateTime(2025, 1, 1),
      );

      final jsonArgs = jsonEncode({
        'type': 'alert',
        'data': reminder.toJsonString(),
      });

      final result = WindowService.parseAlertWindowArgs(jsonArgs);
      expect(result, isNotNull);
      expect(result?.id, 1);
      expect(result?.name, 'Test Reminder');
    });

    test('parseAlertWindowArgs returns null for invalid args', () {
      final jsonArgs = jsonEncode({'type': 'summary', 'data': 'something'});

      final result = WindowService.parseAlertWindowArgs(jsonArgs);
      expect(result, isNull);
    });

    test('parseSummaryWindowArgs correctly parses valid args', () {
      final reminder = ReminderModel(
        id: 1,
        name: 'Test Reminder',
        dateTime: DateTime(2025, 1, 1),
      );

      final list = [reminder.toJson()];

      final jsonArgs = jsonEncode({
        'type': 'summary',
        'data': jsonEncode(list),
      });

      final result = WindowService.parseSummaryWindowArgs(jsonArgs);
      expect(result, isNotEmpty);
      expect(result.first.id, 1);
    });

    test('parseSummaryWindowArgs returns empty for invalid args', () {
      final jsonArgs = jsonEncode({'type': 'alert', 'data': 'something'});

      final result = WindowService.parseSummaryWindowArgs(jsonArgs);
      expect(result, isEmpty);
    });
  });
}
