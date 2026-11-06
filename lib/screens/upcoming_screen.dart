import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';
import '../models/subscription.dart';
import '../utils/formatters.dart';
import '../widgets/common_widgets.dart';

class UpcomingScreen extends StatelessWidget {
  const UpcomingScreen({
    super.key,
    required this.subscriptions,
    required this.summary,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });
  final List<Subscription> subscriptions;
  final DashboardSummary? summary;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final items = <_TimelineItem>[
      if (summary != null)
        for (final charge in summary!.upcomingCharges)
          _TimelineItem(
            charge.date,
            charge.serviceName,
            'Charge · ${charge.currency} ${currency(charge.amountMinor / 100)}',
            Icons.credit_card_outlined,
            Colors.blue,
          ),
      if (summary != null)
        for (final trial in summary!.trials)
          _TimelineItem(
            trial.date,
            trial.serviceName,
            'Trial ends · review before renewal',
            Icons.hourglass_bottom_outlined,
            Colors.orange,
          ),
    ]..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        const PageHeader(
          title: 'Upcoming',
          subtitle: 'Charges and trial deadlines, sorted by date',
        ),
        if (isLoading && summary == null) const LinearProgressIndicator(),
        if (error != null)
          MaterialBanner(
            content: Text(error!),
            actions: [
              TextButton(onPressed: onRefresh, child: const Text('Retry')),
            ],
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'Nothing upcoming',
                    message:
                        'Future charges and trial reminders will appear here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _UpcomingTile(
                      item: items[index],
                      isLast: index == items.length - 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _TimelineItem {
  const _TimelineItem(
    this.date,
    this.title,
    this.detail,
    this.icon,
    this.color,
  );
  final DateTime date;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.item, required this.isLast});
  final _TimelineItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 53,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: .13),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: item.color, size: 21),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel(item.date),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.detail,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
