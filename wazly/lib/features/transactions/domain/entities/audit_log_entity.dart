import 'package:equatable/equatable.dart';

/// Entity representing an audit log entry for transaction modifications
class AuditLogEntity extends Equatable {
  final String id;
  final String transactionId;
  final double oldAmount;
  final double newAmount;
  final String reason;
  final DateTime timestamp;

  const AuditLogEntity({
    required this.id,
    required this.transactionId,
    required this.oldAmount,
    required this.newAmount,
    required this.reason,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    transactionId,
    oldAmount,
    newAmount,
    reason,
    timestamp,
  ];
}
