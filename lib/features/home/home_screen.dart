import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/reminder_provider.dart';
import '../../services/tray_service.dart';
import '../../services/window_service.dart';
import '../reminder/create_reminder_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_fab.dart';
import 'widgets/reminder_list.dart';
import 'widgets/sidebar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WindowListener {
  late AnimationController _fabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _mainFocusNode = FocusNode();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    // Initialize system tray
    trayService.init();
    // Prevent default close to handle minimize-to-tray
    windowManager.setPreventClose(true);

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _fabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mainFocusNode.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Minimize to tray instead of closing
    await WindowService.minimizeToTray();
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
    final currentView = ref.watch(currentViewProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _showCreateReminderDialog,
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          setState(() => _isSearchActive = true);
          _searchFocusNode.requestFocus();
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          setState(() {
            _isSearchActive = false;
            _searchController.clear();
          });
          _searchFocusNode.unfocus();
          _mainFocusNode.requestFocus();
          ref.read(searchQueryProvider.notifier).state = '';
        },
      },
      child: Focus(
        focusNode: _mainFocusNode,
        autofocus: true,
        child: Scaffold(
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
                child: currentView == AppView.settings
                    ? const SettingsScreen()
                    : Column(
                        children: [
                          // App bar
                          HomeAppBar(
                            isSearchActive: _isSearchActive,
                            searchController: _searchController,
                            searchFocusNode: _searchFocusNode,
                            filter: currentFilter,
                            onSearchToggle: () =>
                                setState(() => _isSearchActive = true),
                            onCloseSearch: () {
                              setState(() => _isSearchActive = false);
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          ),

                          // Reminder list
                          const Expanded(child: ReminderList()),
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: currentView == AppView.reminders
              ? HomeFAB(
                  onPressed: _showCreateReminderDialog,
                  controller: _fabController,
                )
              : null,
        ),
      ),
    );
  }
}
