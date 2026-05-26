class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'development',
  );

  static bool get isProduction => flavor == 'production';
  static bool get isStaging => flavor == 'staging';
  static bool get isDevelopment => flavor == 'development';

  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw const MissingConfigException(
        'SUPABASE_URL no fue provisto. Lanza con: '
        'flutter run --dart-define-from-file=env/<flavor>.json',
      );
    }
    if (supabaseAnonKey.isEmpty) {
      throw const MissingConfigException(
        'SUPABASE_ANON_KEY no fue provisto. Lanza con: '
        'flutter run --dart-define-from-file=env/<flavor>.json',
      );
    }
  }
}

class MissingConfigException implements Exception {
  final String message;
  const MissingConfigException(this.message);

  @override
  String toString() => 'MissingConfigException: $message';
}
