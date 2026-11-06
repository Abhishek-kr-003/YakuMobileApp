import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/auth_models.dart';
import '../models/dashboard_models.dart';
import '../models/subscription.dart';
import '../repositories/yaku_repository.dart';
import '../services/api_client.dart';
import '../services/secure_session_store.dart';

enum SessionStatus { checking, signedOut, signedIn }

class YakuController extends ChangeNotifier {
  YakuController({this._repository, SecureSessionStore? store, ApiClient? api})
    : _api = api ?? ApiClient(),
      _store = store ?? SecureSessionStore();

  final ApiClient _api;
  final SecureSessionStore _store;
  YakuRepository? _repository;
  AuthSession? _session;

  SessionStatus sessionStatus = SessionStatus.checking;
  bool isLoadingData = false;
  String? dataError;
  UserProfile? profile;
  DashboardSummary? summary;
  List<Subscription> subscriptions = [];
  List<CancellationAttempt> attempts = [];

  YakuRepository get _repo => _repository ??= YakuRepository(_api);

  Future<void> restoreSession() async {
    final saved = await _store.read();
    if (saved == null) {
      sessionStatus = SessionStatus.signedOut;
      notifyListeners();
      return;
    }
    _session = saved;
    _api.accessToken = saved.accessToken;
    try {
      profile = await _repo.profile();
      sessionStatus = SessionStatus.signedIn;
      notifyListeners();
      await refresh();
    } on ApiException catch (error) {
      if (!error.isUnauthorized) {
        sessionStatus = SessionStatus.signedIn;
        dataError = error.message;
        notifyListeners();
        return;
      }
      await _refreshOrSignOut();
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _repo.login(email: email, password: password);
      await _startSession(session);
      return null;
    } on ApiException catch (error) {
      return error.message;
    } on FormatException {
      return 'Yaku sent an unexpected sign-in response. Please try again.';
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final session = await _repo.register(
        email: email,
        password: password,
        name: name,
        timezone: 'UTC',
      );
      await _startSession(session);
      return null;
    } on ApiException catch (error) {
      return error.message;
    } on FormatException {
      return 'Yaku sent an unexpected sign-up response. Please try again.';
    }
  }

  Future<void> _startSession(AuthSession session) async {
    _session = session;
    _api.accessToken = session.accessToken;
    await _store.save(session);
    profile = await _repo.profile();
    sessionStatus = SessionStatus.signedIn;
    notifyListeners();
    await refresh();
  }

  Future<void> refresh() async {
    if (sessionStatus != SessionStatus.signedIn || isLoadingData) return;
    isLoadingData = true;
    dataError = null;
    notifyListeners();
    try {
      final values = await Future.wait([
        _repo.profile(),
        _repo.subscriptions(),
        _repo.summary(),
        _repo.attempts(),
      ]);
      profile = values[0] as UserProfile;
      subscriptions = values[1] as List<Subscription>;
      summary = values[2] as DashboardSummary;
      attempts = values[3] as List<CancellationAttempt>;
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _refreshOrSignOut();
      } else {
        dataError = error.message;
      }
    } on FormatException {
      dataError = 'Yaku sent data in an unexpected format. Please try again.';
    } finally {
      isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> _refreshOrSignOut() async {
    final refreshToken = _session?.refreshToken;
    if (refreshToken == null) {
      await signOut();
      return;
    }
    try {
      final renewed = await _repo.refresh(refreshToken);
      _session = renewed;
      _api.accessToken = renewed.accessToken;
      await _store.save(renewed);
      profile = await _repo.profile();
      sessionStatus = SessionStatus.signedIn;
      dataError = null;
    } on ApiException {
      await signOut();
    }
  }

  Future<void> signOut() async {
    final token = _session?.refreshToken;
    try {
      if (token != null) await _repo.logout(token);
    } on ApiException {
      // Clearing a local session is safe even when the server cannot be reached.
    }
    _session = null;
    _api.accessToken = null;
    profile = null;
    summary = null;
    subscriptions = [];
    attempts = [];
    dataError = null;
    await _store.clear();
    sessionStatus = SessionStatus.signedOut;
    notifyListeners();
  }

  Future<String?> saveTheme(String theme) async {
    try {
      profile = await _repo.updateProfile({'theme': theme});
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String?> addSubscription(Map<String, dynamic> body) async {
    try {
      await _repo.createSubscription(body);
      await refresh();
      return null;
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String?> updateSubscription(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      await _repo.updateSubscription(id, body);
      await refresh();
      return null;
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String?> deleteSubscription(String id) async {
    try {
      await _repo.deleteSubscription(id);
      await refresh();
      return null;
    } on ApiException catch (error) {
      return error.message;
    }
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }
}
