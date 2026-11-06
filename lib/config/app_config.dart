class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment('YAKU_API_BASE_URL');
  static bool get isApiConfigured =>
      apiBaseUrl.startsWith('http://') || apiBaseUrl.startsWith('https://');
}
