class DashboardSummary {
  const DashboardSummary({
    required this.monthlySpend,
    required this.upcomingCharges,
    required this.trials,
  });

  final List<CurrencySpend> monthlySpend;
  final List<UpcomingCharge> upcomingCharges;
  final List<TrialCountdown> trials;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final spend = _list(json['spendByCurrency'])
        .map(CurrencySpend.fromJson)
        .toList();
    final charges = _list(json['upcomingCharges'])
        .map(UpcomingCharge.fromJson)
        .toList();
    final trials = _list(json['trialCountdowns'])
        .map(TrialCountdown.fromJson)
        .toList();
    return DashboardSummary(
      monthlySpend: spend,
      upcomingCharges: charges,
      trials: trials,
    );
  }
}

class CurrencySpend {
  const CurrencySpend(this.currency, this.monthlyMinor, this.subscriptionCount);
  final String currency;
  final int monthlyMinor;
  final int subscriptionCount;
  factory CurrencySpend.fromJson(Map<String, dynamic> json) => CurrencySpend(
    _string(json, 'currency'),
    _number(json, 'monthlyMinor'),
    _number(json, 'subscriptionCount'),
  );
}

class UpcomingCharge {
  const UpcomingCharge(
    this.subscriptionId,
    this.serviceName,
    this.amountMinor,
    this.currency,
    this.date,
    this.daysUntil,
  );
  final String subscriptionId;
  final String serviceName;
  final int amountMinor;
  final String currency;
  final DateTime date;
  final int daysUntil;
  factory UpcomingCharge.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'];
    if (amount is! Map<String, dynamic>) {
      throw const FormatException('Invalid upcoming charge.');
    }
    return UpcomingCharge(
      _string(json, 'subscriptionId'),
      _string(json, 'serviceName'),
      _number(amount, 'amountMinor'),
      _string(amount, 'currency'),
      _date(json, 'nextChargeDate'),
      _number(json, 'daysUntil'),
    );
  }
}

class TrialCountdown {
  const TrialCountdown(
    this.subscriptionId,
    this.serviceName,
    this.date,
    this.daysUntil,
  );
  final String subscriptionId;
  final String serviceName;
  final DateTime date;
  final int daysUntil;
  factory TrialCountdown.fromJson(Map<String, dynamic> json) => TrialCountdown(
    _string(json, 'subscriptionId'),
    _string(json, 'serviceName'),
    _date(json, 'trialEndDate'),
    _number(json, 'daysUntil'),
  );
}

class CancellationAttempt {
  const CancellationAttempt({
    required this.id,
    required this.subscriptionId,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.abortReason,
  });
  final String id;
  final String subscriptionId;
  final String status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? abortReason;
  factory CancellationAttempt.fromJson(Map<String, dynamic> json) =>
      CancellationAttempt(
        id: _string(json, 'id'),
        subscriptionId: _string(json, 'subscriptionId'),
        status: _string(json, 'status'),
        startedAt: _date(json, 'startedAt'),
        finishedAt: json['finishedAt'] is String
            ? DateTime.tryParse(json['finishedAt'] as String)
            : null,
        abortReason: json['abortReason'] as String?,
      );
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) throw const FormatException('Invalid list response.');
  return value.map((item) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Invalid list item.');
    }
    return item;
  }).toList();
}

String _string(Map<String, dynamic> value, String key) {
  final item = value[key];
  if (item is! String || item.isEmpty) {
    throw FormatException('Missing $key.');
  }
  return item;
}

int _number(Map<String, dynamic> value, String key) {
  final item = value[key];
  if (item is! num) throw FormatException('Missing $key.');
  return item.toInt();
}

DateTime _date(Map<String, dynamic> value, String key) {
  final parsed = value[key] is String
      ? DateTime.tryParse(value[key] as String)
      : null;
  if (parsed == null) throw FormatException('Invalid $key.');
  return parsed;
}
