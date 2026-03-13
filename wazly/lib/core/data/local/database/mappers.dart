import 'package:drift/drift.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/transaction_enums.dart';
import '../../../domain/entities/treasury.dart';
import '../../../domain/entities/installment_plan.dart';
import '../../../domain/entities/installment_item.dart';
import 'app_database.dart';

// --- PERSON MAPPERS ---
extension PersonEntryMapper on PersonEntry {
  Person toDomain() {
    return Person(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nextReminderDate: nextReminderDate,
      reminderRepeatType: reminderRepeatType,
    );
  }
}

extension PersonEntityMapper on Person {
  PersonsTableCompanion toCompanion() {
    return PersonsTableCompanion.insert(
      id: id,
      name: name,
      phoneNumber: Value(phoneNumber),
      createdAt: createdAt,
      updatedAt: updatedAt,
      nextReminderDate: Value(nextReminderDate),
      reminderRepeatType: Value(reminderRepeatType),
    );
  }
}

// --- TRANSACTION MAPPERS ---
extension TransactionEntryMapper on TransactionEntry {
  Transaction toDomain() {
    return Transaction(
      id: id,
      amountInCents: amountInCents,
      type: TransactionType.values.byName(type),
      direction: direction != null
          ? DebtDirection.values.byName(direction!)
          : null,
      description: description,
      date: date,
      personId: personId,
    );
  }
}

extension TransactionEntityMapper on Transaction {
  TransactionsTableCompanion toCompanion() {
    return TransactionsTableCompanion.insert(
      id: id,
      amountInCents: amountInCents,
      type: type.name,
      direction: Value(direction?.name),
      description: description,
      date: date,
      personId: Value(personId),
    );
  }
}

// --- TREASURY MAPPERS ---
extension TreasuryEntryMapper on TreasuryEntry {
  Treasury toDomain() {
    return Treasury(balanceInCents: balanceInCents, currency: currency);
  }
}

extension TreasuryEntityMapper on Treasury {
  TreasuryTableCompanion toCompanion() {
    return TreasuryTableCompanion(
      balanceInCents: Value(balanceInCents),
      currency: Value(currency),
      updatedAt: Value(DateTime.now()),
    );
  }
}

// --- INSTALLMENT PLAN MAPPERS ---
extension InstallmentPlanEntryMapper on InstallmentPlanEntry {
  InstallmentPlan toDomain() {
    return InstallmentPlan(
      id: id,
      personId: personId,
      originalTransactionId: originalTransactionId,
      direction: DebtDirection.values.byName(direction),
      totalAmountInCents: totalAmountInCents,
      title: title,
      createdAt: createdAt,
      isCompleted: isCompleted,
    );
  }
}

extension InstallmentPlanEntityMapper on InstallmentPlan {
  InstallmentPlansTableCompanion toCompanion() {
    return InstallmentPlansTableCompanion.insert(
      id: id,
      personId: personId,
      originalTransactionId: originalTransactionId,
      direction: direction.name,
      totalAmountInCents: totalAmountInCents,
      title: title,
      createdAt: createdAt,
      isCompleted: Value(isCompleted),
    );
  }
}

// --- INSTALLMENT ITEM MAPPERS ---
extension InstallmentItemEntryMapper on InstallmentItemEntry {
  InstallmentItem toDomain() {
    return InstallmentItem(
      id: id,
      planId: planId,
      amountInCents: amountInCents,
      dueDate: dueDate,
      isPaid: isPaid,
      paidDate: paidDate,
      notificationId: notificationId,
    );
  }
}

extension InstallmentItemEntityMapper on InstallmentItem {
  InstallmentItemsTableCompanion toCompanion() {
    return InstallmentItemsTableCompanion.insert(
      id: id,
      planId: planId,
      amountInCents: amountInCents,
      dueDate: dueDate,
      isPaid: Value(isPaid),
      paidDate: Value(paidDate),
      notificationId: Value(notificationId),
    );
  }
}
