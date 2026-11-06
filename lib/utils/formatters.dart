String currency(double value, [String currencyCode = 'USD']) {
  final code = currencyCode.toUpperCase();

  const symbols = <String, String>{
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'KRW': '₩',
    'CAD': 'CA\$',
    'AUD': 'A\$',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'NZD': 'NZ\$',
    'CHF': 'CHF ',
    'AED': 'د.إ ',
    'SAR': 'ر.س ',
    'BRL': 'R\$',
    'RUB': '₽',
    'TRY': '₺',
    'ZAR': 'R',
    'THB': '฿',
    'MYR': 'RM ',
    'IDR': 'Rp ',
    'PHP': '₱',
    'BDT': '৳',
    'PKR': 'Rs ',
    'VND': '₫',
    'NGN': '₦',
    'KES': 'KSh ',
  };

  const zeroDecimalCurrencies = {'JPY', 'KRW', 'VND', 'IDR', 'CLP'};
  const threeDecimalCurrencies = {'BHD', 'KWD', 'OMR', 'JOD', 'TND'};

  final decimals = zeroDecimalCurrencies.contains(code)
      ? 0
      : threeDecimalCurrencies.contains(code)
      ? 3
      : 2;

  final symbol = symbols[code] ?? '$code ';
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');

  final integerPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  final formatted = decimals == 0 ? integerPart : '$integerPart.${parts[1]}';

  return '${value < 0 ? '-' : ''}$symbol$formatted';
}

String dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}';
}

String fullDateLabel(DateTime date) => '${dateLabel(date)}, ${date.year}';
