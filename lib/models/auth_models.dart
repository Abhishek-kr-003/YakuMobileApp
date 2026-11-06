class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    accessToken: _string(json, 'accessToken'),
    refreshToken: _string(json, 'refreshToken'),
    expiresIn: _int(json, 'expiresIn'),
  );

  Map<String, String> toStorage() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn.toString(),
  };

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw const FormatException('Invalid authentication response.');
    }
    return value;
  }

  static int _int(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! num) {
      throw const FormatException('Invalid authentication response.');
    }
    return value.toInt();
  }
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.theme,
    required this.alertsAllowed,
  });
  final String? name;
  final String email;
  final String theme;
  final bool alertsAllowed;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final entitlements = json['entitlements'];
    if (json['email'] is! String || entitlements is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile response.');
    }
    return UserProfile(
      name: json['name'] as String?,
      email: json['email'] as String,
      theme: json['theme'] as String? ?? 'system',
      alertsAllowed: entitlements['alertsAllowed'] == true,
    );
  }
}
