import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_models.dart';

class SecureSessionStore {
  static const _accessKey = 'yaku_access_token';
  static const _refreshKey = 'yaku_refresh_token';
  static const _expiresKey = 'yaku_token_expires_in';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<AuthSession?> read() async {
    final values = await _storage.readAll();
    final access = values[_accessKey];
    final refresh = values[_refreshKey];
    final expires = int.tryParse(values[_expiresKey] ?? '');
    if (access == null || refresh == null || expires == null) return null;
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      expiresIn: expires,
    );
  }

  Future<void> save(AuthSession session) async {
    final values = session.toStorage();
    await _storage.write(key: _accessKey, value: values['accessToken']);
    await _storage.write(key: _refreshKey, value: values['refreshToken']);
    await _storage.write(key: _expiresKey, value: values['expiresIn']);
  }

  Future<void> clear() => _storage.deleteAll();
}
