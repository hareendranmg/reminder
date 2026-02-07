# Changelog

All notable changes to the Reminder app are documented here. The project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)-style entries where applicable.

---

## [1.3.0] - 2026-02-07

### Added

- **Single-instance behavior (Linux & Windows)**  
  Only one instance of the app runs per session. Launching again from the app drawer or shortcut brings the existing window to the foreground instead of opening a new process, preventing multiple system tray icons.

### Changed

- Bumped version to 1.3.0 in preparation for upcoming features and improvements.

---

## [1.2.0] - 2026-02-07

### Added

- **Snooze behavior fix for recurring reminders**  
  Recurring reminders now keep their original schedule after snooze. For example: 9:00 AM reminder → snooze 10 min → acknowledge at 9:10 AM → next reminder at 10:00 AM (not 10:10 AM).
- **Explicit next-trigger API**  
  New repository method to set the next trigger time explicitly (used when snoozing recurring reminders so the schedule anchor is preserved).

### Changed

- **Recurring next-occurrence calculation**  
  Next trigger time is always computed from the original schedule anchor (`dateTime`), not from the last trigger or snooze time.
- **Snooze flow for recurring reminders**  
  Snooze now only updates `nextTriggerTime` to the snooze time (e.g. 9:10) instead of going through full reminder update, so acknowledge correctly advances to the next slot (e.g. 10:00).
- **Application icons**  
  Updated app icons; simplified next recurring time calculation in the Reminder model.
- **Windows**  
  Bumped version to 1.2.0, updated Windows app ID, and replaced the Windows app icon with a new `.ico` file.

### Performance

- **Recurring reminder calculation**  
  Optimized `_nextOccurrence` by advancing closer to `baseTime` in one step to avoid excessive loops.

---

## [1.1.0] - 2026-02-05

### Added

- **Dynamic app version in Settings**  
  Version is fetched at runtime and shown in the settings screen via a new provider.
- **Detailed snooze options**  
  Custom time selection for snooze and a snooze confirmation message.
- **Windows support**  
  Windows runner and Flutter application target added.
- **Windows installer**  
  Configuration file for the Windows installer with application details.

### Changed

- App version set to 1.1.0; version displayed dynamically in settings; Windows installer ID updated.
- Removed unused app constants and alert window size configuration.

---

## [1.0.0] - 2026-02-05

### Added

- **Core reminders**  
  Create, edit, and delete one-time and recurring reminders with date/time and recurrence (minutes, hours, days, weeks, months).
- **Alert windows**  
  Non-dismissible alert windows for due reminders (with desktop_multi_window).
- **System tray**  
  Minimize to tray, restore from tray, dynamic “Next reminder” text, and tray_manager integration.
- **Tray actions**  
  “Add Reminder” and “Show Window” from the system tray; “Add Reminder” opens the create-reminder dialog.
- **Alert window UI**  
  Dedicated widgets for alert layout; motivational quotes on the alert screen.
- **Launch at login**  
  Startup service using `launch_at_startup`; re-enable on init to refresh executable path when already enabled.
- **Linux packaging**  
  Debian packaging, app icons, developer info in settings, and `installed_size` in package configuration.
- **Settings**  
  Theme mode, snooze duration, sound setting provider, and developer information.
- **Passcode & sensitive reminders**  
  App passcode protection; option to mark reminders as sensitive; in alert window, sensitive reminders require passcode to view details.
- **Reminder filtering**  
  Filters: All, Today, Upcoming, Past; sidebar filter order; default filter set to Today.
- **Recurring logic**  
  Queries filter/order by `nextTriggerTime` for recurring and `reminderDateTime` for non-recurring.
- **Search**  
  Reminder search with focus nodes and Escape to deactivate and clear.
- **UI/UX**  
  System theme support; reminder list empty states; RecurringSelector as StatefulWidget with interval TextEditingController; autofocus on HomeScreen scaffold; activation toggle hidden for past reminders.
- **Documentation**  
  README with features, installation, usage, and screenshots.

### Changed

- ReminderCard: removed hover effects and direct delete action from the card.
- App description updated to mention Windows support.

### Fixed

- **Startup path**  
  Use `Platform.resolvedExecutable` for correct app path in launch-at-startup setup.
- **Passcode snackbar**  
  Check `context.mounted` before showing snackbar after setting passcode.

### Technical / Refactor

- Alert window UI split into dedicated widgets.

---

## Version mapping (commit reference)

| Version | Release date  | Key commit (version bump / package) |
|--------|----------------|--------------------------------------|
| 1.3.0  | 2026-02-07     | `8c96c63` – Bump version to 1.3.0    |
| 1.2.0  | 2026-02-07     | `c1d5c16` – Bump version to 1.2.0    |
| 1.1.0  | 2026-02-05     | `5212ec8` – Update app version to 1.1.0 |
| 1.0.0  | 2026-02-05     | `b13af8a` – Update Linux debian package to version 1.0.0 |

[1.3.0]: https://github.com/hareendranmg/reminder/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/hareendranmg/reminder/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/hareendranmg/reminder/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/hareendranmg/reminder/releases/tag/v1.0.0
