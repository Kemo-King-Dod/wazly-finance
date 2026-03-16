import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wazly/core/domain/entities/transaction.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/domain/entities/person.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

class ExcelGenerator {
  static Future<String> generateActivityExcel(
    BuildContext ctx,
    List<Transaction> transactions,
    List<Person> people,
    String currencyCode,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Activity Report'];

    final l = AppLocalizations.of(ctx)!;

    // Headers
    sheet.appendRow([
      TextCellValue(l.dateText),
      TextCellValue(l.typeLabel),
      TextCellValue(l.personLabel),
      TextCellValue(l.descriptionText),
      TextCellValue(l.amountText),
      TextCellValue(l.currency),
    ]);

    for (final t in transactions) {
      String typeStr = '';
      switch (t.type) {
        case TransactionType.debt:
          typeStr = l.debt;
          break;
        case TransactionType.payment:
          typeStr = l.payment;
          break;
        case TransactionType.treasuryIn:
          typeStr = l.addedFunds;
          break;
        case TransactionType.treasuryOut:
          typeStr = l.removedFunds;
          break;
      }

      String personName = '-';
      if (t.personId != null) {
        final person = people.where((p) => p.id == t.personId).firstOrNull;
        if (person != null) {
          personName = person.name;
        }
      }

      sheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(t.date)),
        TextCellValue(typeStr),
        TextCellValue(personName),
        TextCellValue(t.description),
        DoubleCellValue(t.amountInCents / 100.0),
        TextCellValue(currencyCode),
      ]);
    }

    final output = await getTemporaryDirectory();
    final String dateString = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${output.path}/Wazly_Activity_$dateString.xlsx');
    
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    
    return file.path;
  }
}
