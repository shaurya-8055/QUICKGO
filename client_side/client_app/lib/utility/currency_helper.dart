class CurrencyHelper {
  static const String currencySymbol = '₹'; // Indian Rupee symbol
  static const String currencyCode = 'INR';

  /// Formats a number as Indian Rupee currency
  /// Example: 1234.56 -> "₹1,234.56"
  static String formatCurrency(num amount) {
    if (amount == 0) return '$currencySymbol 0';

    // Convert to string with 2 decimal places
    String amountStr = amount.toStringAsFixed(2);

    // Remove trailing zeros after decimal point
    if (amountStr.contains('.')) {
      amountStr = amountStr.replaceAll(RegExp(r'\.?0*$'), '');
    }

    // Add currency symbol
    return '$currencySymbol $amountStr';
  }

  /// Formats a number as Indian Rupee currency without decimal if it's a whole number
  /// Example: 1234.00 -> "₹1,234", 1234.56 -> "₹1,234.56"
  static String formatCurrencyCompact(num amount) {
    if (amount == 0) return '$currencySymbol 0';

    if (amount == amount.truncate()) {
      // It's a whole number
      return '$currencySymbol ${amount.truncate()}';
    } else {
      // It has decimal places
      return '$currencySymbol ${amount.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '')}';
    }
  }
}
