import 'dart:typed_data';

class ArquivoSelecionado {
  const ArquivoSelecionado({required this.nome, required this.bytes});

  final String nome;
  final Uint8List bytes;
}
