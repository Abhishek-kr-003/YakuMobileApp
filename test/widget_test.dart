// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yaku_mobile/models/dashboard_models.dart';
import 'package:yaku_mobile/models/subscription.dart';
import 'package:yaku_mobile/main.dart';
import 'package:yaku_mobile/screens/subscriptions_screen.dart';

void main() {
  testWidgets('unconfigured app explains how to connect the backend', (
    tester,
  ) async {
    await tester.pumpWidget(const YakuApp());

    expect(find.text('Connect Yaku'), findsOneWidget);
    expect(find.textContaining('YAKU_API_BASE_URL'), findsWidgets);
  });

  testWidgets('subscriptions can be searched', (tester) async {
    final netflix = Subscription(
      id: 'netflix',
      name: 'Netflix',
      category: 'video',
      price: 15,
      billingCycle: BillingCycle.monthly,
      nextCharge: DateTime(2026, 11, 2),
      status: SubscriptionStatus.active,
      icon: Icons.movie_outlined,
      color: Colors.red,
    );
    final spotify = Subscription(
      id: 'spotify',
      name: 'Spotify',
      category: 'music',
      price: 10,
      billingCycle: BillingCycle.monthly,
      nextCharge: DateTime(2026, 11, 3),
      status: SubscriptionStatus.active,
      icon: Icons.graphic_eq,
      color: Colors.green,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionsScreen(
            subscriptions: [netflix, spotify],
            isLoading: false,
            error: null,
            onRefresh: () async {},
            onUpdateSubscription: (id, body) async => null,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), 'Spotify');
    await tester.pumpAndSettle();

    expect(find.text('Spotify'), findsWidgets);
    expect(find.text('Netflix'), findsNothing);
  });

  test('backend subscription response parses billing and nullable dates', () {
    final subscription = Subscription.fromJson({
      'id': 'one',
      'serviceName': 'Example',
      'category': 'software',
      'amount': {'amountMinor': 1299, 'currency': 'USD'},
      'billingCycle': 'annual',
      'status': 'active',
      'nextChargeDate': null,
      'trialEndDate': null,
      'plan': null,
      'notes': null,
    });
    expect(subscription.monthlyCost, closeTo(1.0825, 0.0001));
    expect(subscription.nextChargeDate, isNull);
    expect(subscription.currency, 'USD');
  });

  test('summary response preserves separate currencies', () {
    final summary = DashboardSummary.fromJson({
      'spendByCurrency': [
        {'currency': 'USD', 'monthlyMinor': 2500, 'subscriptionCount': 2},
      ],
      'upcomingCharges': [],
      'trialCountdowns': [],
    });
    expect(summary.monthlySpend.single.monthlyMinor, 2500);
  });
}
