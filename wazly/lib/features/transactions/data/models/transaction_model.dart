// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/debt_status.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends TransactionEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final double amount;

  @HiveField(2)
  @override
  final String category;

  @HiveField(3)
  @override
  final DateTime date;

  @HiveField(4)
  @override
  final String description;

  @HiveField(5)
  @override
  final bool isIncome;

  @HiveField(6)
  @override
  final bool isDebt;

  @HiveField(7)
  @override
  final String accountId;

  @HiveField(8)
  @override
  final String? linkedAccountId;

  @HiveField(9)
  @override
  final DebtStatus? debtStatus;

  @HiveField(10)
  @override
  final String? lastModifiedReason;

  @HiveField(11)
  @override
  final DateTime? dueDate;

  @HiveField(12)
  @override
  final bool hasNotification;

  @HiveField(13)
  @override
  final bool isSettled;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isIncome,
    required this.isDebt,
    required this.accountId,
    this.linkedAccountId,
    this.debtStatus,
    this.lastModifiedReason,
    this.dueDate,
    this.hasNotification = false,
    this.isSettled = false,
  }) : super(
         id: id,
         amount: amount,
         category: category,
         date: date,
         description: description,
         isIncome: isIncome,
         isDebt: isDebt,
         accountId: accountId,
         linkedAccountId: linkedAccountId,
         debtStatus: debtStatus,
         lastModifiedReason: lastModifiedReason,
         dueDate: dueDate,
         hasNotification: hasNotification,
         isSettled: isSettled,
       );

  /// Create a TransactionModel from a TransactionEntity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      category: entity.category,
      date: entity.date,
      description: entity.description,
      isIncome: entity.isIncome,
      isDebt: entity.isDebt,
      accountId: entity.accountId,
      linkedAccountId: entity.linkedAccountId,
      debtStatus: entity.debtStatus,
      lastModifiedReason: entity.lastModifiedReason,
      dueDate: entity.dueDate,
      hasNotification: entity.hasNotification,
      isSettled: entity.isSettled,
    );
  }

  /// Create a TransactionModel from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      isIncome: json['isIncome'] as bool,
      isDebt: json['isDebt'] as bool,
      accountId: json['accountId'] as String,
      linkedAccountId: json['linkedAccountId'] as String?,
      debtStatus: json['debtStatus'] != null
          ? DebtStatus.values.byName(json['debtStatus'] as String)
          : null,
      lastModifiedReason: json['lastModifiedReason'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      hasNotification: json['hasNotification'] as bool? ?? false,
      isSettled: json['isSettled'] as bool? ?? false,
    );
  }

  /// Convert TransactionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'isIncome': isIncome,
      'isDebt': isDebt,
      'accountId': accountId,
      'linkedAccountId': linkedAccountId,
      'debtStatus': debtStatus?.name,
      'lastModifiedReason': lastModifiedReason,
      'dueDate': dueDate?.toIso8601String(),
      'hasNotification': hasNotification,
      'isSettled': isSettled,
    };
  }

  /// Convert to TransactionEntity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      category: category,
      date: date,
      description: description,
      isIncome: isIncome,
      isDebt: isDebt,
      accountId: accountId,
      linkedAccountId: linkedAccountId,
      debtStatus: debtStatus,
      lastModifiedReason: lastModifiedReason,
      dueDate: dueDate,
      hasNotification: hasNotification,
      isSettled: isSettled,
    );
  }

  /// Create a copy with modified fields
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    bool? isIncome,
    bool? isDebt,
    String? accountId,
    String? linkedAccountId,
    DebtStatus? debtStatus,
    String? lastModifiedReason,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      isIncome: isIncome ?? this.isIncome,
      isDebt: isDebt ?? this.isDebt,
      accountId: accountId ?? this.accountId,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      debtStatus: debtStatus ?? this.debtStatus,
      lastModifiedReason: lastModifiedReason ?? this.lastModifiedReason,
    );
  }
}

/// Extension for DebtStatus Hive adapter
extension DebtStatusExtension on DebtStatus {
  int toHiveValue() {
    switch (this) {
      case DebtStatus.open:
        return 0;
      case DebtStatus.partial:
        return 1;
      case DebtStatus.settled:
        return 2;
    }
  }

  static DebtStatus fromHiveValue(int value) {
    switch (value) {
      case 0:
        return DebtStatus.open;
      case 1:
        return DebtStatus.partial;
      case 2:
        return DebtStatus.settled;
      default:
        return DebtStatus.open;
    }
  }
}
