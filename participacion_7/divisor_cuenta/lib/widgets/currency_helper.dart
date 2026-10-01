class CurrencyHelper {
  static const List<String> availableCurrencies = [
    r'$',
    '€',
    '£',
    'S/',
    'COP',
    'MXN',
  ];

  static String format(double amount, {String symbol = r'$'}) {
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
}
