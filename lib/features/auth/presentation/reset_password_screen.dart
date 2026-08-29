import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'redefinir_senha_controller.dart';

/// Sem referência no Figma — o e-mail de recuperação envia um código
/// (não um link/deep link), então a pessoa cola esse código aqui junto
/// com a nova senha.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(redefinirSenhaControllerProvider.notifier)
        .submit(
          token: _tokenController.text.trim(),
          novaSenha: _novaSenhaController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(redefinirSenhaControllerProvider);

    ref.listen(redefinirSenhaControllerProvider, (previous, next) {
      if (next.redefinido) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha redefinida. Faça login com a nova senha.'),
          ),
        );
        context.go('/login');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.colors.surfaceInput,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.chevronLeft, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Redefinir senha',
                  style: AppTypography.displayLarge(
                    context,
                  ).copyWith(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cole o código recebido por e-mail e escolha uma nova senha.',
                  style: AppTypography.body(context),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Código',
                  hint: 'Código recebido por e-mail',
                  controller: _tokenController,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Informe o código'
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
                  label: 'Confirmar senha',
                  hint: 'Repita a nova senha',
                  controller: _confirmarSenhaController,
                  obscureText: true,
                  validator: (value) => value != _novaSenhaController.text
                      ? 'As senhas não coincidem'
                      : null,
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: AppTypography.body(
                      context,
                    ).copyWith(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Redefinir senha',
                  loading: state.loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
