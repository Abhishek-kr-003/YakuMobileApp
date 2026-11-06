import 'package:flutter/material.dart';

enum SubscriptionStatus { active, trialing, trial, paused, cancelled, expired }

enum BillingCycle {
  weekly,
  monthly,
  quarterly,
  semiannual,
  yearly,
  annual,
  oneTime,
}

class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.billingCycle,
    required this.nextCharge,
    required this.status,
    required this.icon,
    required this.color,
    this.currency = 'USD',
    this.amountMinor,
    this.plan,
    this.nextChargeDate,
    this.trialEndDate,
    this.cancelUrl,
    this.manageUrl,
    this.trialEnds,
    this.description = '',
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final BillingCycle billingCycle;
  final DateTime nextCharge;
  final SubscriptionStatus status;
  final IconData icon;
  final Color color;
  final DateTime? trialEnds;
  final String description;
  final String currency;
  final int? amountMinor;
  final String? plan;
  final DateTime? nextChargeDate;
  final DateTime? trialEndDate;
  final String? cancelUrl;
  final String? manageUrl;

  bool get isActive => status == SubscriptionStatus.active;
  bool get isTrial =>
      status == SubscriptionStatus.trial ||
      status == SubscriptionStatus.trialing;
  double get monthlyCost => switch (billingCycle) {
    BillingCycle.weekly => price * 52 / 12,
    BillingCycle.monthly => price,
    BillingCycle.quarterly => price / 3,
    BillingCycle.semiannual => price / 6,
    BillingCycle.yearly || BillingCycle.annual => price / 12,
    BillingCycle.oneTime => 0,
  };
  String get billingLabel => switch (billingCycle) {
    BillingCycle.weekly => 'Weekly',
    BillingCycle.monthly => 'Monthly',
    BillingCycle.quarterly => 'Quarterly',
    BillingCycle.semiannual => 'Semiannual',
    BillingCycle.yearly || BillingCycle.annual => 'Annual',
    BillingCycle.oneTime => 'One-time',
  };
  String get statusLabel => switch (status) {
    SubscriptionStatus.active => 'Active',
    SubscriptionStatus.trial || SubscriptionStatus.trialing => 'Trial',
    SubscriptionStatus.paused => 'Paused',
    SubscriptionStatus.cancelled => 'Cancelled',
    SubscriptionStatus.expired => 'Expired',
  };

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'];
    if (json['id'] is! String ||
        json['serviceName'] is! String ||
        amount is! Map<String, dynamic>) {
      throw const FormatException('Invalid subscription response.');
    }
    final minor = amount['amountMinor'];
    final currency = amount['currency'];
    if (minor is! num || currency is! String) {
      throw const FormatException('Invalid subscription amount.');
    }
    final cycle = _billingCycle(json['billingCycle'] as String?);
    final status = _status(json['status'] as String?);
    final parsedNextCharge = _date(json['nextChargeDate']);
    final parsedTrial = _date(json['trialEndDate']);
    return Subscription(
      id: json['id'] as String,
      name: json['serviceName'] as String,
      category: json['category'] as String? ?? 'other',
      price: minor.toDouble() / 100,
      amountMinor: minor.toInt(),
      currency: currency,
      billingCycle: cycle,
      nextCharge: parsedNextCharge ?? DateTime.fromMillisecondsSinceEpoch(0),
      nextChargeDate: parsedNextCharge,
      status: status,
      trialEnds: parsedTrial,
      trialEndDate: parsedTrial,
      plan: json['plan'] as String?,
      description: json['notes'] as String? ?? '',
      cancelUrl: json['cancelUrl'] as String?,
      manageUrl: json['manageUrl'] as String?,
      icon: _iconForCategory(json['category'] as String?),
      color: _colorForCategory(json['category'] as String?),
    );
  }
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

SubscriptionStatus _status(String? value) => switch (value) {
  'active' => SubscriptionStatus.active,
  'trialing' => SubscriptionStatus.trialing,
  'paused' => SubscriptionStatus.paused,
  'cancelled' => SubscriptionStatus.cancelled,
  'expired' => SubscriptionStatus.expired,
  _ => throw const FormatException('Invalid subscription status.'),
};

BillingCycle _billingCycle(String? value) => switch (value) {
  'weekly' => BillingCycle.weekly,
  'monthly' => BillingCycle.monthly,
  'quarterly' => BillingCycle.quarterly,
  'semiannual' => BillingCycle.semiannual,
  'annual' => BillingCycle.annual,
  'one_time' => BillingCycle.oneTime,
  _ => throw const FormatException('Invalid subscription billing cycle.'),
};

IconData _iconForCategory(String? category) => switch (category) {
  'video' => Icons.movie_outlined,
  'music' => Icons.graphic_eq,
  'fitness' => Icons.directions_run_outlined,
  'productivity' || 'software' || 'ai' => Icons.auto_awesome_outlined,
  'cloud_storage' => Icons.cloud_outlined,
  _ => Icons.credit_card_outlined,
};

Color _colorForCategory(String? category) => switch (category) {
  'video' => const Color(0xFFE50914),
  'music' => const Color(0xFF1DB954),
  'fitness' => const Color(0xFFFF5722),
  'productivity' || 'software' || 'ai' => const Color(0xFF6750A4),
  _ => const Color(0xFF1565C0),
};
