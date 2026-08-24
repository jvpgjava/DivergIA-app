/// URL base do backend DivergIA. Nunca embutir aqui segredo/credencial de
/// infraestrutura — o app só conhece essa URL e se autentica com
/// usuário/senha (checklist de segurança do roadmap).
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
