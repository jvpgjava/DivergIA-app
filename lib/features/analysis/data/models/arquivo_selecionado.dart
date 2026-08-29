import 'dart:typed_data';

/// Um arquivo escolhido pela pessoa (texto original ou editado) — desacopla
/// a API de análise do pacote de seleção de arquivo usado na tela.
class ArquivoSelecionado {
  const ArquivoSelecionado({required this.nome, required this.bytes});

  final String nome;
  final Uint8List bytes;
}
