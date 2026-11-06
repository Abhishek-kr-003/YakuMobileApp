import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';
import '../models/subscription.dart';
import '../utils/formatters.dart';
import '../widgets/subscription_card.dart';
import 'subscription_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.subscriptions,
    required this.summary,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onUpdateSubscription,
    required this.onOpenSubscriptions,
    required this.onOpenSettings,
  });

  final List<Subscription> subscriptions;
  final DashboardSummary? summary;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<String?> Function(String id, Map<String, dynamic> body)
  onUpdateSubscription;
  final VoidCallback onOpenSubscriptions;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final active = subscriptions.where((item) => item.isActive).toList();
    final trials = summary?.trials ?? <TrialCountdown>[];
    final spending = summary?.monthlySpend ?? <CurrencySpend>[];
    final upcoming = [...subscriptions]
      ..sort((a, b) {
        final left = a.nextChargeDate;
        final right = b.nextChargeDate;
        if (left == null && right == null) return 0;
        if (left == null) return 1;
        if (right == null) return -1;
        return left.compareTo(right);
      });
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Good morning',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: onOpenSettings,
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'A clear view of your subscriptions',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (isLoading && summary == null) const LinearProgressIndicator(),
          if (error != null) _ErrorBanner(message: error!, onRetry: onRefresh),
          _SpendingHero(spending: spending),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Active plans',
                  value: summary == null ? '—' : active.length.toString(),
                  icon: Icons.layers_outlined,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _MetricCard(
                  label: 'Trials ending',
                  value: summary == null ? '—' : trials.length.toString(),
                  icon: Icons.hourglass_bottom_outlined,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Coming up',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: onOpenSubscriptions,
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (!isLoading && upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('No subscriptions have been added yet.'),
              ),
            ),
          ...upcoming
              .where((item) => item.nextChargeDate != null)
              .take(3)
              .map(
                (subscription) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SubscriptionCard(
                    subscription: subscription,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SubscriptionDetailsScreen(
                          subscription: subscription,
                          onUpdate: onUpdateSubscription,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SpendingHero extends StatelessWidget {
  const _SpendingHero({required this.spending});
  final List<CurrencySpend> spending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6750A4), Color(0xFF9B7BD4)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly spending',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          if (spending.isEmpty)
            Text(
              'No active spend',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            )
          else
            ...spending.map(
              (item) => Text(
                currency(item.monthlyMinor / 100, item.currency),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Estimated monthly recurring spend',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: MaterialBanner(
      content: Text(message),
      actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 18),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
