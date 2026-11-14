import 'package:divergia_app/core/utils/validacao_texto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? validar(String texto) =>
      validarTextoDaAnalise(texto, rotulo: 'texto original');

  group('deve recusar', () {
    final casos = <String, String>{
      'vazio': '   ',
      'uma palavra': 'Ótimo',
      'só números': '123 456 789 2024 99',
      'só símbolos': '!!! ??? ### \$\$\$ %%%',
      'binário': '01101111 01101100 01100001 00100000 01101101 01110101 01101110 01100100',
      'binário sem espaço': '0110100001100101011011000110110001101111',
      'hexadecimal': '63 6f 6e 74 65 20 75 6d 61 20 70 69 61 64 61 20 70 61 72 61',
      'lixo de teclado': 'asdfgh jklqwr zxcvbn qwrtpsd',
      'letra repetida': 'aaaaaaaaaaaaaaaaaaaa',
      'palavra repetida': 'bla bla bla bla bla bla bla bla',
    };
    casos.forEach((nome, texto) {
      test(nome, () => expect(validar(texto), isNotNull, reason: nome));
    });
  });

  group('deve passar', () {
    final casos = <String, String>{
      'frase curta': 'Sou contra.',
      'exemplo da apresentação': 'A maioria das pessoas apenas existe.',
      'com números': 'Em 2024, 72 pessoas testaram o app e 30 eram estudantes.',
      'com palavrão': 'Isso é uma merda.',
      'inglês': 'I strongly disagree with this proposal.',
      'termos técnicos': 'O deploy do backend usa HTTP, SQL e HTML5.',
    };
    casos.forEach((nome, texto) {
      test(nome, () => expect(validar(texto), isNull, reason: nome));
    });
  });

  test('mensagem cita o campo', () {
    expect(
      validarTextoDaAnalise('123 456', rotulo: 'texto editado'),
      contains('texto editado'),
    );
  });

  test('vazio usa a mesma mensagem de antes', () {
    expect(validar(''), 'Cole o texto ou anexe um arquivo');
  });

  test('limparTexto remove invisíveis e espaços sobrando', () {
    expect(
      limparTexto('  Olá​,   mundo﻿!\r\n\r\n\r\nFim  '),
      'Olá, mundo!\n\nFim',
    );
  });

  test('textosIdenticos ignora só espaços', () {
    expect(textosIdenticos('Ele veio.', '  Ele   veio. '), isTrue);
    expect(textosIdenticos('Ele veio.', 'Ele veio?'), isFalse);
  });
}
