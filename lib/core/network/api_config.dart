abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Análise e reescrita chamam o modelo e passam de 15 s; fica acima do timeout do servidor (90 s).
  static const Duration iaTimeout = Duration(seconds: 150);
}
