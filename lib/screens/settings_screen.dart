
import 'package:flutter/material.dart';

import '../controllers/yaku_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final YakuController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  bool _isLoggingOut = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = switch (widget.controller.profile?.theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final alertsAllowed =
        widget.controller.profile?.alertsAllowed ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<ThemeMode>(
                initialValue: themeMode,
                decoration: const InputDecoration(
                  labelText: 'App theme',
                  prefixIcon: Icon(Icons.palette_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Use device settings'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark theme'),
                  ),
                ],
                onChanged: _setTheme,
              ),
            ),
          ),

          const SizedBox(height: 26),

          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              value: alertsAllowed,
              onChanged: null,
              title: const Text('Renewal reminders'),
              subtitle: const Text(
                'Backend alert rules are available for Pro accounts. '
                'Manage delivery channels in the Yaku dashboard.',
              ),
              secondary: const Icon(Icons.notifications_active_outlined),
            ),
          ),

          const SizedBox(height: 26),

          Text(
            'Monthly spending alert',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'The backend currently exposes notification rules rather '
            'than a mobile spending-alert threshold.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                      hintText: 'e.g. 75',
                    ),
                    validator: (value) {
                      final amount =
                          double.tryParse(value?.trim() ?? '');

                      if (amount == null || amount <= 0) {
                        return 'Enter an amount greater than zero';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _saveAlert,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log out'),
              subtitle: const Text(
                'Sign out of your Yaku account on this device.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _isLoggingOut ? null : _confirmLogout,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setTheme(ThemeMode? mode) async {
    if (mode != null) {
      final error = await widget.controller.saveTheme(switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      });

      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  void _saveAlert() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This control is local validation only; '
          'no backend setting was saved.',
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'Are you sure you want to log out of your Yaku account?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await widget.controller.signOut();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not log out. Please try again.'),
        ),
      );
    }
  }
}
