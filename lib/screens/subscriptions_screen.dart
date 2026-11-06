import 'package:flutter/material.dart';

import '../models/subscription.dart';
import '../widgets/common_widgets.dart';
import '../widgets/subscription_card.dart';
import 'subscription_details_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({
    super.key,
    required this.subscriptions,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    this.onAddSubscription,
    required this.onUpdateSubscription,
    this.onDeleteSubscription,
  });

  final List<Subscription> subscriptions;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;

  final Future<String?> Function(Map<String, dynamic> body)? onAddSubscription;

  final Future<String?> Function(String id, Map<String, dynamic> body)
  onUpdateSubscription;

  final Future<String?> Function(String id)? onDeleteSubscription;

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String _query = '';
  String _filter = 'All';
  final Set<String> _deletingIds = {};

  @override
  Widget build(BuildContext context) {
    final matching = widget.subscriptions.where((subscription) {
      final textMatches =
          subscription.name.toLowerCase().contains(_query.toLowerCase()) ||
          subscription.category.toLowerCase().contains(_query.toLowerCase());

      final filterMatches =
          _filter == 'All' || subscription.statusLabel == _filter;

      return textMatches && filterMatches;
    }).toList();

    return Column(
      children: [
        const PageHeader(
          title: 'Subscriptions',
          subtitle: 'Track every recurring expense',
        ),

        if (widget.onAddSubscription != null)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 8),
              child: FilledButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add subscription'),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search subscriptions',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 42,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: ['All', 'Active', 'Trial']
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: _filter == filter,
                      onSelected: (_) {
                        setState(() => _filter = filter);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: matching.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 100),
                      EmptyState(
                        icon: Icons.search_off_outlined,
                        title: 'No matching subscriptions',
                        message:
                            'Try another search or choose a different filter.',
                      ),
                    ],
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth > 700
                          ? 680.0
                          : constraints.maxWidth;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: width,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                            itemCount: matching.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 2),
                            itemBuilder: (context, index) {
                              final subscription = matching[index];
                              final isDeleting = _deletingIds.contains(
                                subscription.id,
                              );

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SubscriptionCard(
                                      subscription: subscription,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                SubscriptionDetailsScreen(
                                                  subscription: subscription,
                                                  onUpdate: widget
                                                      .onUpdateSubscription,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  if (widget.onDeleteSubscription != null)
                                    IconButton(
                                      tooltip: 'Delete subscription',
                                      onPressed: isDeleting
                                          ? null
                                          : () => _confirmDelete(subscription),
                                      icon: isDeleting
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                    ),
                                ],
                              );
                            },
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

  Future<void> _confirmDelete(Subscription subscription) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete subscription?'),
          content: Text(
            'Are you sure you want to remove ${subscription.name}? '
            'Its tracking will stop, but existing activity records '
            'will be preserved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await _deleteSubscription(subscription);
  }

  Future<void> _deleteSubscription(Subscription subscription) async {
    final onDelete = widget.onDeleteSubscription;

    if (onDelete == null) return;

    setState(() {
      _deletingIds.add(subscription.id);
    });

    try {
      final error = await onDelete(subscription.id);

      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${subscription.name} deleted successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete subscription. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingIds.remove(subscription.id);
        });
      }
    }
  }

  Future<void> _showAddDialog() async {
    final onAdd = widget.onAddSubscription;

    if (onAdd == null) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _AddSubscriptionDialog(onSubmit: onAdd),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription added successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _AddSubscriptionDialog extends StatefulWidget {
  const _AddSubscriptionDialog({required this.onSubmit});

  final Future<String?> Function(Map<String, dynamic> body) onSubmit;

  @override
  State<_AddSubscriptionDialog> createState() => _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends State<_AddSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _currencyController = TextEditingController(text: 'USD');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final amountValue = double.parse(_amountController.text.trim());

    final body = <String, dynamic>{
      'serviceName': _nameController.text.trim(),
      'amount': {
        'amountMinor': (amountValue * 100).round(),
        'currency': _currencyController.text.trim().toUpperCase(),
      },
      'billingCycle': 'monthly',
      'status': 'active',
    };

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final error = await widget.onSubmit(body);

      if (!mounted) return;

      if (error != null) {
        setState(() {
          _errorMessage = error;
          _isSubmitting = false;
        });
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add subscription'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Service name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                enabled: !_isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');

                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Enter a valid amount greater than zero';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currencyController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Currency (ISO code)',
                ),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[A-Za-z]{3}$').hasMatch(value.trim())) {
                    return 'Use a 3-letter code';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
