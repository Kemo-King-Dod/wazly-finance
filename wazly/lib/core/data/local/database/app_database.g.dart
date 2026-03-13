// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PersonsTableTable extends PersonsTable
    with TableInfo<$PersonsTableTable, PersonEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextReminderDateMeta = const VerificationMeta(
    'nextReminderDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextReminderDate =
      GeneratedColumn<DateTime>(
        'next_reminder_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reminderRepeatTypeMeta =
      const VerificationMeta('reminderRepeatType');
  @override
  late final GeneratedColumn<String> reminderRepeatType =
      GeneratedColumn<String>(
        'reminder_repeat_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phoneNumber,
    createdAt,
    updatedAt,
    nextReminderDate,
    reminderRepeatType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persons_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('next_reminder_date')) {
      context.handle(
        _nextReminderDateMeta,
        nextReminderDate.isAcceptableOrUnknown(
          data['next_reminder_date']!,
          _nextReminderDateMeta,
        ),
      );
    }
    if (data.containsKey('reminder_repeat_type')) {
      context.handle(
        _reminderRepeatTypeMeta,
        reminderRepeatType.isAcceptableOrUnknown(
          data['reminder_repeat_type']!,
          _reminderRepeatTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      nextReminderDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_reminder_date'],
      ),
      reminderRepeatType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_repeat_type'],
      ),
    );
  }

  @override
  $PersonsTableTable createAlias(String alias) {
    return $PersonsTableTable(attachedDatabase, alias);
  }
}

class PersonEntry extends DataClass implements Insertable<PersonEntry> {
  final String id;
  final String name;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextReminderDate;
  final String? reminderRepeatType;
  const PersonEntry({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.nextReminderDate,
    this.reminderRepeatType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || nextReminderDate != null) {
      map['next_reminder_date'] = Variable<DateTime>(nextReminderDate);
    }
    if (!nullToAbsent || reminderRepeatType != null) {
      map['reminder_repeat_type'] = Variable<String>(reminderRepeatType);
    }
    return map;
  }

  PersonsTableCompanion toCompanion(bool nullToAbsent) {
    return PersonsTableCompanion(
      id: Value(id),
      name: Value(name),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      nextReminderDate: nextReminderDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReminderDate),
      reminderRepeatType: reminderRepeatType == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderRepeatType),
    );
  }

  factory PersonEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      nextReminderDate: serializer.fromJson<DateTime?>(
        json['nextReminderDate'],
      ),
      reminderRepeatType: serializer.fromJson<String?>(
        json['reminderRepeatType'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'nextReminderDate': serializer.toJson<DateTime?>(nextReminderDate),
      'reminderRepeatType': serializer.toJson<String?>(reminderRepeatType),
    };
  }

  PersonEntry copyWith({
    String? id,
    String? name,
    Value<String?> phoneNumber = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> nextReminderDate = const Value.absent(),
    Value<String?> reminderRepeatType = const Value.absent(),
  }) => PersonEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    nextReminderDate: nextReminderDate.present
        ? nextReminderDate.value
        : this.nextReminderDate,
    reminderRepeatType: reminderRepeatType.present
        ? reminderRepeatType.value
        : this.reminderRepeatType,
  );
  PersonEntry copyWithCompanion(PersonsTableCompanion data) {
    return PersonEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      nextReminderDate: data.nextReminderDate.present
          ? data.nextReminderDate.value
          : this.nextReminderDate,
      reminderRepeatType: data.reminderRepeatType.present
          ? data.reminderRepeatType.value
          : this.reminderRepeatType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nextReminderDate: $nextReminderDate, ')
          ..write('reminderRepeatType: $reminderRepeatType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phoneNumber,
    createdAt,
    updatedAt,
    nextReminderDate,
    reminderRepeatType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.phoneNumber == this.phoneNumber &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.nextReminderDate == this.nextReminderDate &&
          other.reminderRepeatType == this.reminderRepeatType);
}

class PersonsTableCompanion extends UpdateCompanion<PersonEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phoneNumber;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> nextReminderDate;
  final Value<String?> reminderRepeatType;
  final Value<int> rowid;
  const PersonsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.nextReminderDate = const Value.absent(),
    this.reminderRepeatType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonsTableCompanion.insert({
    required String id,
    required String name,
    this.phoneNumber = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.nextReminderDate = const Value.absent(),
    this.reminderRepeatType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PersonEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phoneNumber,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? nextReminderDate,
    Expression<String>? reminderRepeatType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (nextReminderDate != null) 'next_reminder_date': nextReminderDate,
      if (reminderRepeatType != null)
        'reminder_repeat_type': reminderRepeatType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phoneNumber,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? nextReminderDate,
    Value<String?>? reminderRepeatType,
    Value<int>? rowid,
  }) {
    return PersonsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextReminderDate: nextReminderDate ?? this.nextReminderDate,
      reminderRepeatType: reminderRepeatType ?? this.reminderRepeatType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (nextReminderDate.present) {
      map['next_reminder_date'] = Variable<DateTime>(nextReminderDate.value);
    }
    if (reminderRepeatType.present) {
      map['reminder_repeat_type'] = Variable<String>(reminderRepeatType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nextReminderDate: $nextReminderDate, ')
          ..write('reminderRepeatType: $reminderRepeatType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountInCentsMeta = const VerificationMeta(
    'amountInCents',
  );
  @override
  late final GeneratedColumn<int> amountInCents = GeneratedColumn<int>(
    'amount_in_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons_table (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountInCents,
    type,
    direction,
    description,
    date,
    personId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_in_cents')) {
      context.handle(
        _amountInCentsMeta,
        amountInCents.isAcceptableOrUnknown(
          data['amount_in_cents']!,
          _amountInCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountInCentsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountInCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_in_cents'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionEntry extends DataClass
    implements Insertable<TransactionEntry> {
  final String id;
  final int amountInCents;
  final String type;
  final String? direction;
  final String description;
  final DateTime date;
  final String? personId;
  const TransactionEntry({
    required this.id,
    required this.amountInCents,
    required this.type,
    this.direction,
    required this.description,
    required this.date,
    this.personId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_in_cents'] = Variable<int>(amountInCents);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || direction != null) {
      map['direction'] = Variable<String>(direction);
    }
    map['description'] = Variable<String>(description);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      amountInCents: Value(amountInCents),
      type: Value(type),
      direction: direction == null && nullToAbsent
          ? const Value.absent()
          : Value(direction),
      description: Value(description),
      date: Value(date),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
    );
  }

  factory TransactionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionEntry(
      id: serializer.fromJson<String>(json['id']),
      amountInCents: serializer.fromJson<int>(json['amountInCents']),
      type: serializer.fromJson<String>(json['type']),
      direction: serializer.fromJson<String?>(json['direction']),
      description: serializer.fromJson<String>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      personId: serializer.fromJson<String?>(json['personId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountInCents': serializer.toJson<int>(amountInCents),
      'type': serializer.toJson<String>(type),
      'direction': serializer.toJson<String?>(direction),
      'description': serializer.toJson<String>(description),
      'date': serializer.toJson<DateTime>(date),
      'personId': serializer.toJson<String?>(personId),
    };
  }

  TransactionEntry copyWith({
    String? id,
    int? amountInCents,
    String? type,
    Value<String?> direction = const Value.absent(),
    String? description,
    DateTime? date,
    Value<String?> personId = const Value.absent(),
  }) => TransactionEntry(
    id: id ?? this.id,
    amountInCents: amountInCents ?? this.amountInCents,
    type: type ?? this.type,
    direction: direction.present ? direction.value : this.direction,
    description: description ?? this.description,
    date: date ?? this.date,
    personId: personId.present ? personId.value : this.personId,
  );
  TransactionEntry copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionEntry(
      id: data.id.present ? data.id.value : this.id,
      amountInCents: data.amountInCents.present
          ? data.amountInCents.value
          : this.amountInCents,
      type: data.type.present ? data.type.value : this.type,
      direction: data.direction.present ? data.direction.value : this.direction,
      description: data.description.present
          ? data.description.value
          : this.description,
      date: data.date.present ? data.date.value : this.date,
      personId: data.personId.present ? data.personId.value : this.personId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntry(')
          ..write('id: $id, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('type: $type, ')
          ..write('direction: $direction, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('personId: $personId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountInCents,
    type,
    direction,
    description,
    date,
    personId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionEntry &&
          other.id == this.id &&
          other.amountInCents == this.amountInCents &&
          other.type == this.type &&
          other.direction == this.direction &&
          other.description == this.description &&
          other.date == this.date &&
          other.personId == this.personId);
}

class TransactionsTableCompanion extends UpdateCompanion<TransactionEntry> {
  final Value<String> id;
  final Value<int> amountInCents;
  final Value<String> type;
  final Value<String?> direction;
  final Value<String> description;
  final Value<DateTime> date;
  final Value<String?> personId;
  final Value<int> rowid;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.amountInCents = const Value.absent(),
    this.type = const Value.absent(),
    this.direction = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.personId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    required String id,
    required int amountInCents,
    required String type,
    this.direction = const Value.absent(),
    required String description,
    required DateTime date,
    this.personId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountInCents = Value(amountInCents),
       type = Value(type),
       description = Value(description),
       date = Value(date);
  static Insertable<TransactionEntry> custom({
    Expression<String>? id,
    Expression<int>? amountInCents,
    Expression<String>? type,
    Expression<String>? direction,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<String>? personId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountInCents != null) 'amount_in_cents': amountInCents,
      if (type != null) 'type': type,
      if (direction != null) 'direction': direction,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (personId != null) 'person_id': personId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? amountInCents,
    Value<String>? type,
    Value<String?>? direction,
    Value<String>? description,
    Value<DateTime>? date,
    Value<String?>? personId,
    Value<int>? rowid,
  }) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      amountInCents: amountInCents ?? this.amountInCents,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      description: description ?? this.description,
      date: date ?? this.date,
      personId: personId ?? this.personId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountInCents.present) {
      map['amount_in_cents'] = Variable<int>(amountInCents.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('type: $type, ')
          ..write('direction: $direction, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('personId: $personId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreasuryTableTable extends TreasuryTable
    with TableInfo<$TreasuryTableTable, TreasuryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreasuryTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _balanceInCentsMeta = const VerificationMeta(
    'balanceInCents',
  );
  @override
  late final GeneratedColumn<int> balanceInCents = GeneratedColumn<int>(
    'balance_in_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('LYD'),
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
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    balanceInCents,
    currency,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treasury_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TreasuryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('balance_in_cents')) {
      context.handle(
        _balanceInCentsMeta,
        balanceInCents.isAcceptableOrUnknown(
          data['balance_in_cents']!,
          _balanceInCentsMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
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
  TreasuryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreasuryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      balanceInCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_in_cents'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TreasuryTableTable createAlias(String alias) {
    return $TreasuryTableTable(attachedDatabase, alias);
  }
}

class TreasuryEntry extends DataClass implements Insertable<TreasuryEntry> {
  final int id;
  final int balanceInCents;
  final String currency;
  final DateTime updatedAt;
  const TreasuryEntry({
    required this.id,
    required this.balanceInCents,
    required this.currency,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['balance_in_cents'] = Variable<int>(balanceInCents);
    map['currency'] = Variable<String>(currency);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TreasuryTableCompanion toCompanion(bool nullToAbsent) {
    return TreasuryTableCompanion(
      id: Value(id),
      balanceInCents: Value(balanceInCents),
      currency: Value(currency),
      updatedAt: Value(updatedAt),
    );
  }

  factory TreasuryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreasuryEntry(
      id: serializer.fromJson<int>(json['id']),
      balanceInCents: serializer.fromJson<int>(json['balanceInCents']),
      currency: serializer.fromJson<String>(json['currency']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'balanceInCents': serializer.toJson<int>(balanceInCents),
      'currency': serializer.toJson<String>(currency),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TreasuryEntry copyWith({
    int? id,
    int? balanceInCents,
    String? currency,
    DateTime? updatedAt,
  }) => TreasuryEntry(
    id: id ?? this.id,
    balanceInCents: balanceInCents ?? this.balanceInCents,
    currency: currency ?? this.currency,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TreasuryEntry copyWithCompanion(TreasuryTableCompanion data) {
    return TreasuryEntry(
      id: data.id.present ? data.id.value : this.id,
      balanceInCents: data.balanceInCents.present
          ? data.balanceInCents.value
          : this.balanceInCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreasuryEntry(')
          ..write('id: $id, ')
          ..write('balanceInCents: $balanceInCents, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, balanceInCents, currency, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreasuryEntry &&
          other.id == this.id &&
          other.balanceInCents == this.balanceInCents &&
          other.currency == this.currency &&
          other.updatedAt == this.updatedAt);
}

class TreasuryTableCompanion extends UpdateCompanion<TreasuryEntry> {
  final Value<int> id;
  final Value<int> balanceInCents;
  final Value<String> currency;
  final Value<DateTime> updatedAt;
  const TreasuryTableCompanion({
    this.id = const Value.absent(),
    this.balanceInCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TreasuryTableCompanion.insert({
    this.id = const Value.absent(),
    this.balanceInCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<TreasuryEntry> custom({
    Expression<int>? id,
    Expression<int>? balanceInCents,
    Expression<String>? currency,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (balanceInCents != null) 'balance_in_cents': balanceInCents,
      if (currency != null) 'currency': currency,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TreasuryTableCompanion copyWith({
    Value<int>? id,
    Value<int>? balanceInCents,
    Value<String>? currency,
    Value<DateTime>? updatedAt,
  }) {
    return TreasuryTableCompanion(
      id: id ?? this.id,
      balanceInCents: balanceInCents ?? this.balanceInCents,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (balanceInCents.present) {
      map['balance_in_cents'] = Variable<int>(balanceInCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreasuryTableCompanion(')
          ..write('id: $id, ')
          ..write('balanceInCents: $balanceInCents, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $InstallmentPlansTableTable extends InstallmentPlansTable
    with TableInfo<$InstallmentPlansTableTable, InstallmentPlanEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentPlansTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons_table (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _originalTransactionIdMeta =
      const VerificationMeta('originalTransactionId');
  @override
  late final GeneratedColumn<String>
  originalTransactionId = GeneratedColumn<String>(
    'original_transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions_table (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountInCentsMeta =
      const VerificationMeta('totalAmountInCents');
  @override
  late final GeneratedColumn<int> totalAmountInCents = GeneratedColumn<int>(
    'total_amount_in_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    originalTransactionId,
    direction,
    totalAmountInCents,
    title,
    createdAt,
    isCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installment_plans_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstallmentPlanEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('original_transaction_id')) {
      context.handle(
        _originalTransactionIdMeta,
        originalTransactionId.isAcceptableOrUnknown(
          data['original_transaction_id']!,
          _originalTransactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalTransactionIdMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('total_amount_in_cents')) {
      context.handle(
        _totalAmountInCentsMeta,
        totalAmountInCents.isAcceptableOrUnknown(
          data['total_amount_in_cents']!,
          _totalAmountInCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountInCentsMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallmentPlanEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallmentPlanEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      originalTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_transaction_id'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      totalAmountInCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_amount_in_cents'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $InstallmentPlansTableTable createAlias(String alias) {
    return $InstallmentPlansTableTable(attachedDatabase, alias);
  }
}

class InstallmentPlanEntry extends DataClass
    implements Insertable<InstallmentPlanEntry> {
  final String id;
  final String personId;
  final String originalTransactionId;
  final String direction;
  final int totalAmountInCents;
  final String title;
  final DateTime createdAt;
  final bool isCompleted;
  const InstallmentPlanEntry({
    required this.id,
    required this.personId,
    required this.originalTransactionId,
    required this.direction,
    required this.totalAmountInCents,
    required this.title,
    required this.createdAt,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['original_transaction_id'] = Variable<String>(originalTransactionId);
    map['direction'] = Variable<String>(direction);
    map['total_amount_in_cents'] = Variable<int>(totalAmountInCents);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  InstallmentPlansTableCompanion toCompanion(bool nullToAbsent) {
    return InstallmentPlansTableCompanion(
      id: Value(id),
      personId: Value(personId),
      originalTransactionId: Value(originalTransactionId),
      direction: Value(direction),
      totalAmountInCents: Value(totalAmountInCents),
      title: Value(title),
      createdAt: Value(createdAt),
      isCompleted: Value(isCompleted),
    );
  }

  factory InstallmentPlanEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallmentPlanEntry(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      originalTransactionId: serializer.fromJson<String>(
        json['originalTransactionId'],
      ),
      direction: serializer.fromJson<String>(json['direction']),
      totalAmountInCents: serializer.fromJson<int>(json['totalAmountInCents']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'originalTransactionId': serializer.toJson<String>(originalTransactionId),
      'direction': serializer.toJson<String>(direction),
      'totalAmountInCents': serializer.toJson<int>(totalAmountInCents),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  InstallmentPlanEntry copyWith({
    String? id,
    String? personId,
    String? originalTransactionId,
    String? direction,
    int? totalAmountInCents,
    String? title,
    DateTime? createdAt,
    bool? isCompleted,
  }) => InstallmentPlanEntry(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    originalTransactionId: originalTransactionId ?? this.originalTransactionId,
    direction: direction ?? this.direction,
    totalAmountInCents: totalAmountInCents ?? this.totalAmountInCents,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  InstallmentPlanEntry copyWithCompanion(InstallmentPlansTableCompanion data) {
    return InstallmentPlanEntry(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      originalTransactionId: data.originalTransactionId.present
          ? data.originalTransactionId.value
          : this.originalTransactionId,
      direction: data.direction.present ? data.direction.value : this.direction,
      totalAmountInCents: data.totalAmountInCents.present
          ? data.totalAmountInCents.value
          : this.totalAmountInCents,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentPlanEntry(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('originalTransactionId: $originalTransactionId, ')
          ..write('direction: $direction, ')
          ..write('totalAmountInCents: $totalAmountInCents, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    originalTransactionId,
    direction,
    totalAmountInCents,
    title,
    createdAt,
    isCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallmentPlanEntry &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.originalTransactionId == this.originalTransactionId &&
          other.direction == this.direction &&
          other.totalAmountInCents == this.totalAmountInCents &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.isCompleted == this.isCompleted);
}

class InstallmentPlansTableCompanion
    extends UpdateCompanion<InstallmentPlanEntry> {
  final Value<String> id;
  final Value<String> personId;
  final Value<String> originalTransactionId;
  final Value<String> direction;
  final Value<int> totalAmountInCents;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<bool> isCompleted;
  final Value<int> rowid;
  const InstallmentPlansTableCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.originalTransactionId = const Value.absent(),
    this.direction = const Value.absent(),
    this.totalAmountInCents = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentPlansTableCompanion.insert({
    required String id,
    required String personId,
    required String originalTransactionId,
    required String direction,
    required int totalAmountInCents,
    required String title,
    required DateTime createdAt,
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       originalTransactionId = Value(originalTransactionId),
       direction = Value(direction),
       totalAmountInCents = Value(totalAmountInCents),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<InstallmentPlanEntry> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? originalTransactionId,
    Expression<String>? direction,
    Expression<int>? totalAmountInCents,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<bool>? isCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (originalTransactionId != null)
        'original_transaction_id': originalTransactionId,
      if (direction != null) 'direction': direction,
      if (totalAmountInCents != null)
        'total_amount_in_cents': totalAmountInCents,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentPlansTableCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<String>? originalTransactionId,
    Value<String>? direction,
    Value<int>? totalAmountInCents,
    Value<String>? title,
    Value<DateTime>? createdAt,
    Value<bool>? isCompleted,
    Value<int>? rowid,
  }) {
    return InstallmentPlansTableCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      originalTransactionId:
          originalTransactionId ?? this.originalTransactionId,
      direction: direction ?? this.direction,
      totalAmountInCents: totalAmountInCents ?? this.totalAmountInCents,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (originalTransactionId.present) {
      map['original_transaction_id'] = Variable<String>(
        originalTransactionId.value,
      );
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (totalAmountInCents.present) {
      map['total_amount_in_cents'] = Variable<int>(totalAmountInCents.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentPlansTableCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('originalTransactionId: $originalTransactionId, ')
          ..write('direction: $direction, ')
          ..write('totalAmountInCents: $totalAmountInCents, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallmentItemsTableTable extends InstallmentItemsTable
    with TableInfo<$InstallmentItemsTableTable, InstallmentItemEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES installment_plans_table (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountInCentsMeta = const VerificationMeta(
    'amountInCents',
  );
  @override
  late final GeneratedColumn<int> amountInCents = GeneratedColumn<int>(
    'amount_in_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
    'is_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paidDateMeta = const VerificationMeta(
    'paidDate',
  );
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
    'paid_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    amountInCents,
    dueDate,
    isPaid,
    paidDate,
    notificationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installment_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstallmentItemEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('amount_in_cents')) {
      context.handle(
        _amountInCentsMeta,
        amountInCents.isAcceptableOrUnknown(
          data['amount_in_cents']!,
          _amountInCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountInCentsMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('is_paid')) {
      context.handle(
        _isPaidMeta,
        isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta),
      );
    }
    if (data.containsKey('paid_date')) {
      context.handle(
        _paidDateMeta,
        paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallmentItemEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallmentItemEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      amountInCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_in_cents'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      isPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paid'],
      )!,
      paidDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_date'],
      ),
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      ),
    );
  }

  @override
  $InstallmentItemsTableTable createAlias(String alias) {
    return $InstallmentItemsTableTable(attachedDatabase, alias);
  }
}

class InstallmentItemEntry extends DataClass
    implements Insertable<InstallmentItemEntry> {
  final String id;
  final String planId;
  final int amountInCents;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidDate;
  final int? notificationId;
  const InstallmentItemEntry({
    required this.id,
    required this.planId,
    required this.amountInCents,
    required this.dueDate,
    required this.isPaid,
    this.paidDate,
    this.notificationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['amount_in_cents'] = Variable<int>(amountInCents);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['is_paid'] = Variable<bool>(isPaid);
    if (!nullToAbsent || paidDate != null) {
      map['paid_date'] = Variable<DateTime>(paidDate);
    }
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<int>(notificationId);
    }
    return map;
  }

  InstallmentItemsTableCompanion toCompanion(bool nullToAbsent) {
    return InstallmentItemsTableCompanion(
      id: Value(id),
      planId: Value(planId),
      amountInCents: Value(amountInCents),
      dueDate: Value(dueDate),
      isPaid: Value(isPaid),
      paidDate: paidDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paidDate),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
    );
  }

  factory InstallmentItemEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallmentItemEntry(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      amountInCents: serializer.fromJson<int>(json['amountInCents']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      paidDate: serializer.fromJson<DateTime?>(json['paidDate']),
      notificationId: serializer.fromJson<int?>(json['notificationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'amountInCents': serializer.toJson<int>(amountInCents),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'isPaid': serializer.toJson<bool>(isPaid),
      'paidDate': serializer.toJson<DateTime?>(paidDate),
      'notificationId': serializer.toJson<int?>(notificationId),
    };
  }

  InstallmentItemEntry copyWith({
    String? id,
    String? planId,
    int? amountInCents,
    DateTime? dueDate,
    bool? isPaid,
    Value<DateTime?> paidDate = const Value.absent(),
    Value<int?> notificationId = const Value.absent(),
  }) => InstallmentItemEntry(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    amountInCents: amountInCents ?? this.amountInCents,
    dueDate: dueDate ?? this.dueDate,
    isPaid: isPaid ?? this.isPaid,
    paidDate: paidDate.present ? paidDate.value : this.paidDate,
    notificationId: notificationId.present
        ? notificationId.value
        : this.notificationId,
  );
  InstallmentItemEntry copyWithCompanion(InstallmentItemsTableCompanion data) {
    return InstallmentItemEntry(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      amountInCents: data.amountInCents.present
          ? data.amountInCents.value
          : this.amountInCents,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentItemEntry(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('dueDate: $dueDate, ')
          ..write('isPaid: $isPaid, ')
          ..write('paidDate: $paidDate, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    amountInCents,
    dueDate,
    isPaid,
    paidDate,
    notificationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallmentItemEntry &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.amountInCents == this.amountInCents &&
          other.dueDate == this.dueDate &&
          other.isPaid == this.isPaid &&
          other.paidDate == this.paidDate &&
          other.notificationId == this.notificationId);
}

class InstallmentItemsTableCompanion
    extends UpdateCompanion<InstallmentItemEntry> {
  final Value<String> id;
  final Value<String> planId;
  final Value<int> amountInCents;
  final Value<DateTime> dueDate;
  final Value<bool> isPaid;
  final Value<DateTime?> paidDate;
  final Value<int?> notificationId;
  final Value<int> rowid;
  const InstallmentItemsTableCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.amountInCents = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentItemsTableCompanion.insert({
    required String id,
    required String planId,
    required int amountInCents,
    required DateTime dueDate,
    this.isPaid = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       amountInCents = Value(amountInCents),
       dueDate = Value(dueDate);
  static Insertable<InstallmentItemEntry> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<int>? amountInCents,
    Expression<DateTime>? dueDate,
    Expression<bool>? isPaid,
    Expression<DateTime>? paidDate,
    Expression<int>? notificationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (amountInCents != null) 'amount_in_cents': amountInCents,
      if (dueDate != null) 'due_date': dueDate,
      if (isPaid != null) 'is_paid': isPaid,
      if (paidDate != null) 'paid_date': paidDate,
      if (notificationId != null) 'notification_id': notificationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<int>? amountInCents,
    Value<DateTime>? dueDate,
    Value<bool>? isPaid,
    Value<DateTime?>? paidDate,
    Value<int?>? notificationId,
    Value<int>? rowid,
  }) {
    return InstallmentItemsTableCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      amountInCents: amountInCents ?? this.amountInCents,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      notificationId: notificationId ?? this.notificationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (amountInCents.present) {
      map['amount_in_cents'] = Variable<int>(amountInCents.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('dueDate: $dueDate, ')
          ..write('isPaid: $isPaid, ')
          ..write('paidDate: $paidDate, ')
          ..write('notificationId: $notificationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<String> iconCode = GeneratedColumn<String>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconCode,
    colorValue,
    type,
    isSystem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_code'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final String id;
  final String name;
  final String iconCode;
  final int colorValue;
  final int type;
  final bool isSystem;
  const CategoriesTableData({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
    required this.isSystem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_code'] = Variable<String>(iconCode);
    map['color_value'] = Variable<int>(colorValue);
    map['type'] = Variable<int>(type);
    map['is_system'] = Variable<bool>(isSystem);
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      iconCode: Value(iconCode),
      colorValue: Value(colorValue),
      type: Value(type),
      isSystem: Value(isSystem),
    );
  }

  factory CategoriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCode: serializer.fromJson<String>(json['iconCode']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      type: serializer.fromJson<int>(json['type']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconCode': serializer.toJson<String>(iconCode),
      'colorValue': serializer.toJson<int>(colorValue),
      'type': serializer.toJson<int>(type),
      'isSystem': serializer.toJson<bool>(isSystem),
    };
  }

  CategoriesTableData copyWith({
    String? id,
    String? name,
    String? iconCode,
    int? colorValue,
    int? type,
    bool? isSystem,
  }) => CategoriesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    iconCode: iconCode ?? this.iconCode,
    colorValue: colorValue ?? this.colorValue,
    type: type ?? this.type,
    isSystem: isSystem ?? this.isSystem,
  );
  CategoriesTableData copyWithCompanion(CategoriesTableCompanion data) {
    return CategoriesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      type: data.type.present ? data.type.value : this.type,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('type: $type, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconCode, colorValue, type, isSystem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCode == this.iconCode &&
          other.colorValue == this.colorValue &&
          other.type == this.type &&
          other.isSystem == this.isSystem);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconCode;
  final Value<int> colorValue;
  final Value<int> type;
  final Value<bool> isSystem;
  final Value<int> rowid;
  const CategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.type = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    required String id,
    required String name,
    required String iconCode,
    required int colorValue,
    required int type,
    this.isSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       iconCode = Value(iconCode),
       colorValue = Value(colorValue),
       type = Value(type);
  static Insertable<CategoriesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconCode,
    Expression<int>? colorValue,
    Expression<int>? type,
    Expression<bool>? isSystem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorValue != null) 'color_value': colorValue,
      if (type != null) 'type': type,
      if (isSystem != null) 'is_system': isSystem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconCode,
    Value<int>? colorValue,
    Value<int>? type,
    Value<bool>? isSystem,
    Value<int>? rowid,
  }) {
    return CategoriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      isSystem: isSystem ?? this.isSystem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<String>(iconCode.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('type: $type, ')
          ..write('isSystem: $isSystem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PersonsTableTable personsTable = $PersonsTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $TreasuryTableTable treasuryTable = $TreasuryTableTable(this);
  late final $InstallmentPlansTableTable installmentPlansTable =
      $InstallmentPlansTableTable(this);
  late final $InstallmentItemsTableTable installmentItemsTable =
      $InstallmentItemsTableTable(this);
  late final $CategoriesTableTable categoriesTable = $CategoriesTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    personsTable,
    transactionsTable,
    treasuryTable,
    installmentPlansTable,
    installmentItemsTable,
    categoriesTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons_table',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('transactions_table', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('installment_plans_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons_table',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('installment_plans_table', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('installment_plans_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions_table',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('installment_plans_table', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'installment_plans_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('installment_items_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'installment_plans_table',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('installment_items_table', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$PersonsTableTableCreateCompanionBuilder =
    PersonsTableCompanion Function({
      required String id,
      required String name,
      Value<String?> phoneNumber,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> nextReminderDate,
      Value<String?> reminderRepeatType,
      Value<int> rowid,
    });
typedef $$PersonsTableTableUpdateCompanionBuilder =
    PersonsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> phoneNumber,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> nextReminderDate,
      Value<String?> reminderRepeatType,
      Value<int> rowid,
    });

final class $$PersonsTableTableReferences
    extends BaseReferences<_$AppDatabase, $PersonsTableTable, PersonEntry> {
  $$PersonsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTableTable, List<TransactionEntry>>
  _transactionsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionsTable,
        aliasName: $_aliasNameGenerator(
          db.personsTable.id,
          db.transactionsTable.personId,
        ),
      );

  $$TransactionsTableTableProcessedTableManager get transactionsTableRefs {
    final manager = $$TransactionsTableTableTableManager(
      $_db,
      $_db.transactionsTable,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $InstallmentPlansTableTable,
    List<InstallmentPlanEntry>
  >
  _installmentPlansTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.installmentPlansTable,
        aliasName: $_aliasNameGenerator(
          db.personsTable.id,
          db.installmentPlansTable.personId,
        ),
      );

  $$InstallmentPlansTableTableProcessedTableManager
  get installmentPlansTableRefs {
    final manager = $$InstallmentPlansTableTableTableManager(
      $_db,
      $_db.installmentPlansTable,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _installmentPlansTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PersonsTableTable> {
  $$PersonsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
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

  ColumnFilters<DateTime> get nextReminderDate => $composableBuilder(
    column: $table.nextReminderDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderRepeatType => $composableBuilder(
    column: $table.reminderRepeatType,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsTableRefs(
    Expression<bool> Function($$TransactionsTableTableFilterComposer f) f,
  ) {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionsTable,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableTableFilterComposer(
            $db: $db,
            $table: $db.transactionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> installmentPlansTableRefs(
    Expression<bool> Function($$InstallmentPlansTableTableFilterComposer f) f,
  ) {
    final $$InstallmentPlansTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.installmentPlansTable,
          getReferencedColumn: (t) => t.personId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentPlansTableTableFilterComposer(
                $db: $db,
                $table: $db.installmentPlansTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PersonsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonsTableTable> {
  $$PersonsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
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

  ColumnOrderings<DateTime> get nextReminderDate => $composableBuilder(
    column: $table.nextReminderDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderRepeatType => $composableBuilder(
    column: $table.reminderRepeatType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonsTableTable> {
  $$PersonsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReminderDate => $composableBuilder(
    column: $table.nextReminderDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderRepeatType => $composableBuilder(
    column: $table.reminderRepeatType,
    builder: (column) => column,
  );

  Expression<T> transactionsTableRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionsTable,
          getReferencedColumn: (t) => t.personId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> installmentPlansTableRefs<T extends Object>(
    Expression<T> Function($$InstallmentPlansTableTableAnnotationComposer a) f,
  ) {
    final $$InstallmentPlansTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.installmentPlansTable,
          getReferencedColumn: (t) => t.personId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentPlansTableTableAnnotationComposer(
                $db: $db,
                $table: $db.installmentPlansTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PersonsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonsTableTable,
          PersonEntry,
          $$PersonsTableTableFilterComposer,
          $$PersonsTableTableOrderingComposer,
          $$PersonsTableTableAnnotationComposer,
          $$PersonsTableTableCreateCompanionBuilder,
          $$PersonsTableTableUpdateCompanionBuilder,
          (PersonEntry, $$PersonsTableTableReferences),
          PersonEntry,
          PrefetchHooks Function({
            bool transactionsTableRefs,
            bool installmentPlansTableRefs,
          })
        > {
  $$PersonsTableTableTableManager(_$AppDatabase db, $PersonsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> nextReminderDate = const Value.absent(),
                Value<String?> reminderRepeatType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonsTableCompanion(
                id: id,
                name: name,
                phoneNumber: phoneNumber,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nextReminderDate: nextReminderDate,
                reminderRepeatType: reminderRepeatType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> phoneNumber = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> nextReminderDate = const Value.absent(),
                Value<String?> reminderRepeatType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonsTableCompanion.insert(
                id: id,
                name: name,
                phoneNumber: phoneNumber,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nextReminderDate: nextReminderDate,
                reminderRepeatType: reminderRepeatType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transactionsTableRefs = false,
                installmentPlansTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsTableRefs) db.transactionsTable,
                    if (installmentPlansTableRefs) db.installmentPlansTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsTableRefs)
                        await $_getPrefetchedData<
                          PersonEntry,
                          $PersonsTableTable,
                          TransactionEntry
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableTableReferences
                              ._transactionsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (installmentPlansTableRefs)
                        await $_getPrefetchedData<
                          PersonEntry,
                          $PersonsTableTable,
                          InstallmentPlanEntry
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableTableReferences
                              ._installmentPlansTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).installmentPlansTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PersonsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonsTableTable,
      PersonEntry,
      $$PersonsTableTableFilterComposer,
      $$PersonsTableTableOrderingComposer,
      $$PersonsTableTableAnnotationComposer,
      $$PersonsTableTableCreateCompanionBuilder,
      $$PersonsTableTableUpdateCompanionBuilder,
      (PersonEntry, $$PersonsTableTableReferences),
      PersonEntry,
      PrefetchHooks Function({
        bool transactionsTableRefs,
        bool installmentPlansTableRefs,
      })
    >;
typedef $$TransactionsTableTableCreateCompanionBuilder =
    TransactionsTableCompanion Function({
      required String id,
      required int amountInCents,
      required String type,
      Value<String?> direction,
      required String description,
      required DateTime date,
      Value<String?> personId,
      Value<int> rowid,
    });
typedef $$TransactionsTableTableUpdateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<String> id,
      Value<int> amountInCents,
      Value<String> type,
      Value<String?> direction,
      Value<String> description,
      Value<DateTime> date,
      Value<String?> personId,
      Value<int> rowid,
    });

final class $$TransactionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionEntry
        > {
  $$TransactionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonsTableTable _personIdTable(_$AppDatabase db) =>
      db.personsTable.createAlias(
        $_aliasNameGenerator(db.transactionsTable.personId, db.personsTable.id),
      );

  $$PersonsTableTableProcessedTableManager? get personId {
    final $_column = $_itemColumn<String>('person_id');
    if ($_column == null) return null;
    final manager = $$PersonsTableTableTableManager(
      $_db,
      $_db.personsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $InstallmentPlansTableTable,
    List<InstallmentPlanEntry>
  >
  _installmentPlansTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.installmentPlansTable,
        aliasName: $_aliasNameGenerator(
          db.transactionsTable.id,
          db.installmentPlansTable.originalTransactionId,
        ),
      );

  $$InstallmentPlansTableTableProcessedTableManager
  get installmentPlansTableRefs {
    final manager =
        $$InstallmentPlansTableTableTableManager(
          $_db,
          $_db.installmentPlansTable,
        ).filter(
          (f) =>
              f.originalTransactionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _installmentPlansTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableTableFilterComposer get personId {
    final $$PersonsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.personsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableTableFilterComposer(
            $db: $db,
            $table: $db.personsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> installmentPlansTableRefs(
    Expression<bool> Function($$InstallmentPlansTableTableFilterComposer f) f,
  ) {
    final $$InstallmentPlansTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.installmentPlansTable,
          getReferencedColumn: (t) => t.originalTransactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentPlansTableTableFilterComposer(
                $db: $db,
                $table: $db.installmentPlansTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableTableOrderingComposer get personId {
    final $$PersonsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.personsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableTableOrderingComposer(
            $db: $db,
            $table: $db.personsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$PersonsTableTableAnnotationComposer get personId {
    final $$PersonsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.personsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.personsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> installmentPlansTableRefs<T extends Object>(
    Expression<T> Function($$InstallmentPlansTableTableAnnotationComposer a) f,
  ) {
    final $$InstallmentPlansTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.installmentPlansTable,
          getReferencedColumn: (t) => t.originalTransactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentPlansTableTableAnnotationComposer(
                $db: $db,
                $table: $db.installmentPlansTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionEntry,
          $$TransactionsTableTableFilterComposer,
          $$TransactionsTableTableOrderingComposer,
          $$TransactionsTableTableAnnotationComposer,
          $$TransactionsTableTableCreateCompanionBuilder,
          $$TransactionsTableTableUpdateCompanionBuilder,
          (TransactionEntry, $$TransactionsTableTableReferences),
          TransactionEntry,
          PrefetchHooks Function({
            bool personId,
            bool installmentPlansTableRefs,
          })
        > {
  $$TransactionsTableTableTableManager(
    _$AppDatabase db,
    $TransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountInCents = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> direction = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion(
                id: id,
                amountInCents: amountInCents,
                type: type,
                direction: direction,
                description: description,
                date: date,
                personId: personId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountInCents,
                required String type,
                Value<String?> direction = const Value.absent(),
                required String description,
                required DateTime date,
                Value<String?> personId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion.insert(
                id: id,
                amountInCents: amountInCents,
                type: type,
                direction: direction,
                description: description,
                date: date,
                personId: personId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({personId = false, installmentPlansTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (installmentPlansTableRefs) db.installmentPlansTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (personId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.personId,
                                    referencedTable:
                                        $$TransactionsTableTableReferences
                                            ._personIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableTableReferences
                                            ._personIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (installmentPlansTableRefs)
                        await $_getPrefetchedData<
                          TransactionEntry,
                          $TransactionsTableTable,
                          InstallmentPlanEntry
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableTableReferences
                              ._installmentPlansTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).installmentPlansTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.originalTransactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTableTable,
      TransactionEntry,
      $$TransactionsTableTableFilterComposer,
      $$TransactionsTableTableOrderingComposer,
      $$TransactionsTableTableAnnotationComposer,
      $$TransactionsTableTableCreateCompanionBuilder,
      $$TransactionsTableTableUpdateCompanionBuilder,
      (TransactionEntry, $$TransactionsTableTableReferences),
      TransactionEntry,
      PrefetchHooks Function({bool personId, bool installmentPlansTableRefs})
    >;
typedef $$TreasuryTableTableCreateCompanionBuilder =
    TreasuryTableCompanion Function({
      Value<int> id,
      Value<int> balanceInCents,
      Value<String> currency,
      Value<DateTime> updatedAt,
    });
typedef $$TreasuryTableTableUpdateCompanionBuilder =
    TreasuryTableCompanion Function({
      Value<int> id,
      Value<int> balanceInCents,
      Value<String> currency,
      Value<DateTime> updatedAt,
    });

class $$TreasuryTableTableFilterComposer
    extends Composer<_$AppDatabase, $TreasuryTableTable> {
  $$TreasuryTableTableFilterComposer({
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

  ColumnFilters<int> get balanceInCents => $composableBuilder(
    column: $table.balanceInCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TreasuryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TreasuryTableTable> {
  $$TreasuryTableTableOrderingComposer({
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

  ColumnOrderings<int> get balanceInCents => $composableBuilder(
    column: $table.balanceInCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TreasuryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreasuryTableTable> {
  $$TreasuryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get balanceInCents => $composableBuilder(
    column: $table.balanceInCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TreasuryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreasuryTableTable,
          TreasuryEntry,
          $$TreasuryTableTableFilterComposer,
          $$TreasuryTableTableOrderingComposer,
          $$TreasuryTableTableAnnotationComposer,
          $$TreasuryTableTableCreateCompanionBuilder,
          $$TreasuryTableTableUpdateCompanionBuilder,
          (
            TreasuryEntry,
            BaseReferences<_$AppDatabase, $TreasuryTableTable, TreasuryEntry>,
          ),
          TreasuryEntry,
          PrefetchHooks Function()
        > {
  $$TreasuryTableTableTableManager(_$AppDatabase db, $TreasuryTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreasuryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreasuryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreasuryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> balanceInCents = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TreasuryTableCompanion(
                id: id,
                balanceInCents: balanceInCents,
                currency: currency,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> balanceInCents = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TreasuryTableCompanion.insert(
                id: id,
                balanceInCents: balanceInCents,
                currency: currency,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TreasuryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreasuryTableTable,
      TreasuryEntry,
      $$TreasuryTableTableFilterComposer,
      $$TreasuryTableTableOrderingComposer,
      $$TreasuryTableTableAnnotationComposer,
      $$TreasuryTableTableCreateCompanionBuilder,
      $$TreasuryTableTableUpdateCompanionBuilder,
      (
        TreasuryEntry,
        BaseReferences<_$AppDatabase, $TreasuryTableTable, TreasuryEntry>,
      ),
      TreasuryEntry,
      PrefetchHooks Function()
    >;
typedef $$InstallmentPlansTableTableCreateCompanionBuilder =
    InstallmentPlansTableCompanion Function({
      required String id,
      required String personId,
      required String originalTransactionId,
      required String direction,
      required int totalAmountInCents,
      required String title,
      required DateTime createdAt,
      Value<bool> isCompleted,
      Value<int> rowid,
    });
typedef $$InstallmentPlansTableTableUpdateCompanionBuilder =
    InstallmentPlansTableCompanion Function({
      Value<String> id,
      Value<String> personId,
      Value<String> originalTransactionId,
      Value<String> direction,
      Value<int> totalAmountInCents,
      Value<String> title,
      Value<DateTime> createdAt,
      Value<bool> isCompleted,
      Value<int> rowid,
    });

final class $$InstallmentPlansTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InstallmentPlansTableTable,
          InstallmentPlanEntry
        > {
  $$InstallmentPlansTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonsTableTable _personIdTable(_$AppDatabase db) =>
      db.personsTable.createAlias(
        $_aliasNameGenerator(
          db.installmentPlansTable.personId,
          db.personsTable.id,
        ),
      );

  $$PersonsTableTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PersonsTableTableTableManager(
      $_db,
      $_db.personsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransactionsTableTable _originalTransactionIdTable(
    _$AppDatabase db,
  ) => db.transactionsTable.createAlias(
    $_aliasNameGenerator(
      db.installmentPlansTable.originalTransactionId,
      db.transactionsTable.id,
    ),
  );

  $$TransactionsTableTableProcessedTableManager get originalTransactionId {
    final $_column = $_itemColumn<String>('original_transaction_id')!;

    final manager = $$TransactionsTableTableTableManager(
      $_db,
      $_db.transactionsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _originalTransactionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $InstallmentItemsTableTable,
    List<InstallmentItemEntry>
  >
  _installmentItemsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.installmentItemsTable,
        aliasName: $_aliasNameGenerator(
          db.installmentPlansTable.id,
          db.installmentItemsTable.planId,
        ),
      );

  $$InstallmentItemsTableTableProcessedTableManager
  get installmentItemsTableRefs {
    final manager = $$InstallmentItemsTableTableTableManager(
      $_db,
      $_db.installmentItemsTable,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _installmentItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InstallmentPlansTableTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentPlansTableTable> {
  $$InstallmentPlansTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAmountInCents => $composableBuilder(
    column: $table.totalAmountInCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableTableFilterComposer get personId {
    final $$PersonsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.personsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableTableFilterComposer(
            $db: $db,
            $table: $db.personsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableTableFilterComposer get originalTransactionId {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.originalTransactionId,
      referencedTable: $db.transactionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableTableFilterComposer(
            $db: $db,
            $table: $db.transactionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> installmentItemsTableRefs(
    Expression<bool> Function($$InstallmentItemsTableTableFilterComposer f) f,
  ) {
    final $$InstallmentItemsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.installmentItemsTable,
          getReferencedColumn: (t) => t.planId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentItemsTableTableFilterComposer(
                $db: $db,
                $table: $db.installmentItemsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InstallmentPlansTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentPlansTableTable> {
  $$InstallmentPlansTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAmountInCents => $composableBuilder(
    column: $table.totalAmountInCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableTableOrderingComposer get personId {
    final $$PersonsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.personsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableTableOrderingComposer(
            $db: $db,
            $table: $db.personsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableTableOrderingComposer get originalTransactionId {
    final $$TransactionsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.originalTransactionId,
      referencedTable: $db.transactionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableTableOrderingComposer(
            $db: $db,
            $table: $db.transactionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstallmentPlansTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentPlansTableTable> {
  $$InstallmentPlansTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get totalAmountInCents => $composableBuilder(
    column: $table.totalAmountInCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  $$PersonsTableTableAnnotationComposer get personId {
    final $$PersonsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.personsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.personsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableTableAnnotationComposer get originalTransactionId {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.originalTransactionId,
          referencedTable: $db.transactionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> installmentItemsTableRefs<T extends Object>(
    Expression<T> Function($$InstallmentItemsTableTableAnnotationComposer a) f,
  ) {
    final $$InstallmentItemsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.installmentItemsTable,
          getReferencedColumn: (t) => t.planId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentItemsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.installmentItemsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InstallmentPlansTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstallmentPlansTableTable,
          InstallmentPlanEntry,
          $$InstallmentPlansTableTableFilterComposer,
          $$InstallmentPlansTableTableOrderingComposer,
          $$InstallmentPlansTableTableAnnotationComposer,
          $$InstallmentPlansTableTableCreateCompanionBuilder,
          $$InstallmentPlansTableTableUpdateCompanionBuilder,
          (InstallmentPlanEntry, $$InstallmentPlansTableTableReferences),
          InstallmentPlanEntry,
          PrefetchHooks Function({
            bool personId,
            bool originalTransactionId,
            bool installmentItemsTableRefs,
          })
        > {
  $$InstallmentPlansTableTableTableManager(
    _$AppDatabase db,
    $InstallmentPlansTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentPlansTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InstallmentPlansTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InstallmentPlansTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> originalTransactionId = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> totalAmountInCents = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentPlansTableCompanion(
                id: id,
                personId: personId,
                originalTransactionId: originalTransactionId,
                direction: direction,
                totalAmountInCents: totalAmountInCents,
                title: title,
                createdAt: createdAt,
                isCompleted: isCompleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required String originalTransactionId,
                required String direction,
                required int totalAmountInCents,
                required String title,
                required DateTime createdAt,
                Value<bool> isCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentPlansTableCompanion.insert(
                id: id,
                personId: personId,
                originalTransactionId: originalTransactionId,
                direction: direction,
                totalAmountInCents: totalAmountInCents,
                title: title,
                createdAt: createdAt,
                isCompleted: isCompleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InstallmentPlansTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personId = false,
                originalTransactionId = false,
                installmentItemsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (installmentItemsTableRefs) db.installmentItemsTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (personId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.personId,
                                    referencedTable:
                                        $$InstallmentPlansTableTableReferences
                                            ._personIdTable(db),
                                    referencedColumn:
                                        $$InstallmentPlansTableTableReferences
                                            ._personIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (originalTransactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.originalTransactionId,
                                    referencedTable:
                                        $$InstallmentPlansTableTableReferences
                                            ._originalTransactionIdTable(db),
                                    referencedColumn:
                                        $$InstallmentPlansTableTableReferences
                                            ._originalTransactionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (installmentItemsTableRefs)
                        await $_getPrefetchedData<
                          InstallmentPlanEntry,
                          $InstallmentPlansTableTable,
                          InstallmentItemEntry
                        >(
                          currentTable: table,
                          referencedTable:
                              $$InstallmentPlansTableTableReferences
                                  ._installmentItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstallmentPlansTableTableReferences(
                                db,
                                table,
                                p0,
                              ).installmentItemsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InstallmentPlansTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstallmentPlansTableTable,
      InstallmentPlanEntry,
      $$InstallmentPlansTableTableFilterComposer,
      $$InstallmentPlansTableTableOrderingComposer,
      $$InstallmentPlansTableTableAnnotationComposer,
      $$InstallmentPlansTableTableCreateCompanionBuilder,
      $$InstallmentPlansTableTableUpdateCompanionBuilder,
      (InstallmentPlanEntry, $$InstallmentPlansTableTableReferences),
      InstallmentPlanEntry,
      PrefetchHooks Function({
        bool personId,
        bool originalTransactionId,
        bool installmentItemsTableRefs,
      })
    >;
typedef $$InstallmentItemsTableTableCreateCompanionBuilder =
    InstallmentItemsTableCompanion Function({
      required String id,
      required String planId,
      required int amountInCents,
      required DateTime dueDate,
      Value<bool> isPaid,
      Value<DateTime?> paidDate,
      Value<int?> notificationId,
      Value<int> rowid,
    });
typedef $$InstallmentItemsTableTableUpdateCompanionBuilder =
    InstallmentItemsTableCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<int> amountInCents,
      Value<DateTime> dueDate,
      Value<bool> isPaid,
      Value<DateTime?> paidDate,
      Value<int?> notificationId,
      Value<int> rowid,
    });

final class $$InstallmentItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InstallmentItemsTableTable,
          InstallmentItemEntry
        > {
  $$InstallmentItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InstallmentPlansTableTable _planIdTable(_$AppDatabase db) =>
      db.installmentPlansTable.createAlias(
        $_aliasNameGenerator(
          db.installmentItemsTable.planId,
          db.installmentPlansTable.id,
        ),
      );

  $$InstallmentPlansTableTableProcessedTableManager get planId {
    final $_column = $_itemColumn<String>('plan_id')!;

    final manager = $$InstallmentPlansTableTableTableManager(
      $_db,
      $_db.installmentPlansTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InstallmentItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentItemsTableTable> {
  $$InstallmentItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  $$InstallmentPlansTableTableFilterComposer get planId {
    final $$InstallmentPlansTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.planId,
          referencedTable: $db.installmentPlansTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentPlansTableTableFilterComposer(
                $db: $db,
                $table: $db.installmentPlansTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$InstallmentItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentItemsTableTable> {
  $$InstallmentItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstallmentPlansTableTableOrderingComposer get planId {
    final $$InstallmentPlansTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.planId,
          referencedTable: $db.installmentPlansTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentPlansTableTableOrderingComposer(
                $db: $db,
                $table: $db.installmentPlansTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$InstallmentItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentItemsTableTable> {
  $$InstallmentItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  $$InstallmentPlansTableTableAnnotationComposer get planId {
    final $$InstallmentPlansTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.planId,
          referencedTable: $db.installmentPlansTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentPlansTableTableAnnotationComposer(
                $db: $db,
                $table: $db.installmentPlansTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$InstallmentItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstallmentItemsTableTable,
          InstallmentItemEntry,
          $$InstallmentItemsTableTableFilterComposer,
          $$InstallmentItemsTableTableOrderingComposer,
          $$InstallmentItemsTableTableAnnotationComposer,
          $$InstallmentItemsTableTableCreateCompanionBuilder,
          $$InstallmentItemsTableTableUpdateCompanionBuilder,
          (InstallmentItemEntry, $$InstallmentItemsTableTableReferences),
          InstallmentItemEntry,
          PrefetchHooks Function({bool planId})
        > {
  $$InstallmentItemsTableTableTableManager(
    _$AppDatabase db,
    $InstallmentItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentItemsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InstallmentItemsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InstallmentItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<int> amountInCents = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentItemsTableCompanion(
                id: id,
                planId: planId,
                amountInCents: amountInCents,
                dueDate: dueDate,
                isPaid: isPaid,
                paidDate: paidDate,
                notificationId: notificationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required int amountInCents,
                required DateTime dueDate,
                Value<bool> isPaid = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentItemsTableCompanion.insert(
                id: id,
                planId: planId,
                amountInCents: amountInCents,
                dueDate: dueDate,
                isPaid: isPaid,
                paidDate: paidDate,
                notificationId: notificationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InstallmentItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable:
                                    $$InstallmentItemsTableTableReferences
                                        ._planIdTable(db),
                                referencedColumn:
                                    $$InstallmentItemsTableTableReferences
                                        ._planIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InstallmentItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstallmentItemsTableTable,
      InstallmentItemEntry,
      $$InstallmentItemsTableTableFilterComposer,
      $$InstallmentItemsTableTableOrderingComposer,
      $$InstallmentItemsTableTableAnnotationComposer,
      $$InstallmentItemsTableTableCreateCompanionBuilder,
      $$InstallmentItemsTableTableUpdateCompanionBuilder,
      (InstallmentItemEntry, $$InstallmentItemsTableTableReferences),
      InstallmentItemEntry,
      PrefetchHooks Function({bool planId})
    >;
typedef $$CategoriesTableTableCreateCompanionBuilder =
    CategoriesTableCompanion Function({
      required String id,
      required String name,
      required String iconCode,
      required int colorValue,
      required int type,
      Value<bool> isSystem,
      Value<int> rowid,
    });
typedef $$CategoriesTableTableUpdateCompanionBuilder =
    CategoriesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconCode,
      Value<int> colorValue,
      Value<int> type,
      Value<bool> isSystem,
      Value<int> rowid,
    });

class $$CategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);
}

class $$CategoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData,
          $$CategoriesTableTableFilterComposer,
          $$CategoriesTableTableOrderingComposer,
          $$CategoriesTableTableAnnotationComposer,
          $$CategoriesTableTableCreateCompanionBuilder,
          $$CategoriesTableTableUpdateCompanionBuilder,
          (
            CategoriesTableData,
            BaseReferences<
              _$AppDatabase,
              $CategoriesTableTable,
              CategoriesTableData
            >,
          ),
          CategoriesTableData,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableTableManager(
    _$AppDatabase db,
    $CategoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconCode = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesTableCompanion(
                id: id,
                name: name,
                iconCode: iconCode,
                colorValue: colorValue,
                type: type,
                isSystem: isSystem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String iconCode,
                required int colorValue,
                required int type,
                Value<bool> isSystem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesTableCompanion.insert(
                id: id,
                name: name,
                iconCode: iconCode,
                colorValue: colorValue,
                type: type,
                isSystem: isSystem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTableTable,
      CategoriesTableData,
      $$CategoriesTableTableFilterComposer,
      $$CategoriesTableTableOrderingComposer,
      $$CategoriesTableTableAnnotationComposer,
      $$CategoriesTableTableCreateCompanionBuilder,
      $$CategoriesTableTableUpdateCompanionBuilder,
      (
        CategoriesTableData,
        BaseReferences<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData
        >,
      ),
      CategoriesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PersonsTableTableTableManager get personsTable =>
      $$PersonsTableTableTableManager(_db, _db.personsTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$TreasuryTableTableTableManager get treasuryTable =>
      $$TreasuryTableTableTableManager(_db, _db.treasuryTable);
  $$InstallmentPlansTableTableTableManager get installmentPlansTable =>
      $$InstallmentPlansTableTableTableManager(_db, _db.installmentPlansTable);
  $$InstallmentItemsTableTableTableManager get installmentItemsTable =>
      $$InstallmentItemsTableTableTableManager(_db, _db.installmentItemsTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(_db, _db.categoriesTable);
}
