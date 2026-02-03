import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/constants/app_constants.dart';
import '../data/database/app_database.dart';
import '../data/models/reminder.dart';
import '../data/repositories/reminder_repository.dart';
import '../services/scheduler_service.dart';
import 'scheduler_provider.dart';

/// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Repository provider
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ReminderRepository(database);
});

/// Current filter state
final reminderFilterProvider = StateProvider<ReminderFilter>((ref) {
  return ReminderFilter.today;
});

/// Application view state
enum AppView { reminders, settings }

/// Current application view
final currentViewProvider = StateProvider<AppView>((ref) {
  return AppView.reminders;
});

/// All reminders stream
final allRemindersProvider = StreamProvider<List<ReminderModel>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.watchAllReminders();
});

/// Active reminders stream
final activeRemindersProvider = StreamProvider<List<ReminderModel>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.watchActiveReminders();
});

/// Filtered reminders based on current filter
final filteredRemindersProvider = StreamProvider<List<ReminderModel>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final filter = ref.watch(reminderFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return repository.watchRemindersByFilter(filter).map((reminders) {
    if (searchQuery.isEmpty) return reminders;

    return reminders.where((reminder) {
      final nameMatch = reminder.name.toLowerCase().contains(searchQuery);
      final descMatch =
          reminder.description?.toLowerCase().contains(searchQuery) ?? false;
      return nameMatch || descMatch;
    }).toList();
  });
});

/// Today's reminders count
final todayRemindersCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.watchTodayReminders().map((list) => list.length);
});

/// Upcoming reminders count
final upcomingRemindersCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.watchUpcomingReminders().map((list) => list.length);
});

/// Selected reminder for editing
final selectedReminderProvider = StateProvider<ReminderModel?>((ref) {
  return null;
});

/// Sidebar expanded state
final sidebarExpandedProvider = StateProvider<bool>((ref) {
  return true;
});

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Reminder actions notifier
class ReminderActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final ReminderRepository _repository;
  final SchedulerService _schedulerService;

  ReminderActionsNotifier(this._repository, this._schedulerService)
    : super(const AsyncValue.data(null));

  Future<int> createReminder(ReminderModel reminder) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.createReminder(reminder);
      await _schedulerService.refresh();
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateReminder(reminder);
      await _schedulerService.refresh();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteReminder(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteReminder(id);
      await _schedulerService.refresh();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> toggleActive(int id, bool isActive) async {
    try {
      await _repository.toggleReminderActive(id, isActive);
      await _schedulerService.refresh();
    } catch (e) {
      // Silently fail for toggle operations
    }
  }
}

/// Reminder actions provider
final reminderActionsProvider =
    StateNotifierProvider<ReminderActionsNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(reminderRepositoryProvider);
      final scheduler = ref.watch(schedulerServiceProvider);
      return ReminderActionsNotifier(repository, scheduler);
    });
