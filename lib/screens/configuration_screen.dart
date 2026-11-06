import 'package:flutter/material.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.settings_ethernet_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'Connect Yaku',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'No API address is configured. Start the app with YAKU_API_BASE_URL set to your HTTPS API endpoint.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            SelectableText(
              'flutter run --dart-define=YAKU_API_BASE_URL=https://api.example.com/api/v1/',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
