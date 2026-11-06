import 'package:flutter/material.dart';

import '../models/subscription.dart';

final List<Subscription> sampleSubscriptions = [
  Subscription(
    id: 'netflix',
    name: 'Netflix',
    category: 'Entertainment',
    price: 15.49,
    billingCycle: BillingCycle.monthly,
    nextCharge: DateTime(2026, 11, 2),
    status: SubscriptionStatus.active,
    icon: Icons.movie_outlined,
    color: const Color(0xFFE50914),
    description: 'Standard plan · Entertainment at home.',
  ),
  Subscription(
    id: 'spotify',
    name: 'Spotify',
    category: 'Music',
    price: 10.99,
    billingCycle: BillingCycle.monthly,
    nextCharge: DateTime(2026, 10, 29),
    status: SubscriptionStatus.active,
    icon: Icons.graphic_eq,
    color: const Color(0xFF1DB954),
    description: 'Individual Premium · Ad-free listening.',
  ),
  Subscription(
    id: 'notion',
    name: 'Notion',
    category: 'Productivity',
    price: 12,
    billingCycle: BillingCycle.monthly,
    nextCharge: DateTime(2026, 11, 5),
    status: SubscriptionStatus.active,
    icon: Icons.edit_note_outlined,
    color: const Color(0xFF111111),
    description: 'Plus plan · Notes and project workspace.',
  ),
  Subscription(
    id: 'headspace',
    name: 'Headspace',
    category: 'Wellness',
    price: 69.99,
    billingCycle: BillingCycle.yearly,
    nextCharge: DateTime(2027, 3, 12),
    status: SubscriptionStatus.active,
    icon: Icons.self_improvement_outlined,
    color: const Color(0xFFFF8A65),
    description: 'Annual plan · Mindfulness and sleep.',
  ),
  Subscription(
    id: 'mubi',
    name: 'MUBI',
    category: 'Entertainment',
    price: 14.99,
    billingCycle: BillingCycle.monthly,
    nextCharge: DateTime(2026, 11, 1),
    status: SubscriptionStatus.trial,
    trialEnds: DateTime(2026, 10, 31),
    icon: Icons.theaters_outlined,
    color: const Color(0xFF263238),
    description: '30-day trial · Curated cinema.',
  ),
  Subscription(
    id: 'strava',
    name: 'Strava',
    category: 'Fitness',
    price: 79.99,
    billingCycle: BillingCycle.yearly,
    nextCharge: DateTime(2027, 1, 8),
    status: SubscriptionStatus.trial,
    trialEnds: DateTime(2026, 10, 30),
    icon: Icons.directions_run_outlined,
    color: const Color(0xFFFF5722),
    description: 'Free trial · Training insights and routes.',
  ),
];

class ActivityItem {
  const ActivityItem(this.title, this.detail, this.date, this.icon, this.color);
  final String title;
  final String detail;
  final DateTime date;
  final IconData icon;
  final Color color;
}

final sampleActivity = [
  ActivityItem(
    'Sample cancellation record',
    'Example only — no live subscription was cancelled',
    DateTime(2026, 10, 22),
    Icons.event_available_outlined,
    Colors.teal,
  ),
  ActivityItem(
    'Price change noted',
    'YouTube Premium price update',
    DateTime(2026, 10, 18),
    Icons.trending_up_outlined,
    Colors.orange,
  ),
  ActivityItem(
    'Renewal reminder sent',
    'Headspace annual plan',
    DateTime(2026, 10, 12),
    Icons.notifications_none,
    Colors.blue,
  ),
];
