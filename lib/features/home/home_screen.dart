import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/reminder_provider.dart';
import '../reminder/create_reminder_screen.dart';
import 'widgets/reminder_list.dart';
import 'widgets/sidebar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _showCreateReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: const CreateReminderScreen(isDialog: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSidebarExpanded = ref.watch(sidebarExpandedProvider);
    final currentFilter = ref.watch(reminderFilterProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: AppConstants.mediumAnimation,
            curve: Curves.easeInOutCubic,
            width: isSidebarExpanded
                ? AppConstants.sidebarWidth
                : AppConstants.sidebarCollapsedWidth,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: const Sidebar(),
          ),

          // Divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colorScheme.outlineVariant.withAlpha(77),
          ),

          // Main content area
          Expanded(
            child: Column(
              children: [
                // App bar
                _buildAppBar(context, currentFilter),

                // Reminder list
                const Expanded(child: ReminderList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildAppBar(BuildContext context, ReminderFilter filter) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withAlpha(77)),
        ),
      ),
      child: Row(
        children: [
          Text(
            filter.label,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.1, end: 0),
          const Spacer(),
          // Search button
          IconButton(
            onPressed: () {
              // TODO: Implement search
            },
            icon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Search reminders',
          ),
          const SizedBox(width: 8),
          // Settings button
          IconButton(
            onPressed: () {
              // Toggle theme
              ref.read(themeModeProvider.notifier).state = !ref.read(
                themeModeProvider,
              );
            },
            icon: Icon(
              ref.watch(themeModeProvider)
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
          onPressed: _showCreateReminderDialog,
          icon: AnimatedBuilder(
            animation: _fabController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _fabController.value * 0.5,
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              );
            },
          ),
          label: Text(
            'New Reminder',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 2,
          highlightElevation: 4,
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}
