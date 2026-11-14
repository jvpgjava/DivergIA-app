library;

const limiteCaracteresAnalise = 10000;

final _invisiveis = RegExp(
  r'[\u200B-\u200F\u202A-\u202E\u2060-\u2064\uFEFF\u00AD]',
);
final _espacos = RegExp(r'[ \t\u00A0]+');
final _muitasQuebras = RegExp(r'\n{3,}');
final _letra = RegExp(r'\p{L}', unicode: true);
final _palavraDeLetras = RegExp(r'\p{L}+', unicode: true);
final _vogal = RegExp(r'[aeiouyáéíóúâêôãõàü]', caseSensitive: false);
final _consoantesSeguidas = RegExp(
  r'[bcdfghjklmnpqrstvwxz]{5,}',
  caseSensitive: false,
);
final _mesmoCaractere = RegExp(r'(.)\1{5,}');
final _binario = RegExp(r'(?:\b[01]{8}\b[\s,]*){4,}');
final _soBinario = RegExp(r'^[01\s,]{16,}$');
final _hex = RegExp(
  r'(?:\b[0-9a-fA-F]{2}\b[\s,:]*){16,}|\b(?:0x)?[0-9a-fA-F]{32,}\b',
);

String limparTexto(String texto) {
  final semInvisiveis = texto
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(_invisiveis, '')
      .replaceAll(_espacos, ' ');
  final linhas = semInvisiveis.split('\n').map((l) => l.trim()).join('\n');
  return linhas.replaceAll(_muitasQuebras, '\n\n').trim();
}

// Espelha as regras estruturais do ValidadorDeEntrada do backend; na dúvida, deixa o servidor decidir.
String? validarTextoDaAnalise(String texto, {required String rotulo}) {
  final t = limparTexto(texto);
  if (t.isEmpty) return 'Cole o texto ou anexe um arquivo';
  if (t.length > limiteCaracteresAnalise) {
    return 'O $rotulo passou do limite de $limiteCaracteresAnalise caracteres.';
  }
  if (_soBinario.hasMatch(t) || _binario.hasMatch(t) || _hex.hasMatch(t)) {
    return 'O $rotulo tem conteúdo codificado (binário ou hexadecimal). '
        'Cole o texto em linguagem natural.';
  }
  if (_naoEhTexto(t)) {
    return 'O $rotulo não parece ser um texto escrito (só números, símbolos '
        'ou código). O DivergIA compara frases em linguagem natural.';
  }
  if (_letraRepetidaDomina(t)) return _semSentido(rotulo);
  final palavras = _palavraDeLetras.allMatches(t).map((m) => m[0]!).toList();
  if (palavras.length < 2) {
    return 'O $rotulo é curto demais para comparar. Use pelo menos uma frase '
        'com algumas palavras.';
  }
  if (_lixoDeTeclado(palavras) || _palavraRepetida(palavras)) {
    return _semSentido(rotulo);
  }
  return null;
}

bool textosIdenticos(String original, String editado) {
  String forma(String s) => limparTexto(s).replaceAll(RegExp(r'\s+'), ' ');
  return forma(original) == forma(editado);
}

String _semSentido(String rotulo) =>
    'O $rotulo não parece ter palavras com sentido. Confira se colou o texto certo.';

bool _naoEhTexto(String t) {
  var visiveis = 0;
  var letras = 0;
  for (final rune in t.runes) {
    final c = String.fromCharCode(rune);
    if (c.trim().isEmpty) continue;
    visiveis++;
    if (_letra.hasMatch(c)) letras++;
  }
  return visiveis == 0 || letras < visiveis * 0.5;
}

bool _letraRepetidaDomina(String t) {
  final semEspacos = t.replaceAll(RegExp(r'\s+'), '');
  final m = _mesmoCaractere.firstMatch(semEspacos);
  return m != null && m[0]!.length * 2 >= semEspacos.length;
}

bool _lixoDeTeclado(List<String> palavras) {
  var longas = 0;
  var estranhas = 0;
  for (final p in palavras) {
    // Siglas (HTTP, HTML) não têm vogal e não são lixo de teclado.
    if (p.length < 4 || p == p.toUpperCase()) continue;
    longas++;
    if (!_vogal.hasMatch(p) || _consoantesSeguidas.hasMatch(p)) estranhas++;
  }
  return longas > 0 && estranhas * 10 >= longas * 4;
}

bool _palavraRepetida(List<String> palavras) {
  if (palavras.length < 6) return false;
  final distintas = palavras.map((p) => p.toLowerCase()).toSet();
  return distintas.length * 10 < palavras.length * 3;
}
