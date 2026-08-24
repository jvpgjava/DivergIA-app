/// Espelha `LoginResponse` do backend (`POST /api/auth/login`).
class TokenAcesso {
  const TokenAcesso({required this.accessToken, required this.expiraEm});

  factory TokenAcesso.fromJson(Map<String, dynamic> json) => TokenAcesso(
    accessToken: json['accessToken'] as String,
    expiraEm: DateTime.parse(json['expiraEm'] as String),
  );

  final String accessToken;
  final DateTime expiraEm;
}
