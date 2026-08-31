import 'package:flutter/material.dart';

import '../../../core/widgets/legal_document_screen.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      titulo: 'Termos de Serviço',
      atualizadoEm: 'agosto de 2026',
      secoes: [
        SecaoLegal(
          titulo: '1. Sobre o serviço',
          paragrafos: [
            'O DivergIA é um aplicativo que compara um texto original com uma '
                'versão editada por Inteligência Artificial, identificando onde o '
                'sentido, a posição ou a intensidade do conteúdo foram alterados, '
                'e sugerindo reescritas mais fiéis ao texto original quando '
                'solicitado.',
          ],
        ),
        SecaoLegal(
          titulo: '2. Sua conta',
          paragrafos: [
            'Você é responsável por manter sua senha em sigilo e por todas as '
                'atividades realizadas na sua conta. As informações fornecidas no '
                'cadastro (nome e e-mail) devem ser verdadeiras.',
            'Você pode alterar seu e-mail, sua senha e sua foto de perfil a '
                'qualquer momento pelo próprio aplicativo, e pode excluir sua '
                'conta quando quiser. A exclusão é permanente.',
          ],
        ),
        SecaoLegal(
          titulo: '3. Uso aceitável',
          paragrafos: [
            'O DivergIA não deve ser usado para analisar conteúdo ilegal, '
                'ofensivo, ou que viole direitos autorais ou de terceiros. '
                'Reservamo-nos o direito de suspender contas que violem estes '
                'termos.',
          ],
        ),
        SecaoLegal(
          titulo: '4. Sobre as análises geradas por IA',
          paragrafos: [
            'As comparações e sugestões de reescrita são geradas por modelos '
                'de linguagem de terceiros e podem, ocasionalmente, conter '
                'imprecisões. O DivergIA é uma ferramenta de apoio à revisão de '
                'texto, não um serviço de garantia editorial. A decisão final '
                'sobre qualquer texto é sempre sua.',
          ],
        ),
        SecaoLegal(
          titulo: '5. Alterações nestes termos',
          paragrafos: [
            'Podemos atualizar estes termos periodicamente. Mudanças '
                'relevantes serão comunicadas dentro do aplicativo.',
          ],
        ),
        SecaoLegal(
          titulo: '6. Contato',
          paragrafos: [
            'Dúvidas sobre estes termos podem ser enviadas para o e-mail de '
                'suporte informado na loja de aplicativos.',
          ],
        ),
      ],
    );
  }
}
