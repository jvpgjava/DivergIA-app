class TokenAcesso {
  const TokenAcesso({required this.accessToken});

  factory TokenAcesso.fromJson(Map<String, dynamic> json) =>
      TokenAcesso(accessToken: json['accessToken'] as String);

  final String accessToken;
}
