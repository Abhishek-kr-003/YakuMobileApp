import 'package:flutter/material.dart';

import '../controllers/yaku_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});
  final YakuController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _isRegistering = false;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 54,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to Yaku',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegistering
                        ? 'Create your secure Yaku account.'
                        : 'Sign in to view your subscription ledger.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  if (_isRegistering) ...[
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Name (optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : 'Enter a valid email address',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: _isRegistering
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if ((value?.length ?? 0) < (_isRegistering ? 10 : 1)) {
                        return _isRegistering
                            ? 'Use at least 10 characters'
                            : 'Enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isRegistering ? 'Create account' : 'Sign in'),
                    ),
                  ),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () =>
                              setState(() => _isRegistering = !_isRegistering),
                    child: Text(
                      _isRegistering
                          ? 'Already have an account? Sign in'
                          : 'New to Yaku? Create an account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final error = _isRegistering
        ? await widget.controller.signUp(
            email: _email.text.trim(),
            password: _password.text,
            name: _name.text,
          )
        : await widget.controller.signIn(
            email: _email.text.trim(),
            password: _password.text,
          );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
