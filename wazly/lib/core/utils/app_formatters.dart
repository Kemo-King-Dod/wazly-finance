import 'package:intl/intl.dart';

class AppFormatters {
  /// Formats a double amount with 2 decimal places using English digits (0-9).
  /// This ensures that even in Arabic locale, the numbers remain in Western style.
  static String formatAmount(double amount) {
    return NumberFormat.decimalPattern('en_US').format(amount);
  }

  /// Formats an amount in cents (e.g. 100 cents = 1.00 LYD).
  static String formatAmountInCents(int cents) {
    return formatAmount(cents / 100);
  }

  /// Formats a date using the given pattern, but ensures Western digits are used.
  /// If [useArabicText] is true, month names will be in Arabic, but digits in English.
  static String formatDate(DateTime date, String pattern, {bool useArabicText = true}) {
    final locale = useArabicText ? 'ar' : 'en';
    final formatted = DateFormat(pattern, locale).format(date);
    
    // Replace Arabic digits with English digits if they exist in the string
    return _toEnglishDigits(formatted);
  }

  static String _toEnglishDigits(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String output = input;
    for (int i = 0; i < 10; i++) {
      output = output.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return output;
  }
}
