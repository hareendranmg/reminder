import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../security/passcode_dialog.dart';
import 'preferences_provider.dart';
import 'providers/passcode_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/startup_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final snoozeDuration = ref.watch(snoozeDurationProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withAlpha(77),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance Section
                  Text(
                    'Appearance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withAlpha(77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          title: const Text('System Default'),
                          value: ThemeMode.system,
                          // ignore: deprecated_member_use
                          groupValue: themeMode,
                          // ignore: deprecated_member_use
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(value);
                            }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('Light Mode'),
                          value: ThemeMode.light,
                          // ignore: deprecated_member_use
                          groupValue: themeMode,
                          // ignore: deprecated_member_use
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(value);
                            }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('Dark Mode'),
                          value: ThemeMode.dark,
                          // ignore: deprecated_member_use
                          groupValue: themeMode,
                          // ignore: deprecated_member_use
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Alerts Section
                  Text(
                    'Alerts',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withAlpha(77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Default Snooze Duration'),
                          subtitle: Text('$snoozeDuration minutes'),
                          trailing: DropdownButton<int>(
                            value: snoozeDuration,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(12),
                            items: [5, 10, 15, 30, 60].map((minutes) {
                              return DropdownMenuItem<int>(
                                value: minutes,
                                child: Text('$minutes min'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(snoozeDurationProvider.notifier)
                                    .setDuration(value);
                              }
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        // Placeholder for Sound
                        Consumer(
                          builder: (context, ref, child) {
                            final isSoundEnabled = ref.watch(
                              soundEnabledProvider,
                            );
                            return SwitchListTile(
                              title: const Text('Play Sound'),
                              subtitle: const Text(
                                'Play a sound when reminder triggers',
                              ),
                              value: isSoundEnabled,
                              onChanged: (value) {
                                ref
                                    .read(soundEnabledProvider.notifier)
                                    .setSoundEnabled(value);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // System Section
                  Text(
                    'System',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withAlpha(77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final isEnabled = ref.watch(startupProvider);
                            return SwitchListTile(
                              title: const Text('Launch at login'),
                              subtitle: const Text(
                                'Automatically start the app when you log in',
                              ),
                              value: isEnabled,
                              onChanged: (value) {
                                ref.read(startupProvider.notifier).toggle();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Security Section
                  Text(
                    'Security',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withAlpha(77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final passcode = ref.watch(passcodeProvider);
                        final hasPasscode = passcode != null;

                        return ListTile(
                          title: Text(
                            hasPasscode ? 'Change Passcode' : 'Set Passcode',
                          ),
                          subtitle: Text(
                            hasPasscode
                                ? 'Update your security passcode'
                                : 'Protect sensitive reminders',
                          ),
                          leading: const Icon(Icons.lock_outline_rounded),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () async {
                            if (hasPasscode) {
                              // Verify old passcode first
                              final verified = await showDialog<bool>(
                                context: context,
                                builder: (context) =>
                                    const PasscodeVerificationDialog(
                                      title: 'Verify Old Passcode',
                                    ),
                              );

                              if (verified != true) return;
                            }

                            if (!context.mounted) return;

                            // Set new passcode
                            final newPasscode = await showDialog<String>(
                              context: context,
                              builder: (context) => PasscodeVerificationDialog(
                                title: hasPasscode
                                    ? 'Enter New Passcode'
                                    : 'Set Passcode',
                                isSettingNew: true,
                              ),
                            );

                            if (newPasscode != null &&
                                newPasscode.isNotEmpty &&
                                context.mounted) {
                              await ref
                                  .read(passcodeProvider.notifier)
                                  .setPasscode(newPasscode);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Passcode updated successfully',
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // About Section
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withAlpha(77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const ListTile(
                          title: Text('Reminder'),
                          subtitle: Text('Version 1.0.0'),
                          leading: Icon(Icons.info_outline_rounded),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Hareendran MG'),
                          subtitle: const Text(
                            "Architect of questionable decisions.",
                          ),
                          leading: const Icon(Icons.person_rounded),
                          onTap: () =>
                              launchUrl(Uri.parse('https://hareendranmg.com')),
                        ),
                      ],
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
