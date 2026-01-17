import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/accounts/data/models/account_model.dart';
import '../../features/transactions/data/models/audit_log_model.dart';

class BackupService {
  static const String _backupFileName = 'wazly_backup.json';

  /// Export all data to a JSON file and share it
  Future<bool> exportBackup() async {
    try {
      final transactionsBox = Hive.box<TransactionModel>('transactions');
      final accountsBox = Hive.box<AccountModel>('accounts');
      final auditLogsBox = Hive.box<AuditLogModel>('audit_logs');
      final settingsBox = Hive.box('settings');

      final data = {
        'transactions': transactionsBox.values.map((t) => t.toJson()).toList(),
        'accounts': accountsBox.values.map((a) => a.toJson()).toList(),
        'audit_logs': auditLogsBox.values.map((l) => l.toJson()).toList(),
        'settings': {
          'locale': settingsBox.get('locale', defaultValue: 'en'),
          'isSecurityEnabled': settingsBox.get(
            'isSecurityEnabled',
            defaultValue: false,
          ),
          'securityType': settingsBox.get('securityType', defaultValue: 'none'),
        },
        'backup_date': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      final jsonString = jsonEncode(data);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$_backupFileName');
      await file.writeAsString(jsonString);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: 'Wazly Backup Data');
      return true;
    } catch (e) {
      // Log or handle error appropriately
      return false;
    }
  }

  /// Import data from a selected JSON file
  Future<bool> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data['version'] == null) throw Exception('Invalid backup file');

      // Clear existing data
      await clearAllData();

      final transactionsBox = Hive.box<TransactionModel>('transactions');
      final accountsBox = Hive.box<AccountModel>('accounts');
      final auditLogsBox = Hive.box<AuditLogModel>('audit_logs');
      final settingsBox = Hive.box('settings');

      // Restore Accounts first (dependencies)
      final accountsData = data['accounts'] as List;
      for (final accountJson in accountsData) {
        final account = AccountModel.fromJson(accountJson);
        await accountsBox.put(account.id, account);
      }

      // Restore Transactions
      final transactionsData = data['transactions'] as List;
      for (final txJson in transactionsData) {
        final tx = TransactionModel.fromJson(txJson);
        await transactionsBox.put(tx.id, tx);
      }

      // Restore Audit Logs
      final logsData = data['audit_logs'] as List;
      for (final logJson in logsData) {
        final log = AuditLogModel.fromJson(logJson);
        await auditLogsBox.put(log.id, log);
      }

      // Restore Settings
      final settingsData = data['settings'] as Map<String, dynamic>;
      await settingsBox.put('locale', settingsData['locale']);
      await settingsBox.put(
        'isSecurityEnabled',
        settingsData['isSecurityEnabled'],
      );
      await settingsBox.put('securityType', settingsData['securityType']);

      return true;
    } catch (e) {
      // Log or handle error appropriately
      return false;
    }
  }

  /// Clear all local data (System Reset)
  Future<void> clearAllData() async {
    await Hive.box<TransactionModel>('transactions').clear();
    await Hive.box<AccountModel>('accounts').clear();
    await Hive.box<AuditLogModel>('audit_logs').clear();
    // Keep settings or reset them too? Usually reset if "Format"
    await Hive.box('settings').clear();
  }
}
