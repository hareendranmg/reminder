import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/reminder_provider.dart';

class HomeAppBar extends ConsumerWidget {
  final bool isSearchActive;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ReminderFilter filter;
  final VoidCallback onSearchToggle;
  final VoidCallback onCloseSearch;

  const HomeAppBar({
    super.key,
    required this.isSearchActive,
    required this.searchController,
    required this.searchFocusNode,
    required this.filter,
    required this.onSearchToggle,
    required this.onCloseSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          if (isSearchActive)
            Expanded(
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search reminders...',
                  border: InputBorder.none,
                  filled: false,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ).animate().fadeIn(duration: 200.ms),
            )
          else
            Text(
              filter.label,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.1, end: 0),

          const Spacer(),

          if (isSearchActive)
            IconButton(
              onPressed: onCloseSearch,
              icon: Icon(
                Icons.close_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Close search',
            )
          else
            IconButton(
              onPressed: onSearchToggle,
              icon: Icon(
                Icons.search_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Search reminders',
            ),
        ],
      ),
    );
  }
}
