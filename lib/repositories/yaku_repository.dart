import '../models/auth_models.dart';
import '../models/dashboard_models.dart';
import '../models/subscription.dart';
import '../services/api_client.dart';

class YakuRepository {
  YakuRepository(this._api);
  final ApiClient _api;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      'auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthSession.fromJson(_map(data));
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    String? name,
    required String timezone,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'timezone': timezone,
    };
    if (name?.trim().isNotEmpty == true) body['name'] = name!.trim();
    final data = await _api.post('auth/register', body: body);
    return AuthSession.fromJson(_map(data));
  }

  Future<AuthSession> refresh(String refreshToken) async =>
      AuthSession.fromJson(
        _map(
          await _api.post('auth/refresh', body: {'refreshToken': refreshToken}),
        ),
      );

  Future<void> logout(String refreshToken) =>
      _api.post('auth/logout', body: {'refreshToken': refreshToken});
  Future<UserProfile> profile() async =>
      UserProfile.fromJson(_map(await _api.get('me')));
  Future<UserProfile> updateProfile(Map<String, dynamic> body) async =>
      UserProfile.fromJson(_map(await _api.patch('me', body: body)));

  Future<List<Subscription>> subscriptions() async {
    final data = _map(await _api.get('subscriptions'));
    return _items(data).map(Subscription.fromJson).toList();
  }

  Future<void> deleteSubscription(String id) async {
  await _api.delete(
    'subscriptions/${Uri.encodeComponent(id)}',
  );
}

  Future<DashboardSummary> summary() async =>
      DashboardSummary.fromJson(_map(await _api.get('subscriptions/summary')));

  Future<List<CancellationAttempt>> attempts() async {
    final data = _map(await _api.get('cancellation-attempts'));
    return _items(data).map(CancellationAttempt.fromJson).toList();
  }

  Future<Subscription> createSubscription(Map<String, dynamic> body) async =>
      Subscription.fromJson(_map(await _api.post('subscriptions', body: body)));

  Future<Subscription> updateSubscription(
    String id,
    Map<String, dynamic> body,
  ) async => Subscription.fromJson(
    _map(await _api.patch('subscriptions/$id', body: body)),
  );

  Map<String, dynamic> _map(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected Yaku response.');
    }
    return data;
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> data) {
    final items = data['items'];
    if (items is! List) {
      throw const FormatException('Unexpected Yaku list response.');
    }
    return items.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Unexpected Yaku list item.');
      }
      return item;
    }).toList();
  }
}
