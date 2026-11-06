import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';
import '../models/subscription.dart';
import '../utils/formatters.dart';
import '../widgets/common_widgets.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({
    super.key,
    required this.attempts,
    required this.subscriptions,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });
  final List<CancellationAttempt> attempts;
  final List<Subscription> subscriptions;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageHeader(
          title: 'Activity',
          subtitle: 'Real cancellation workflow status',
        ),
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
            child: isLoading && attempts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : attempts.isEmpty
                ? const EmptyState(
                    icon: Icons.history_toggle_off_outlined,
                    title: 'No cancellation activity',
                    message: 'The Chrome extension records workflow status here after you explicitly start a supported cancellation.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                    itemCount: attempts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = attempts[index];
                      final subscription = subscriptions
                          .where((entry) => entry.id == item.subscriptionId)
                          .firstOrNull;
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _colorForStatus(item.status)
                                  .withValues(alpha: .13),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _iconForStatus(item.status),
                              color: _colorForStatus(item.status),
                            ),
                          ),
                          title: Text(
                            subscription?.name ?? 'Subscription workflow',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_statusDetail(item)),
                          ),
                          trailing: Text(
                            dateLabel(item.startedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  String _statusDetail(CancellationAttempt item) {
    final reason = item.abortReason == null ? '' : ' · ${item.abortReason!}';
    return item.status + reason;
  }

  IconData _iconForStatus(String status) => switch (status) {
    'succeeded' => Icons.check_circle_outline,
    'failed' || 'blocked' => Icons.error_outline,
    'aborted' => Icons.cancel_outlined,
    _ => Icons.hourglass_top_outlined,
  };

  Color _colorForStatus(String status) => switch (status) {
    'succeeded' => Colors.green,
    'failed' || 'blocked' => Colors.red,
    'aborted' => Colors.orange,
    _ => Colors.blue,
  };
}
