import 'package:flutter/material.dart';

import '../models/subscription.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  const SubscriptionDetailsScreen({
    super.key,
    required this.subscription,
    required this.onUpdate,
  });

  final Subscription subscription;

  final Future<String?> Function(String id, Map<String, dynamic> body) onUpdate;

  String get formattedAmount {
    final minorAmount =
        subscription.amountMinor ?? (subscription.price * 100).round();

    return '${subscription.currency} '
        '${(minorAmount / 100).toStringAsFixed(2)}';
  }

  Future<void> _showEditDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _EditSubscriptionDialog(
          subscription: subscription,
          onUpdate: onUpdate,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Details')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              formattedAmount,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text('Billing cycle: ${subscription.billingLabel}'),
            const SizedBox(height: 8),
            Text('Status: ${subscription.statusLabel}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditDialog(context),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Subscription'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditSubscriptionDialog extends StatefulWidget {
  const _EditSubscriptionDialog({
    required this.subscription,
    required this.onUpdate,
  });

  final Subscription subscription;

  final Future<String?> Function(String id, Map<String, dynamic> body) onUpdate;

  @override
  State<_EditSubscriptionDialog> createState() =>
      _EditSubscriptionDialogState();
}

class _EditSubscriptionDialogState extends State<_EditSubscriptionDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final minorAmount =
        widget.subscription.amountMinor ??
        (widget.subscription.price * 100).round();

    _nameController = TextEditingController(text: widget.subscription.name);

    _amountController = TextEditingController(
      text: (minorAmount / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final body = <String, dynamic>{
        'serviceName': name,
        'amount': {
          'amountMinor': (amount * 100).round(),
          'currency': widget.subscription.currency,
        },
      };

      final error = await widget.onUpdate(widget.subscription.id, body);

      if (!mounted) return;

      if (error != null) {
        setState(() {
          _errorMessage = error;
          _isSaving = false;
        });
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to update subscription. Please try again.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: AlertDialog(
        title: const Text('Edit Subscription'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Service name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a service name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  enabled: !_isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${widget.subscription.currency} ',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');

                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }

                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
