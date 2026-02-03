import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class RecurringSelector extends StatefulWidget {
  final RecurringType selectedType;
  final int interval;
  final ValueChanged<RecurringType> onTypeChanged;
  final ValueChanged<int> onIntervalChanged;

  const RecurringSelector({
    super.key,
    required this.selectedType,
    required this.interval,
    required this.onTypeChanged,
    required this.onIntervalChanged,
  });

  @override
  State<RecurringSelector> createState() => _RecurringSelectorState();
}

class _RecurringSelectorState extends State<RecurringSelector> {
  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController(
      text: widget.interval.toString(),
    );
  }

  @override
  void didUpdateWidget(RecurringSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.interval != oldWidget.interval) {
      final text = widget.interval.toString();
      if (_intervalController.text != text) {
        _intervalController.text = text;
        // Keep cursor at end if focused to prevent jumping
        _intervalController.selection = TextSelection.fromPosition(
          TextPosition(offset: _intervalController.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat Every',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // Interval and type selector row
        Row(
          children: [
            // Interval input
            SizedBox(
              width: 100,
              child: TextField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () =>
                            widget.onIntervalChanged(widget.interval + 1),
                        child: Icon(
                          Icons.arrow_drop_up_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (widget.interval > 1) {
                            widget.onIntervalChanged(widget.interval - 1);
                          }
                        },
                        child: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: widget.interval > 1
                              ? colorScheme.primary
                              : colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed > 0) {
                    widget.onIntervalChanged(parsed);
                  }
                },
              ),
            ),

            const SizedBox(width: 16),

            // Type selector
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RecurringType>(
                    value: widget.selectedType,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    items: RecurringType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          widget.interval == 1
                              ? _getSingularLabel(type)
                              : type.label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onTypeChanged(value);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick select chips
        Text(
          'Quick Select',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getQuickSelectOptions(widget.selectedType).map((option) {
            final isSelected = option == widget.interval;
            return FilterChip(
              label: Text(
                '$option ${option == 1 ? _getSingularLabel(widget.selectedType) : widget.selectedType.label.toLowerCase()}',
              ),
              selected: isSelected,
              onSelected: (_) => widget.onIntervalChanged(option),
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Summary text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getSummaryText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSingularLabel(RecurringType type) {
    switch (type) {
      case RecurringType.minutes:
        return 'Minute';
      case RecurringType.hours:
        return 'Hour';
      case RecurringType.days:
        return 'Day';
      case RecurringType.weeks:
        return 'Week';
      case RecurringType.months:
        return 'Month';
    }
  }

  List<int> _getQuickSelectOptions(RecurringType type) {
    return AppConstants.defaultIntervals[type] ?? [1, 2, 3, 5];
  }

  String _getSummaryText() {
    final typeLabel = widget.interval == 1
        ? _getSingularLabel(widget.selectedType).toLowerCase()
        : widget.selectedType.label.toLowerCase();

    if (widget.interval == 1) {
      return 'This reminder will repeat every $typeLabel';
    }
    return 'This reminder will repeat every ${widget.interval} $typeLabel';
  }
}
