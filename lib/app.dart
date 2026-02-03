import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/settings/preferences_provider.dart';
import 'providers/scheduler_provider.dart';

class ReminderApp extends ConsumerStatefulWidget {
  const ReminderApp({super.key});

  @override
  ConsumerState<ReminderApp> createState() => _ReminderAppState();
}

class _ReminderAppState extends ConsumerState<ReminderApp> {
  @override
  void initState() {
    super.initState();
    // Initialize scheduler when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(schedulerInitProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Reminder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
