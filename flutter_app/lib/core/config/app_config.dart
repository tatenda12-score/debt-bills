class AppConfig {
  // Use 10.0.2.2 for Android emulator testing against local host
  // Use localhost for iOS simulator or web
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
