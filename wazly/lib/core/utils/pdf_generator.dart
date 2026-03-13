import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'; // Add BuildContext
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wazly/core/domain/entities/person.dart';
import 'package:wazly/core/domain/entities/transaction.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/l10n/app_localizations.dart';

extension TransactionPDFExt on Transaction {
  bool isDebtForPerson(String targetPersonId) {
    if (type == TransactionType.debt) {
      return personId == targetPersonId;
    }
    return false;
  }
}

class PdfGenerator {
  static Future<String> generatePersonReport(
    BuildContext ctx,
    Person person,
    List<Transaction> transactions,
    int netBalance,
  ) async {
    final pdf = pw.Document();

    // Load Arabic Font & Logo
    final fontData = await rootBundle.load('assets/fonts/cairo.ttf');
    final ttf = pw.Font.ttf(fontData);

    final logoData = await rootBundle.load('assets/logo/wazlyLogo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final String reportDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Compute Summaries
    int totalDebt = 0;
    int totalPaid = 0;
    for (var tx in transactions) {
      if (tx.isDebtForPerson(person.id)) {
        totalDebt += tx.amountInCents;
      } else {
        totalPaid += tx.amountInCents;
      }
    }

    final String statusText;
    final PdfColor statusColor;
    if (netBalance > 0) {
      statusText = AppLocalizations.of(ctx)!.owesYou;
      statusColor = PdfColors.red;
    } else if (netBalance < 0) {
      statusText = AppLocalizations.of(ctx)!.youOwe;
      statusColor = PdfColors.green;
    } else {
      statusText = AppLocalizations.of(ctx)!.settled;
      statusColor = PdfColors.grey;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: ttf,
        ),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Image(logoImage, width: 40, height: 40),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      AppLocalizations.of(ctx)!.wazlyReport,
                      style: pw.TextStyle(color: PdfColors.blue, fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Text(
                  '${AppLocalizations.of(ctx)!.dateText}: $reportDate',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey),
            pw.SizedBox(height: 10),

            // Person Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      person.name,
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                      textDirection: pw.TextDirection.rtl,
                    ),
                    pw.SizedBox(height: 5),
                    if (person.phoneNumber != null && person.phoneNumber!.isNotEmpty)
                      pw.Text(
                        '${AppLocalizations.of(ctx)!.phoneText}: ${person.phoneNumber}',
                        style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                      )
                    else
                      pw.Text(
                        '${AppLocalizations.of(ctx)!.phoneText}: ${AppLocalizations.of(ctx)!.notProvided}',
                        style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                      ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
                  ),
                  child: pw.Text(
                    statusText,
                    style: pw.TextStyle(color: statusColor, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Summaries
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard(AppLocalizations.of(ctx)!.totalDebt, totalDebt),
                _buildSummaryCard(AppLocalizations.of(ctx)!.totalPaid, totalPaid),
                _buildSummaryCard(AppLocalizations.of(ctx)!.remainingBalance, netBalance.abs()),
              ],
            ),
            pw.SizedBox(height: 30),

            // Transactions Table
            pw.Text(
              AppLocalizations.of(ctx)!.transactionsHistory,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.TableHelper.fromTextArray(
                headers: [
                  AppLocalizations.of(ctx)!.dateText,
                  AppLocalizations.of(ctx)!.typeText,
                  AppLocalizations.of(ctx)!.descriptionText,
                  AppLocalizations.of(ctx)!.amountText
                ],
                data: transactions.map((t) {
                  final isDebt = t.isDebtForPerson(person.id);
                  return [
                    DateFormat('yyyy-MM-dd').format(t.date),
                    isDebt ? AppLocalizations.of(ctx)!.debt : AppLocalizations.of(ctx)!.payment,
                    t.description != null && t.description!.isNotEmpty ? t.description! : '-',
                    (t.amountInCents / 100).toStringAsFixed(0),
                  ];
                }).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
                cellAlignment: pw.Alignment.centerRight,
                cellStyle: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final safeName = person.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\u0600-\u06FF]'), '_');
    final String dateString = DateFormat('yyyyMMdd').format(DateTime.now());
    final file = File('${output.path}/Wazly_Report_${safeName}_$dateString.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static pw.Widget _buildSummaryCard(String title, int cents) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            (cents / 100).toStringAsFixed(2),
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
