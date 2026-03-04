import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reminder/features/settings/providers/startup_provider.dart';
import 'package:reminder/services/startup_service.dart';

class MockStartupService extends Mock implements StartupService {}

/// Helper to wait until the provider state changes or a timeout.
Future<void> waitForState(
  ProviderContainer container, {
  required bool expected,
  Duration timeout = const Duration(seconds: 2),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    if (container.read(startupProvider) == expected) return;
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  group('StartupNotifier', () {
    late MockStartupService mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = MockStartupService();
    });

    tearDown(() => container.dispose());

    test('initializes with false and calls isEnabled', () async {
      when(() => mockService.isEnabled()).thenAnswer((_) async => false);

      container = ProviderContainer(
        overrides: [startupServiceProvider.overrideWithValue(mockService)],
      );

      expect(container.read(startupProvider), false);
      await waitForState(container, expected: false);
      verify(() => mockService.isEnabled()).called(1);
    });

    test('init sets state to true when isEnabled returns true', () async {
      when(() => mockService.isEnabled()).thenAnswer((_) async => true);

      container = ProviderContainer(
        overrides: [startupServiceProvider.overrideWithValue(mockService)],
      );

      await waitForState(container, expected: true);
      expect(container.read(startupProvider), true);
    });

    test('init handles error gracefully', () async {
      when(
        () => mockService.isEnabled(),
      ).thenThrow(UnsupportedError('Not supported'));

      container = ProviderContainer(
        overrides: [startupServiceProvider.overrideWithValue(mockService)],
      );

      await waitForState(container, expected: false);
      expect(container.read(startupProvider), false);
    });

    test('toggle calls service.toggle and updates state', () async {
      when(() => mockService.isEnabled()).thenAnswer((_) async => false);
      when(() => mockService.toggle()).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [startupServiceProvider.overrideWithValue(mockService)],
      );

      await waitForState(container, expected: false);

      // After toggle, isEnabled returns true
      when(() => mockService.isEnabled()).thenAnswer((_) async => true);

      await container.read(startupProvider.notifier).toggle();
      expect(container.read(startupProvider), true);
      verify(() => mockService.toggle()).called(1);
    });

    test('toggle handles error gracefully', () async {
      when(() => mockService.isEnabled()).thenAnswer((_) async => false);
      when(
        () => mockService.toggle(),
      ).thenThrow(UnsupportedError('Not supported'));

      container = ProviderContainer(
        overrides: [startupServiceProvider.overrideWithValue(mockService)],
      );

      await waitForState(container, expected: false);
      await container.read(startupProvider.notifier).toggle();
      expect(container.read(startupProvider), false);
    });
  });
}
