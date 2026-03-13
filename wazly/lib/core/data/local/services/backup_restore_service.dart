import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazly/core/data/local/database/app_database.dart';
import 'package:wazly/core/data/local/database/data_event_bus.dart';

enum ImportStatus {
  success,
  invalidFormat,
  schemaMismatch,
  checksumInvalid,
  cancelled,
  error,
}

class BackupResult {
  final ImportStatus status;
  final String? filePath;

  const BackupResult(this.status, {this.filePath});
}

class BackupRestoreService {
  final AppDatabase database;
  final DataEventBus eventBus;

  BackupRestoreService({required this.database, required this.eventBus});

  Future<bool> exportBackup() async {
    try {
      // 1. Fetch raw data from Drift
      final persons = await database.select(database.personsTable).get();
      final transactions = await database
          .select(database.transactionsTable)
          .get();
      final treasury = await database.select(database.treasuryTable).get();
      final installments = await database
          .select(database.installmentPlansTable)
          .get();
      final installmentItems = await database
          .select(database.installmentItemsTable)
          .get();

      // 2. Serialize to map
      final dataPayload = {
        'persons': persons.map((e) => e.toJson()).toList(),
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'treasury': treasury.map((e) => e.toJson()).toList(),
        'installment_plans': installments.map((e) => e.toJson()).toList(),
        'installment_items': installmentItems.map((e) => e.toJson()).toList(),
      };

      // 3. Stringify & construct metadata
      final dataString = jsonEncode(dataPayload);
      final checksum = sha256.convert(utf8.encode(dataString)).toString();

      final packageInfo = await PackageInfo.fromPlatform();

      final backupJson = {
        'metadata': {
          'appVersion': packageInfo.version,
          'buildNumber': packageInfo.buildNumber,
          'exportedAt': DateTime.now().toIso8601String(),
          'schemaVersion': 1,
          'checksum': checksum,
        },
        'data': dataPayload,
      };

      final jsonString = jsonEncode(backupJson);
      final jsonBytes = utf8.encode(jsonString);

      // 4. Prompt user to save Native file
      final fileName =
          'wazly_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Wazly Backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(jsonBytes), // Required for Android/iOS
      );

      if (savePath != null) {
        // file_picker saves automatically on Web/Mobile if bytes are provided.
        // On desktop, it just returns the path and we must write manually.
        if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          final file = File(savePath);
          await file.writeAsString(jsonString);
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'last_backup_date',
          DateTime.now().toIso8601String(),
        );
        await prefs.setInt('last_backup_size', jsonBytes.length);

        return true;
      }

      return false; // User cancelled
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  Future<BackupResult> importBackup({
    bool force = false,
    String? filePath,
  }) async {
    try {
      String? targetPath = filePath;

      // 1. Pick file if not supplied
      if (targetPath == null) {
        final result = await FilePicker.platform.pickFiles(
          dialogTitle: 'Select Wazly Backup',
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (result == null || result.files.single.path == null) {
          return const BackupResult(ImportStatus.cancelled);
        }
        targetPath = result.files.single.path!;
      }

      final file = File(targetPath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupJson = jsonDecode(jsonString);

      // Validate Metadata exists
      if (!backupJson.containsKey('metadata') ||
          !backupJson.containsKey('data')) {
        return const BackupResult(ImportStatus.invalidFormat);
      }

      final metadata = backupJson['metadata'] as Map<String, dynamic>;
      final data = backupJson['data'] as Map<String, dynamic>;

      // Validate required tables exist
      if (!data.containsKey('persons') ||
          !data.containsKey('transactions') ||
          !data.containsKey('treasury')) {
        return const BackupResult(ImportStatus.invalidFormat);
      }

      // Checksum
      final checksumStr = metadata['checksum'] as String?;
      if (checksumStr != null && !force) {
        final dataString = jsonEncode(data);
        final generatedChecksum = sha256
            .convert(utf8.encode(dataString))
            .toString();
        if (checksumStr != generatedChecksum) {
          return BackupResult(
            ImportStatus.checksumInvalid,
            filePath: targetPath,
          );
        }
      }

      // Schema Version
      final schemaVersion = metadata['schemaVersion'] as int?;
      if (schemaVersion != 1 && !force) {
        return BackupResult(ImportStatus.schemaMismatch, filePath: targetPath);
      }

      // 2. Parse Drift JSON maps natively (from 'data' map)
      final persons = (data['persons'] as List)
          .map((e) => PersonEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      final transactions = (data['transactions'] as List)
          .map((e) => TransactionEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      final treasury = (data['treasury'] as List)
          .map((e) => TreasuryEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      final installments =
          (data['installment_plans'] as List?)
              ?.map(
                (e) => InstallmentPlanEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [];

      final installmentItems =
          (data['installment_items'] as List?)
              ?.map(
                (e) => InstallmentItemEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [];

      // 3. Destructive Write using transaction isolation
      await database.transaction(() async {
        // A. Clean slate
        await database.delete(database.installmentItemsTable).go();
        await database.delete(database.installmentPlansTable).go();
        await database.delete(database.transactionsTable).go();
        await database.delete(database.personsTable).go();
        await database.delete(database.treasuryTable).go();

        // B. Bulk Insert
        await database.batch((batch) {
          batch.insertAll(database.personsTable, persons);
          batch.insertAll(database.transactionsTable, transactions);
          batch.insertAll(database.treasuryTable, treasury);
          batch.insertAll(database.installmentPlansTable, installments);
          batch.insertAll(database.installmentItemsTable, installmentItems);
        });
      });

      // 4. Force Global BLoC UI Refresh by emitting pure events natively
      eventBus.emit(const DataChangeEvent(DataChangeType.globalReload));

      return const BackupResult(ImportStatus.success);
    } catch (e) {
      debugPrint('Import error: $e');
      return BackupResult(ImportStatus.error, filePath: filePath);
    }
  }
}
