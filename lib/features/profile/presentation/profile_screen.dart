import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/primary_button.dart';
import 'profile_controller.dart';

const _extensoesImagemAceitas = ['jpg', 'jpeg', 'png', 'webp'];

/// Tela "Meu perfil" — fidelidade ao frame "profile-settings" do Figma.
///
/// O Figma mostra "Período de retenção de dados" com um valor fixo de "30
/// dias" — removido por decisão explícita: histórico e contribuição para o
/// RAG são sempre ativos agora, sem opção de opt-out por usuário.
///
/// "Excluir conta" também não aparece nesse frame do Figma, mas o roadmap
/// exige essa ação e o backend já tem o endpoint — foi adicionada como uma
/// segunda ação destrutiva ao lado de "Excluir histórico", seguindo a
/// mesma linguagem visual (texto vermelho + ícone de alerta).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _avisarEmBreve(BuildContext context, String recurso) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$recurso ainda não disponível.')));
  }

  Future<bool> _confirmar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    required String textoConfirmar,
  }) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              textoConfirmar,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    return confirmado ?? false;
  }

  Future<void> _excluirHistorico(BuildContext context, WidgetRef ref) async {
    final confirmado = await _confirmar(
      context,
      titulo: 'Excluir histórico de análises',
      mensagem:
          'Todas as suas análises salvas serão apagadas permanentemente. Essa ação não pode ser desfeita.',
      textoConfirmar: 'Excluir',
    );
    if (!confirmado || !context.mounted) return;

    final sucesso = await ref
        .read(profileControllerProvider.notifier)
        .excluirHistorico();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Histórico excluído.'
              : 'Não foi possível excluir o histórico. Tente novamente.',
        ),
      ),
    );
  }

  Future<void> _excluirConta(BuildContext context, WidgetRef ref) async {
    final confirmado = await _confirmar(
      context,
      titulo: 'Excluir conta',
      mensagem:
          'Sua conta e todos os seus dados serão apagados permanentemente. Essa ação não pode ser desfeita.',
      textoConfirmar: 'Excluir conta',
    );
    if (!confirmado || !context.mounted) return;

    final sucesso = await ref
        .read(profileControllerProvider.notifier)
        .excluirConta();
    if (!sucesso && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir a conta. Tente novamente.'),
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmado = await _confirmar(
      context,
      titulo: 'Sair da conta',
      mensagem: 'Você precisará fazer login novamente para continuar usando o app.',
      textoConfirmar: 'Sair',
    );
    if (!confirmado || !context.mounted) return;

    await ref.read(profileControllerProvider.notifier).logout();
  }

  Future<void> _trocarFoto(BuildContext context, WidgetRef ref) async {
    final arquivos = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensoesImagemAceitas,
    );
    if (arquivos.isEmpty) return;
    final arquivo = arquivos.first;
    final bytes = await arquivo.readAsBytes();
    if (!context.mounted) return;

    // O recorte sempre devolve PNG (o pacote não expõe outro formato de
    // saída), independente da extensão do arquivo original escolhido.
    final bytesRecortados = await context.push<Uint8List>(
      '/perfil/cortar-foto',
      extra: bytes,
    );
    if (bytesRecortados == null || !context.mounted) return;

    final erro = await ref
        .read(profileControllerProvider.notifier)
        .atualizarFotoPerfil(bytes: bytesRecortados, nomeArquivo: 'foto.png');
    if (!context.mounted) return;
    if (erro != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(erro)));
    }
  }

  Future<void> _abrirAlterarSenha(BuildContext context) {
    return showAppBottomSheet<void>(
      context,
      builder: (context) => const _AlterarSenhaSheet(),
    );
  }

  Future<void> _abrirAlterarEmail(BuildContext context) {
    return showAppBottomSheet<void>(
      context,
      builder: (context) => const _AlterarEmailSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final colors = context.colors;
    final modoEscuro = ref.watch(themeModeControllerProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.screenBackground,
      body: SafeArea(
        child: state.loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : state.errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(context),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () =>
                            ref.read(profileControllerProvider.notifier).carregar(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  Text(
                    'Meu perfil',
                    style: AppTypography.titleMedium(
                      context,
                    ).copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gerencie preferências da sua conta',
                    style: AppTypography.body(context),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    child: _AvatarCard(
                      nome: state.usuario!.nome,
                      email: state.usuario!.email,
                      fotoUrl: state.usuario!.fotoUrl,
                      onTrocarFoto: () => _trocarFoto(context, ref),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    atraso: atrasoEmCascata(1),
                    child: _SettingsGroup(
                      titulo: 'Conta',
                      children: [
                        _SettingsRow(
                          label: 'Alterar e-mail',
                          onTap: () => _abrirAlterarEmail(context),
                          trailing: Icon(
                            LucideIcons.chevronRight,
                            size: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                        _SettingsRow(
                          label: 'Alterar senha',
                          onTap: () => _abrirAlterarSenha(context),
                          trailing: Icon(
                            LucideIcons.chevronRight,
                            size: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    atraso: atrasoEmCascata(2),
                    child: _SettingsGroup(
                      titulo: 'Configurações',
                      children: [
                        _SettingsRow(
                          label: 'Notificações push',
                          trailing: Switch(
                            value: false,
                            onChanged: (_) =>
                                _avisarEmBreve(context, 'Notificações push'),
                          ),
                        ),
                        _SettingsRow(
                          label: 'Modo escuro',
                          trailing: Switch(
                            value: modoEscuro,
                            onChanged: (valor) => ref
                                .read(themeModeControllerProvider.notifier)
                                .alternar(valor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    atraso: atrasoEmCascata(3),
                    child: _SettingsGroup(
                      titulo: 'Privacidade',
                      children: [
                        _DangerRow(
                          label: 'Excluir histórico de análises',
                          onTap: () => _excluirHistorico(context, ref),
                        ),
                        _DangerRow(
                          label: 'Excluir conta',
                          onTap: () => _excluirConta(context, ref),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    atraso: atrasoEmCascata(4),
                    child: _SettingsGroup(
                      titulo: 'Sobre o App',
                      children: [
                        _SettingsRow(
                          label: 'Termos de Serviço',
                          onTap: () => context.push('/termos-de-servico'),
                          trailing: Icon(
                            LucideIcons.chevronRight,
                            size: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                        _SettingsRow(
                          label: 'Política de Privacidade',
                          onTap: () =>
                              context.push('/politica-de-privacidade'),
                          trailing: Icon(
                            LucideIcons.chevronRight,
                            size: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                        _SettingsRow(
                          label: 'Versão',
                          trailing: Text(
                            'v1.0.0',
                            style: AppTypography.caption(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    atraso: atrasoEmCascata(5),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _logout(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Sair da conta',
                          style: AppTypography.label(
                            context,
                          ).copyWith(color: AppColors.danger),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({
    required this.nome,
    required this.email,
    required this.fotoUrl,
    required this.onTrocarFoto,
  });

  final String nome;
  final String email;
  final String? fotoUrl;
  final VoidCallback onTrocarFoto;

  String get _iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    final primeira = partes.first[0];
    final ultima = partes.length > 1 ? partes.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onTrocarFoto,
            customBorder: const CircleBorder(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    shape: BoxShape.circle,
                    image: fotoUrl == null
                        ? null
                        : DecorationImage(
                            image: NetworkImage(fotoUrl!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  alignment: Alignment.center,
                  child: fotoUrl != null
                      ? null
                      : Text(
                          _iniciais,
                          style: AppTypography.cardTitle(
                            context,
                          ).copyWith(fontSize: 20, color: AppColors.primary),
                        ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.background, width: 2),
                    ),
                    child: const Icon(
                      LucideIcons.camera,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: AppTypography.cardTitle(context)),
                const SizedBox(height: 2),
                Text(email, style: AppTypography.caption(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlterarSenhaSheet extends ConsumerStatefulWidget {
  const _AlterarSenhaSheet();

  @override
  ConsumerState<_AlterarSenhaSheet> createState() => _AlterarSenhaSheetState();
}

class _AlterarSenhaSheetState extends ConsumerState<_AlterarSenhaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro = await ref
        .read(profileControllerProvider.notifier)
        .alterarSenha(
          senhaAtual: _senhaAtualController.text,
          novaSenha: _novaSenhaController.text,
        );
    if (!mounted) return;
    if (erro != null) {
      setState(() {
        _enviando = false;
        _erro = erro;
      });
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Senha alterada.')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alterar senha', style: AppTypography.cardTitle(context)),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Senha atual',
              hint: 'Sua senha atual',
              controller: _senhaAtualController,
              obscureText: true,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Informe sua senha atual'
                  : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Nova senha',
              hint: 'Crie uma senha forte',
              controller: _novaSenhaController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a nova senha';
                }
                if (value.length < 8) {
                  return 'A senha deve ter ao menos 8 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Confirmar nova senha',
              hint: 'Repita a nova senha',
              controller: _confirmarSenhaController,
              obscureText: true,
              validator: (value) => value != _novaSenhaController.text
                  ? 'As senhas não coincidem'
                  : null,
            ),
            if (_erro != null) ...[
              const SizedBox(height: 8),
              Text(
                _erro!,
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Salvar nova senha',
              loading: _enviando,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlterarEmailSheet extends ConsumerStatefulWidget {
  const _AlterarEmailSheet();

  @override
  ConsumerState<_AlterarEmailSheet> createState() => _AlterarEmailSheetState();
}

class _AlterarEmailSheetState extends ConsumerState<_AlterarEmailSheet> {
  final _formKey = GlobalKey<FormState>();
  final _novoEmailController = TextEditingController();
  final _senhaAtualController = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _novoEmailController.dispose();
    _senhaAtualController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro = await ref
        .read(profileControllerProvider.notifier)
        .alterarEmail(
          novoEmail: _novoEmailController.text.trim(),
          senhaAtual: _senhaAtualController.text,
        );
    if (!mounted) return;
    if (erro != null) {
      setState(() {
        _enviando = false;
        _erro = erro;
      });
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('E-mail alterado.')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alterar e-mail', style: AppTypography.cardTitle(context)),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Novo e-mail',
              hint: 'novo@email.com',
              controller: _novoEmailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o novo e-mail';
                }
                if (!value.contains('@')) return 'E-mail inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Senha atual',
              hint: 'Confirme sua senha',
              controller: _senhaAtualController,
              obscureText: true,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Informe sua senha atual'
                  : null,
            ),
            if (_erro != null) ...[
              const SizedBox(height: 8),
              Text(
                _erro!,
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Salvar novo e-mail',
              loading: _enviando,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.titulo, required this.children});

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(),
            style: AppTypography.cardTitle(
              context,
            ).copyWith(fontSize: 12, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          for (final (indice, filho) in children.indexed) ...[
            if (indice > 0)
              Divider(height: 1, thickness: 1, color: context.colors.border),
            filho,
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.trailing, this.onTap});

  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(
                  context,
                ).copyWith(color: context.colors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _DangerRow extends StatelessWidget {
  const _DangerRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(context).copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              LucideIcons.alertTriangle,
              size: 14,
              color: AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }
}

