// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isSensitiveMeta = const VerificationMeta(
    'isSensitive',
  );
  @override
  late final GeneratedColumn<bool> isSensitive = GeneratedColumn<bool>(
    'is_sensitive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sensitive" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _reminderDateTimeMeta = const VerificationMeta(
    'reminderDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> reminderDateTime =
      GeneratedColumn<DateTime>(
        'reminder_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recurringTypeMeta = const VerificationMeta(
    'recurringType',
  );
  @override
  late final GeneratedColumn<String> recurringType = GeneratedColumn<String>(
    'recurring_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringIntervalMeta = const VerificationMeta(
    'recurringInterval',
  );
  @override
  late final GeneratedColumn<int> recurringInterval = GeneratedColumn<int>(
    'recurring_interval',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextTriggerTimeMeta = const VerificationMeta(
    'nextTriggerTime',
  );
  @override
  late final GeneratedColumn<DateTime> nextTriggerTime =
      GeneratedColumn<DateTime>(
        'next_trigger_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    isRecurring,
    isSensitive,
    reminderDateTime,
    recurringType,
    recurringInterval,
    nextTriggerTime,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('is_sensitive')) {
      context.handle(
        _isSensitiveMeta,
        isSensitive.isAcceptableOrUnknown(
          data['is_sensitive']!,
          _isSensitiveMeta,
        ),
      );
    }
    if (data.containsKey('reminder_date_time')) {
      context.handle(
        _reminderDateTimeMeta,
        reminderDateTime.isAcceptableOrUnknown(
          data['reminder_date_time']!,
          _reminderDateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderDateTimeMeta);
    }
    if (data.containsKey('recurring_type')) {
      context.handle(
        _recurringTypeMeta,
        recurringType.isAcceptableOrUnknown(
          data['recurring_type']!,
          _recurringTypeMeta,
        ),
      );
    }
    if (data.containsKey('recurring_interval')) {
      context.handle(
        _recurringIntervalMeta,
        recurringInterval.isAcceptableOrUnknown(
          data['recurring_interval']!,
          _recurringIntervalMeta,
        ),
      );
    }
    if (data.containsKey('next_trigger_time')) {
      context.handle(
        _nextTriggerTimeMeta,
        nextTriggerTime.isAcceptableOrUnknown(
          data['next_trigger_time']!,
          _nextTriggerTimeMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      isSensitive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sensitive'],
      )!,
      reminderDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_date_time'],
      )!,
      recurringType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_type'],
      ),
      recurringInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_interval'],
      ),
      nextTriggerTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_trigger_time'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  /// Unique identifier
  final int id;

  /// Reminder name/title
  final String name;

  /// Optional description
  final String? description;

  /// Whether this is a recurring reminder
  final bool isRecurring;

  /// Whether this reminder is sensitive (requires passcode)
  final bool isSensitive;

  /// The date and time for the reminder (or start time for recurring)
  final DateTime reminderDateTime;

  /// Type of recurrence (minutes, hours, days, weeks, months)
  /// Stored as string enum name
  final String? recurringType;

  /// Interval for recurrence (e.g., every 2 hours)
  final int? recurringInterval;

  /// Next scheduled time for recurring reminders
  final DateTime? nextTriggerTime;

  /// Whether the reminder is active
  final bool isActive;

  /// When the reminder was created
  final DateTime createdAt;

  /// When the reminder was last modified
  final DateTime updatedAt;
  const Reminder({
    required this.id,
    required this.name,
    this.description,
    required this.isRecurring,
    required this.isSensitive,
    required this.reminderDateTime,
    this.recurringType,
    this.recurringInterval,
    this.nextTriggerTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    map['is_sensitive'] = Variable<bool>(isSensitive);
    map['reminder_date_time'] = Variable<DateTime>(reminderDateTime);
    if (!nullToAbsent || recurringType != null) {
      map['recurring_type'] = Variable<String>(recurringType);
    }
    if (!nullToAbsent || recurringInterval != null) {
      map['recurring_interval'] = Variable<int>(recurringInterval);
    }
    if (!nullToAbsent || nextTriggerTime != null) {
      map['next_trigger_time'] = Variable<DateTime>(nextTriggerTime);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isRecurring: Value(isRecurring),
      isSensitive: Value(isSensitive),
      reminderDateTime: Value(reminderDateTime),
      recurringType: recurringType == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringType),
      recurringInterval: recurringInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringInterval),
      nextTriggerTime: nextTriggerTime == null && nullToAbsent
          ? const Value.absent()
          : Value(nextTriggerTime),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      isSensitive: serializer.fromJson<bool>(json['isSensitive']),
      reminderDateTime: serializer.fromJson<DateTime>(json['reminderDateTime']),
      recurringType: serializer.fromJson<String?>(json['recurringType']),
      recurringInterval: serializer.fromJson<int?>(json['recurringInterval']),
      nextTriggerTime: serializer.fromJson<DateTime?>(json['nextTriggerTime']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'isSensitive': serializer.toJson<bool>(isSensitive),
      'reminderDateTime': serializer.toJson<DateTime>(reminderDateTime),
      'recurringType': serializer.toJson<String?>(recurringType),
      'recurringInterval': serializer.toJson<int?>(recurringInterval),
      'nextTriggerTime': serializer.toJson<DateTime?>(nextTriggerTime),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Reminder copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isRecurring,
    bool? isSensitive,
    DateTime? reminderDateTime,
    Value<String?> recurringType = const Value.absent(),
    Value<int?> recurringInterval = const Value.absent(),
    Value<DateTime?> nextTriggerTime = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Reminder(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isRecurring: isRecurring ?? this.isRecurring,
    isSensitive: isSensitive ?? this.isSensitive,
    reminderDateTime: reminderDateTime ?? this.reminderDateTime,
    recurringType: recurringType.present
        ? recurringType.value
        : this.recurringType,
    recurringInterval: recurringInterval.present
        ? recurringInterval.value
        : this.recurringInterval,
    nextTriggerTime: nextTriggerTime.present
        ? nextTriggerTime.value
        : this.nextTriggerTime,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      isSensitive: data.isSensitive.present
          ? data.isSensitive.value
          : this.isSensitive,
      reminderDateTime: data.reminderDateTime.present
          ? data.reminderDateTime.value
          : this.reminderDateTime,
      recurringType: data.recurringType.present
          ? data.recurringType.value
          : this.recurringType,
      recurringInterval: data.recurringInterval.present
          ? data.recurringInterval.value
          : this.recurringInterval,
      nextTriggerTime: data.nextTriggerTime.present
          ? data.nextTriggerTime.value
          : this.nextTriggerTime,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('isSensitive: $isSensitive, ')
          ..write('reminderDateTime: $reminderDateTime, ')
          ..write('recurringType: $recurringType, ')
          ..write('recurringInterval: $recurringInterval, ')
          ..write('nextTriggerTime: $nextTriggerTime, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    isRecurring,
    isSensitive,
    reminderDateTime,
    recurringType,
    recurringInterval,
    nextTriggerTime,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.isRecurring == this.isRecurring &&
          other.isSensitive == this.isSensitive &&
          other.reminderDateTime == this.reminderDateTime &&
          other.recurringType == this.recurringType &&
          other.recurringInterval == this.recurringInterval &&
          other.nextTriggerTime == this.nextTriggerTime &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isRecurring;
  final Value<bool> isSensitive;
  final Value<DateTime> reminderDateTime;
  final Value<String?> recurringType;
  final Value<int?> recurringInterval;
  final Value<DateTime?> nextTriggerTime;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.isSensitive = const Value.absent(),
    this.reminderDateTime = const Value.absent(),
    this.recurringType = const Value.absent(),
    this.recurringInterval = const Value.absent(),
    this.nextTriggerTime = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.isSensitive = const Value.absent(),
    required DateTime reminderDateTime,
    this.recurringType = const Value.absent(),
    this.recurringInterval = const Value.absent(),
    this.nextTriggerTime = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       reminderDateTime = Value(reminderDateTime);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isRecurring,
    Expression<bool>? isSensitive,
    Expression<DateTime>? reminderDateTime,
    Expression<String>? recurringType,
    Expression<int>? recurringInterval,
    Expression<DateTime>? nextTriggerTime,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (isSensitive != null) 'is_sensitive': isSensitive,
      if (reminderDateTime != null) 'reminder_date_time': reminderDateTime,
      if (recurringType != null) 'recurring_type': recurringType,
      if (recurringInterval != null) 'recurring_interval': recurringInterval,
      if (nextTriggerTime != null) 'next_trigger_time': nextTriggerTime,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isRecurring,
    Value<bool>? isSensitive,
    Value<DateTime>? reminderDateTime,
    Value<String?>? recurringType,
    Value<int?>? recurringInterval,
    Value<DateTime?>? nextTriggerTime,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      isSensitive: isSensitive ?? this.isSensitive,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      recurringType: recurringType ?? this.recurringType,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      nextTriggerTime: nextTriggerTime ?? this.nextTriggerTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (isSensitive.present) {
      map['is_sensitive'] = Variable<bool>(isSensitive.value);
    }
    if (reminderDateTime.present) {
      map['reminder_date_time'] = Variable<DateTime>(reminderDateTime.value);
    }
    if (recurringType.present) {
      map['recurring_type'] = Variable<String>(recurringType.value);
    }
    if (recurringInterval.present) {
      map['recurring_interval'] = Variable<int>(recurringInterval.value);
    }
    if (nextTriggerTime.present) {
      map['next_trigger_time'] = Variable<DateTime>(nextTriggerTime.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('isSensitive: $isSensitive, ')
          ..write('reminderDateTime: $reminderDateTime, ')
          ..write('recurringType: $recurringType, ')
          ..write('recurringInterval: $recurringInterval, ')
          ..write('nextTriggerTime: $nextTriggerTime, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final ReminderDao reminderDao = ReminderDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [reminders];
}

typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<bool> isRecurring,
      Value<bool> isSensitive,
      required DateTime reminderDateTime,
      Value<String?> recurringType,
      Value<int?> recurringInterval,
      Value<DateTime?> nextTriggerTime,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<bool> isRecurring,
      Value<bool> isSensitive,
      Value<DateTime> reminderDateTime,
      Value<String?> recurringType,
      Value<int?> recurringInterval,
      Value<DateTime?> nextTriggerTime,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSensitive => $composableBuilder(
    column: $table.isSensitive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderDateTime => $composableBuilder(
    column: $table.reminderDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringType => $composableBuilder(
    column: $table.recurringType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurringInterval => $composableBuilder(
    column: $table.recurringInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextTriggerTime => $composableBuilder(
    column: $table.nextTriggerTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSensitive => $composableBuilder(
    column: $table.isSensitive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderDateTime => $composableBuilder(
    column: $table.reminderDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringType => $composableBuilder(
    column: $table.recurringType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurringInterval => $composableBuilder(
    column: $table.recurringInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextTriggerTime => $composableBuilder(
    column: $table.nextTriggerTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSensitive => $composableBuilder(
    column: $table.isSensitive,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reminderDateTime => $composableBuilder(
    column: $table.reminderDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringType => $composableBuilder(
    column: $table.recurringType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurringInterval => $composableBuilder(
    column: $table.recurringInterval,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextTriggerTime => $composableBuilder(
    column: $table.nextTriggerTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
          Reminder,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<bool> isSensitive = const Value.absent(),
                Value<DateTime> reminderDateTime = const Value.absent(),
                Value<String?> recurringType = const Value.absent(),
                Value<int?> recurringInterval = const Value.absent(),
                Value<DateTime?> nextTriggerTime = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                name: name,
                description: description,
                isRecurring: isRecurring,
                isSensitive: isSensitive,
                reminderDateTime: reminderDateTime,
                recurringType: recurringType,
                recurringInterval: recurringInterval,
                nextTriggerTime: nextTriggerTime,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<bool> isSensitive = const Value.absent(),
                required DateTime reminderDateTime,
                Value<String?> recurringType = const Value.absent(),
                Value<int?> recurringInterval = const Value.absent(),
                Value<DateTime?> nextTriggerTime = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                name: name,
                description: description,
                isRecurring: isRecurring,
                isSensitive: isSensitive,
                reminderDateTime: reminderDateTime,
                recurringType: recurringType,
                recurringInterval: recurringInterval,
                nextTriggerTime: nextTriggerTime,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
      Reminder,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
