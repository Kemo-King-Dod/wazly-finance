import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String id;
  final String name;
  final String? phoneNumber; // Useful for SMS/WhatsApp reminders
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextReminderDate;
  final String? reminderRepeatType;

  Person({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.nextReminderDate,
    this.reminderRepeatType,
  }) {
    validate();
  }

  /// Validates the domain constraints for the person.
  /// Throws [ArgumentError] if the validation fails.
  void validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        createdAt,
        updatedAt,
        nextReminderDate,
        reminderRepeatType,
      ];

  Person copyWith({
    String? id,
    String? name,
    String? Function()? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? Function()? nextReminderDate,
    String? Function()? reminderRepeatType,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber != null ? phoneNumber() : this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextReminderDate: nextReminderDate != null ? nextReminderDate() : this.nextReminderDate,
      reminderRepeatType: reminderRepeatType != null ? reminderRepeatType() : this.reminderRepeatType,
    );
  }
}
