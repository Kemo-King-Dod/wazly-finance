import 'package:hive/hive.dart';
import '../../domain/entities/audit_log_entity.dart';

part 'audit_log_model.g.dart';

@HiveType(typeId: 3)
class AuditLogModel extends AuditLogEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String transactionId;

  @HiveField(2)
  @override
  final double oldAmount;

  @HiveField(3)
  @override
  final double newAmount;

  @HiveField(4)
  @override
  final String reason;

  @HiveField(5)
  @override
  final DateTime timestamp;

  const AuditLogModel({
    required this.id,
    required this.transactionId,
    required this.oldAmount,
    required this.newAmount,
    required this.reason,
    required this.timestamp,
  }) : super(
         id: id,
         transactionId: transactionId,
         oldAmount: oldAmount,
         newAmount: newAmount,
         reason: reason,
         timestamp: timestamp,
       );

  /// Create from entity
  factory AuditLogModel.fromEntity(AuditLogEntity entity) {
    return AuditLogModel(
      id: entity.id,
      transactionId: entity.transactionId,
      oldAmount: entity.oldAmount,
      newAmount: entity.newAmount,
      reason: entity.reason,
      timestamp: entity.timestamp,
    );
  }

  /// Create from JSON
  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String,
      oldAmount: (json['oldAmount'] as num).toDouble(),
      newAmount: (json['newAmount'] as num).toDouble(),
      reason: json['reason'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'oldAmount': oldAmount,
      'newAmount': newAmount,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert to entity
  AuditLogEntity toEntity() {
    return AuditLogEntity(
      id: id,
      transactionId: transactionId,
      oldAmount: oldAmount,
      newAmount: newAmount,
      reason: reason,
      timestamp: timestamp,
    );
  }
}
