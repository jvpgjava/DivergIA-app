import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_mode_controller.dart';
import 'profile_controller.dart';

/// Tela "Meu perfil" — fidelidade ao frame "profile-settings" do Figma.
///
/// O Figma mostra "Período de retenção de dados" com um valor fixo de "30
/// dias", mas o backend só tem um booleano real (manter histórico ou não,
/// via `/api/consentimento`) — não existe uma configuração de dias. Por
/// decisão explícita, essa linha foi substituída pelo "Status de
/// consentimento" (que já é real) em vez de inventar um número.
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

  Future<void> _abrirConsentimento(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _ConsentimentoSheet(),
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
                  _AvatarCard(nome: state.usuario!.nome, email: state.usuario!.email),
                  const SizedBox(height: 16),
                  _SettingsGroup(
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
                  const SizedBox(height: 16),
                  _SettingsGroup(
                    titulo: 'Privacidade',
                    children: [
                      _SettingsRow(
                        label: 'Status de consentimento',
                        onTap: () => _abrirConsentimento(context, ref),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.consentimento!.manterHistorico
                                  ? 'Ativo'
                                  : 'Inativo',
                              style: AppTypography.caption(context),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 14,
                              color: colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
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
                  const SizedBox(height: 16),
                  _SettingsGroup(
                    titulo: 'Sobre o App',
                    children: [
                      _SettingsRow(
                        label: 'Termos de Serviço',
                        onTap: () => _avisarEmBreve(context, 'Termos de Serviço'),
                        trailing: Icon(
                          LucideIcons.chevronRight,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                      _SettingsRow(
                        label: 'Política de Privacidade',
                        onTap: () =>
                            _avisarEmBreve(context, 'Política de Privacidade'),
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
                  const SizedBox(height: 16),
                  SizedBox(
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
                ],
              ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.nome, required this.email});

  final String nome;
  final String email;

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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.primaryTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _iniciais,
              style: AppTypography.cardTitle(
                context,
              ).copyWith(fontSize: 20, color: AppColors.primary),
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
          ...children,
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

class _ConsentimentoSheet extends ConsumerWidget {
  const _ConsentimentoSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentimento = ref.watch(profileControllerProvider).consentimento;
    final colors = context.colors;

    if (consentimento == null) return const SizedBox.shrink();

    void atualizar({bool? manterHistorico, bool? contribuirParaRag}) {
      ref
          .read(profileControllerProvider.notifier)
          .atualizarConsentimento(
            manterHistorico: manterHistorico ?? consentimento.manterHistorico,
            contribuirParaRag:
                contribuirParaRag ?? consentimento.contribuirParaRag,
          );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status de consentimento', style: AppTypography.cardTitle(context)),
          const SizedBox(height: 4),
          Text(
            'Controle o que o DivergIA guarda sobre suas análises.',
            style: AppTypography.body(context),
          ),
          const SizedBox(height: 16),
          _ConsentimentoRow(
            label: 'Manter histórico das análises',
            value: consentimento.manterHistorico,
            onChanged: (valor) => atualizar(manterHistorico: valor),
          ),
          _ConsentimentoRow(
            label: 'Contribuir para a base de referência (RAG)',
            value: consentimento.contribuirParaRag,
            onChanged: (valor) => atualizar(contribuirParaRag: valor),
          ),
          const SizedBox(height: 8),
          Text(
            'Concedido em ${consentimento.concedidoEm.toLocal()}'.split('.').first,
            style: AppTypography.caption(context).copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ConsentimentoRow extends StatelessWidget {
  const _ConsentimentoRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: AppTypography.body(context)),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
