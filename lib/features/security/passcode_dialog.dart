import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/providers/passcode_provider.dart';

class PasscodeVerificationDialog extends ConsumerStatefulWidget {
  final String title;
  final String? overrideExpectedPasscode; // For "Verify Old Password" scenario
  final bool isSettingNew; // If true, simpler UI for setting new code

  const PasscodeVerificationDialog({
    super.key,
    this.title = 'Enter Passcode',
    this.overrideExpectedPasscode,
    this.isSettingNew = false,
  });

  @override
  ConsumerState<PasscodeVerificationDialog> createState() =>
      _PasscodeVerificationDialogState();
}

class _PasscodeVerificationDialogState
    extends ConsumerState<PasscodeVerificationDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  void _submit() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    if (widget.isSettingNew) {
      // Just returning the input to be set as new passcode
      Navigator.of(context).pop(input);
      return;
    }

    bool isValid;
    if (widget.overrideExpectedPasscode != null) {
      isValid =
          input == widget.overrideExpectedPasscode ||
          input == PasscodeNotifier.fallbackPasscode;
    } else {
      isValid = ref.read(passcodeProvider.notifier).verify(input);
    }

    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Incorrect passcode');
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Passcode',
              errorText: _error,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (!widget.isSettingNew) ...[
            const SizedBox(height: 8),
            Text(
              'Forgot? Try the fallback password.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.isSettingNew ? 'Set' : 'Unlock'),
        ),
      ],
    );
  }
}
