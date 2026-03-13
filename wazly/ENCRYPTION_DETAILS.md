# Wazly App: Encryption & Export Compliance Details

This document outlines the cryptographic features implemented within the Wazly application to facilitate Apple App Store review and Export Compliance regulations.

## 1. Encryption Algorithm
Wazly utilizes **AES (Advanced Encryption Standard)** with a **256-bit key length**. This is the industry standard for symmetric-key encryption, providing robust protection for sensitive financial data stored locally on the user's device.

## 2. Key Management & Storage
The 256-bit AES encryption key is generated dynamically and uniquely for each user upon their first launch. 
- **Generation:** The key is generated using a secure random number generator (`Hive.generateSecureKey()`).
- **Secure Storage:** The generated key is immediately base64-encoded and securely stored using the native, hardware-backed keystores of the respective operating systems via the `flutter_secure_storage` package.
  - **iOS/macOS:** The key is stored in the **Apple Keychain**, ensuring it is isolated and protected by the operating system.
  - **Android:** The key is stored in the **Android Keystore**, utilizing hardware-backed security where available.

## 3. Encryption Scope
Encryption is **strictly limited** to local database files stored on the user's personal device. The following local Hive database boxes are encrypted:
- **Transactions:** (`transactions.hive`) - Contains user financial transaction records, amounts, and notes.
- **Installments/Debts:** (`installments.hive`) - Contains records of partial payments, settlements, and outstanding debt amounts.
- **Accounts:** (`accounts.hive`) - Contains user-created account names and current wallet balances.
- **Audit Logs:** (`audit_logs.hive`) - Contains historical tracking of modifications to transactions.
- **Profile:** (`profile.hive`) - Contains the user's locally stored profile information.

*Note: Application settings (e.g., UI theme preferences, localization choices) are stored in an unencrypted box (`settings.hive`) as they do not contain sensitive personal or financial information.*

## 4. Implementation Details
The application utilizes `HiveAesCipher` provided by the `hive` package to encrypt the database payload at rest. During application initialization (Dependency Injection setup), the app:
1. Retrieves the base64-encoded AES key from the secure storage (Keychain/Keystore).
2. Decodes the key into a `Uint8List`.
3. Passes the key into `HiveAesCipher`.
4. Initializes all sensitive `Hive.openBox` calls with the `encryptionCipher` parameter.

This implementation guarantees that the `.hive` binary files written to the device disk are entirely ciphered and cannot be read as plain text from outside the application environment.

## 5. Export Compliance Note
**Important:** The encryption mechanisms implemented in Wazly are used **exclusively** for the protection of the user's personal, locally stored financial data. 
- The app does **not** employ encryption for secure military or government communications.
- The app does **not** provide cryptographic libraries or APIs for third-party use.
- The encryption in this app is standard, readily available data-at-rest protection.

Therefore, the app qualifies for an exemption under Category 5, Part 2 of the EAR (Export Administration Regulations) and standard App Store export compliance guidelines for apps that use encryption solely for intellectual property or personal data protection.
