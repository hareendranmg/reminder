import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/scheduler_service.dart';
import 'reminder_provider.dart';

/// Scheduler service provider
final schedulerServiceProvider = Provider<SchedulerService>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final service = SchedulerService(repository);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Initialize scheduler when app starts
final schedulerInitProvider = FutureProvider<void>((ref) async {
  final scheduler = ref.watch(schedulerServiceProvider);
  await scheduler.initialize();
});
