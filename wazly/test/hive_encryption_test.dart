import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    final directory = Directory.systemTemp.createTempSync();
    Hive.init(directory.path);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('Hive box saves data securely using AES encryption', () async {
    // 1. Generate a secure key and cipher
    final secureKey = Hive.generateSecureKey();
    final encryptionKey = Uint8List.fromList(secureKey);
    final cipher = HiveAesCipher(encryptionKey);

    // 2. Open an encrypted box
    const boxName = 'secure_test_box';
    final box = await Hive.openBox<String>(boxName, encryptionCipher: cipher);

    // 3. Write plain text sensitive data
    const plainTextData = 'SUPER_SECRET_FINANCIAL_RECORD_12345';
    await box.put('secret_key', plainTextData);

    // 4. Close the box to ensure it writes to disk
    final boxPath = box.path;
    await box.close();

    // 5. Read the raw file directly from the file system
    expect(boxPath, isNotNull);
    final file = File(boxPath!);
    expect(file.existsSync(), isTrue);

    final rawFileBytes = await file.readAsBytes();
    final rawStringContent = utf8.decode(rawFileBytes, allowMalformed: true);

    // 6. Assertions
    // The raw string content of the file should NOT contain the plain text data
    expect(
      rawStringContent.contains(plainTextData),
      isFalse,
      reason:
          'The plain text data was found in the raw Hive file! Encryption failed.',
    );

    // 7. Verify we can still read it back correctly using the cipher
    final reopenBox = await Hive.openBox<String>(
      boxName,
      encryptionCipher: cipher,
    );

    final decryptedData = reopenBox.get('secret_key');
    expect(decryptedData, equals(plainTextData));

    // Cleanup
    await reopenBox.close();
    await Hive.deleteBoxFromDisk(boxName);
  });
}
