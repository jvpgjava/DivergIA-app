class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.criadoEm,
    this.fotoUrl,
    this.papel = papelUsuario,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] as String,
    nome: json['nome'] as String,
    email: json['email'] as String,
    criadoEm: DateTime.parse(json['criadoEm'] as String),
    fotoUrl: json['fotoUrl'] as String?,
    papel: json['papel'] as String? ?? papelUsuario,
  );

  static const papelUsuario = 'USUARIO';
  static const papelDev = 'DEV';

  final String id;
  final String nome;
  final String email;
  final DateTime criadoEm;
  final String? fotoUrl;
  final String papel;

  // Só controla o que o app mostra. Quem de fato barra o acesso às métricas é o servidor.
  bool get ehDev => papel == papelDev;

  Usuario copyWith({String? email, String? fotoUrl}) => Usuario(
    id: id,
    nome: nome,
    email: email ?? this.email,
    criadoEm: criadoEm,
    fotoUrl: fotoUrl ?? this.fotoUrl,
    papel: papel,
  );
}
