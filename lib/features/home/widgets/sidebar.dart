import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/reminder_provider.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpanded = ref.watch(sidebarExpandedProvider);
    final currentFilter = ref.watch(reminderFilterProvider);
    final todayCount = ref.watch(todayRemindersCountProvider);
    final upcomingCount = ref.watch(upcomingRemindersCountProvider);

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, ref, isExpanded),

          const SizedBox(height: 8),

          // Filter items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildFilterItem(
                  context,
                  ref,
                  filter: ReminderFilter.all,
                  icon: Icons.inbox_rounded,
                  isSelected: currentFilter == ReminderFilter.all,
                  isExpanded: isExpanded,
                ),
                const SizedBox(height: 4),
                _buildFilterItem(
                  context,
                  ref,
                  filter: ReminderFilter.today,
                  icon: Icons.today_rounded,
                  isSelected: currentFilter == ReminderFilter.today,
                  isExpanded: isExpanded,
                  count: todayCount.value ?? 0,
                ),
                const SizedBox(height: 4),
                _buildFilterItem(
                  context,
                  ref,
                  filter: ReminderFilter.upcoming,
                  icon: Icons.upcoming_rounded,
                  isSelected: currentFilter == ReminderFilter.upcoming,
                  isExpanded: isExpanded,
                  count: upcomingCount.value ?? 0,
                ),
                const SizedBox(height: 4),
                _buildFilterItem(
                  context,
                  ref,
                  filter: ReminderFilter.past,
                  icon: Icons.history_rounded,
                  isSelected: currentFilter == ReminderFilter.past,
                  isExpanded: isExpanded,
                ),
              ],
            ),
          ),

          // Footer
          _buildFooter(context, ref, isExpanded),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isExpanded) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // When collapsed, show only a centered menu button
    if (!isExpanded) {
      return SizedBox(
        height: 64,
        child: Center(
          child: IconButton(
            onPressed: () {
              ref.read(sidebarExpandedProvider.notifier).state = true;
            },
            icon: Icon(Icons.menu_rounded, color: colorScheme.onSurfaceVariant),
            tooltip: 'Expand sidebar',
          ),
        ),
      );
    }

    // When expanded, show full header
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: AppConstants.sidebarWidth - 32,
          child: Row(
            children: [
              // App icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppConstants.appName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Collapse button
              IconButton(
                onPressed: () {
                  ref.read(sidebarExpandedProvider.notifier).state = false;
                },
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Collapse sidebar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterItem(
    BuildContext context,
    WidgetRef ref, {
    required ReminderFilter filter,
    required IconData icon,
    required bool isSelected,
    required bool isExpanded,
    int? count,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconWidget = Icon(
      icon,
      size: 22,
      color: isSelected
          ? colorScheme.onPrimaryContainer
          : colorScheme.onSurfaceVariant,
    );

    // When collapsed, show only centered icon
    if (!isExpanded) {
      return Tooltip(
        message: filter.label,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              ref.read(reminderFilterProvider.notifier).state = filter;
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primaryContainer.withAlpha(179)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: iconWidget),
            ),
          ),
        ),
      );
    }

    // When expanded, show full row
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          ref.read(reminderFilterProvider.notifier).state = filter;
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withAlpha(179)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: AppConstants.sidebarWidth - 32,
              child: Row(
                children: [
                  iconWidget,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      filter.label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (count != null && count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withAlpha(51)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, bool isExpanded) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!isExpanded) {
      return const SizedBox(height: 12);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Divider(color: colorScheme.outlineVariant.withAlpha(77)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: AppConstants.sidebarWidth - 24,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withAlpha(153),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'v${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
