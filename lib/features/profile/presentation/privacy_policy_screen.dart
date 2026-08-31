import 'package:flutter/material.dart';

import '../../../core/widgets/legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      titulo: 'Política de Privacidade',
      atualizadoEm: 'agosto de 2026',
      secoes: [
        SecaoLegal(
          titulo: '1. Quais dados coletamos',
          paragrafos: [
            'Nome, e-mail e senha (armazenada apenas como hash, nunca em '
                'texto simples) no cadastro; foto de perfil, se você optar por '
                'enviar uma; e o texto original e o texto editado que você '
                'submete para análise.',
          ],
        ),
        SecaoLegal(
          titulo: '2. Como usamos seus dados',
          paragrafos: [
            'Para autenticar sua conta, processar as comparações de texto '
                'através de modelos de Inteligência Artificial de terceiros '
                '(usados apenas no momento da análise, para gerar a comparação '
                'semântica e as sugestões de reescrita), e enviar e-mails '
                'transacionais (boas-vindas, recuperação de senha).',
          ],
        ),
        SecaoLegal(
          titulo: '3. Retenção do histórico e contribuição para o RAG',
          paragrafos: [
            'O texto das suas análises e os trechos de divergência '
                'identificados ficam salvos no seu histórico, e passam a '
                'compor a base de referência (RAG) usada para melhorar a '
                'qualidade das análises de todos os usuários do DivergIA.',
            'Você pode excluir seu histórico de análises ou sua conta inteira '
                'a qualquer momento pelo aplicativo. A exclusão é permanente.',
          ],
        ),
        SecaoLegal(
          titulo: '4. Compartilhamento com terceiros',
          paragrafos: [
            'Usamos provedores de Inteligência Artificial (para geração de '
                'texto e para embeddings semânticos) apenas para processar o '
                'conteúdo no momento da análise. Não vendemos seus dados '
                'pessoais a terceiros.',
          ],
        ),
        SecaoLegal(
          titulo: '5. Segurança',
          paragrafos: [
            'Senhas são armazenadas com hash criptográfico (bcrypt), toda a '
                'comunicação com o servidor é feita por conexão criptografada '
                '(HTTPS), e o acesso à sua conta usa tokens de sessão de curta '
                'duração.',
          ],
        ),
        SecaoLegal(
          titulo: '6. Seus direitos',
          paragrafos: [
            'A qualquer momento, você pode: alterar seu e-mail, sua senha e '
                'sua foto de perfil; excluir seu histórico de análises; ou '
                'excluir sua conta e todos os dados associados a ela, de '
                'forma permanente, tudo diretamente pelo aplicativo, na tela '
                'de Perfil.',
          ],
        ),
        SecaoLegal(
          titulo: '7. Contato',
          paragrafos: [
            'Dúvidas sobre esta política podem ser enviadas para o e-mail de '
                'suporte informado na loja de aplicativos.',
          ],
        ),
      ],
    );
  }
}
