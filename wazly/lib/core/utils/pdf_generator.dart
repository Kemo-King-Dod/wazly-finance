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
import 'package:wazly/core/utils/app_formatters.dart';

extension TransactionPDFExt on Transaction {
  bool isDebtForPerson(String targetPersonId) {
    if (type == TransactionType.debt) {
      return personId == targetPersonId;
    }
    return false;
  }
}

class PdfGenerator {
  static Future<pw.ThemeData> _getTheme() async {
    final regularData = await rootBundle.load('assets/fonts/Almarai/Almarai-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Almarai/Almarai-Bold.ttf');
    
    return pw.ThemeData.withFont(
      base: pw.Font.ttf(regularData),
      bold: pw.Font.ttf(boldData),
    );
  }

  static Future<pw.MemoryImage> _getLogo() async {
    final logoData = await rootBundle.load('assets/logo/wazlyLogo.png');
    return pw.MemoryImage(logoData.buffer.asUint8List());
  }

  static Future<String> generatePersonReport(
    BuildContext ctx,
    Person person,
    List<Transaction> transactions,
    int netBalance,
    String currencyCode,
  ) async {
    final pdf = pw.Document();
    final theme = await _getTheme();
    final logoImage = await _getLogo();
    final l = AppLocalizations.of(ctx)!;
    final reportDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
      statusText = l.owesYou;
      statusColor = PdfColors.red700;
    } else if (netBalance < 0) {
      statusText = l.youOwe;
      statusColor = PdfColors.green700;
    } else {
      statusText = l.settled;
      statusColor = PdfColors.blueGrey700;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        header: (context) => _buildHeader(l, logoImage, reportDate),
        footer: (context) => _buildFooter(context),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 24),
            
            // Client Details Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        l.personLabel,
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey400, fontWeight: pw.FontWeight.bold),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        person.name,
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Text(
                            person.phoneNumber?.isNotEmpty == true 
                              ? '${l.phoneText}: ${person.phoneNumber}'
                              : '${l.phoneText}: ${l.notProvided}',
                            style: const pw.TextStyle(fontSize: 12, color: PdfColors.blueGrey600),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      l.statusLabel,
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey400, fontWeight: pw.FontWeight.bold),
                      textDirection: pw.TextDirection.rtl,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColor(statusColor.red, statusColor.green, statusColor.blue, 0.1),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                        border: pw.Border.all(color: PdfColor(statusColor.red, statusColor.green, statusColor.blue, 0.2), width: 1),
                      ),
                      child: pw.Text(
                        statusText,
                        style: pw.TextStyle(color: statusColor, fontWeight: pw.FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Summaries
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard(l.totalDebt, (totalDebt / 100).toStringAsFixed(2), PdfColors.red700, currencyCode),
                _buildSummaryCard(l.totalPaid, (totalPaid / 100).toStringAsFixed(2), PdfColors.green700, currencyCode),
                _buildSummaryCard(l.remainingBalance, (netBalance.abs() / 100).toStringAsFixed(2), PdfColors.blue700, currencyCode),
              ],
            ),
            pw.SizedBox(height: 32),

            // Transactions Table
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  l.transactionsHistory,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.Text(
                  '${transactions.length} ${l.items}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey400),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            _buildTransactionTable(ctx, transactions, (t) => t.isDebtForPerson(person.id), totalDebt, totalPaid, netBalance, currencyCode),
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

  static Future<String> generateActivityReport(
    BuildContext ctx,
    List<Transaction> transactions,
    List<Person> people,
    String currencyCode,
  ) async {
    final pdf = pw.Document();
    final theme = await _getTheme();
    final logoImage = await _getLogo();
    final reportDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final l = AppLocalizations.of(ctx)!;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        header: (context) => _buildHeader(l, logoImage, reportDate),
        footer: (context) => _buildFooter(context),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),
            pw.Text(
              l.activityTitle,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 16),
            _buildActivityTable(l, transactions, people, currencyCode),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final String dateString = DateFormat('yyyyMMdd').format(DateTime.now());
    final file = File('${output.path}/Wazly_Activity_$dateString.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static pw.Widget _buildHeader(AppLocalizations l, pw.ImageProvider logo, String date) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                pw.Container(
                  width: 34,
                  height: 34,
                  decoration: pw.BoxDecoration(
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Image(logo),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  'Wazly',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF0D9488), // Wazly Teal
                  ),
                ),
              ],
            ),
            pw.Text(
              '${l.dateText}: $date',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey400),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.blueGrey100, thickness: 1),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey300),
      ),
    );
  }

  static pw.Widget _buildSummaryCard(String title, String value, PdfColor color, String currency) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.05),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.1), width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey400, fontWeight: pw.FontWeight.bold),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color),
              ),
              pw.SizedBox(width: 4),
              pw.Text(
                currency,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionTable(
    BuildContext context,
    List<Transaction> transactions,
    bool Function(Transaction) isDebt, [
    int? totalDebt,
    int? totalPaid,
    int? netBalance,
    String? currencyCode,
  ]) {
    final l = AppLocalizations.of(context)!;

    return pw.Column(
      children: [
        pw.Table(
          border: const pw.TableBorder(
            horizontalInside: pw.BorderSide(color: PdfColors.blueGrey50, width: 0.5),
            bottom: pw.BorderSide(color: PdfColors.blueGrey100, width: 1),
          ),
          columnWidths: {
            0: const pw.FixedColumnWidth(80),
            1: const pw.FlexColumnWidth(2.5),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey50,
                borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
              ),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    l.dateText,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blueGrey700),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    l.descriptionText,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blueGrey700),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    l.amountText,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blueGrey700),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
              ],
            ),
            // Data Rows
            ...transactions.map((t) {
              final isD = isDebt(t);
              final amountSign = t.signedAmountForPerson() > 0 ? '+' : '';
              
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      DateFormat('MMM d').format(t.date),
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey600),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      t.description.isNotEmpty ? t.description : (isD ? l.debt : l.payment),
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey800),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      '$amountSign${AppFormatters.formatAmount(t.signedAmountForPerson() / 100).replaceAll('-', '')}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                        color: t.signedAmountForPerson() > 0 ? PdfColors.green700 : (t.signedAmountForPerson() < 0 ? PdfColors.red700 : PdfColors.blueGrey900),
                      ),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        
        if (totalDebt != null && totalPaid != null && netBalance != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: const pw.BoxDecoration(
              color: PdfColors.white,
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('${l.totalDebt}: ', style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700)),
                    pw.Text(
                      '${AppFormatters.formatAmount(totalDebt / 100)} $currencyCode',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red700),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('${l.totalPaid}: ', style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700)),
                    pw.Text(
                      '${AppFormatters.formatAmount(totalPaid / 100)} $currencyCode',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green700),
                    ),
                  ],
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Divider(color: PdfColors.blueGrey100, thickness: 0.5),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('${l.remainingBalance}: ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                    pw.Text(
                      '${AppFormatters.formatAmount(netBalance.abs() / 100)} $currencyCode',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: netBalance == 0 ? PdfColors.blueGrey900 : (netBalance > 0 ? PdfColors.green700 : PdfColors.red700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildActivityTable(
    AppLocalizations l,
    List<Transaction> transactions,
    List<Person> people,
    String currencyCode,
  ) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.TableHelper.fromTextArray(
        headers: [
          l.dateText,
          l.typeLabel,
          l.personLabel,
          l.descriptionText,
          l.amountText
        ],
        data: transactions.map((t) {
          String typeStr = '';
          switch (t.type) {
            case TransactionType.debt: typeStr = l.debt; break;
            case TransactionType.payment: typeStr = l.payment; break;
            case TransactionType.treasuryIn: typeStr = l.addedFunds; break;
            case TransactionType.treasuryOut: typeStr = l.removedFunds; break;
          }

          String personName = '-';
          if (t.personId != null) {
            final person = people.where((p) => p.id == t.personId).firstOrNull;
            if (person != null) {
              personName = person.name;
            }
          }

          return [
            DateFormat('yyyy-MM-dd HH:mm').format(t.date),
            typeStr,
            personName,
            t.description.isNotEmpty ? t.description : '-',
            '${(t.amountInCents / 100).toStringAsFixed(2)} $currencyCode',
          ];
        }).toList(),
        border: pw.TableBorder(
          horizontalInside: pw.BorderSide(color: PdfColors.blueGrey50, width: 0.5),
          bottom: pw.BorderSide(color: PdfColors.blueGrey50, width: 0.5),
        ),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800, fontSize: 10),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
        cellStyle: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600),
        cellAlignment: pw.Alignment.centerRight,
        headerAlignment: pw.Alignment.centerRight,
        cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      ),
    );
  }
}
