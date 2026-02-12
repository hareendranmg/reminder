import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/reminder_dao.dart';
import 'tables/reminders_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Reminders], daos: [ReminderDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'reminder_db',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(reminders, reminders.isSensitive);
        }
      },
    );
  }
}
