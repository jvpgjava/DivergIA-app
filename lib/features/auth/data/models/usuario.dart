/// Espelha `UsuarioResponse` do backend (`GET/POST /api/auth/*`).
class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.criadoEm,
    this.fotoUrl,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] as String,
    nome: json['nome'] as String,
    email: json['email'] as String,
    criadoEm: DateTime.parse(json['criadoEm'] as String),
    fotoUrl: json['fotoUrl'] as String?,
  );

  final String id;
  final String nome;
  final String email;
  final DateTime criadoEm;
  final String? fotoUrl;

  Usuario copyWith({String? email, String? fotoUrl}) => Usuario(
    id: id,
    nome: nome,
    email: email ?? this.email,
    criadoEm: criadoEm,
    fotoUrl: fotoUrl ?? this.fotoUrl,
  );
}
