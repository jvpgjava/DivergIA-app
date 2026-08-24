import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'recuperar_senha_controller.dart';

/// Sem referência no Figma (protótipo não cobre recuperação de senha) —
/// segue a mesma linguagem visual das telas de login/cadastro.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(recuperarSenhaControllerProvider.notifier)
        .submit(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recuperarSenhaControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
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
                        color: AppColors.surfaceInput,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.chevronLeft, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Esqueci minha senha',
                style: AppTypography.displayLarge.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                'Informe seu e-mail e enviaremos um código para redefinir sua senha.',
                style: AppTypography.body,
              ),
              const SizedBox(height: 24),
              if (state.enviado)
                Text(
                  'Se esse e-mail estiver cadastrado, você vai receber um código em instantes.',
                  style: AppTypography.bodyEmphasis,
                )
              else
                Form(
                  key: _formKey,
                  child: AppTextField(
                    label: 'E-mail',
                    hint: 'seu@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe seu e-mail';
                      }
                      if (!value.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: AppTypography.body.copyWith(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 20),
              if (state.enviado)
                PrimaryButton(
                  label: 'Já tenho um código',
                  onPressed: () => context.push('/redefinir-senha'),
                )
              else
                PrimaryButton(
                  label: 'Enviar código',
                  loading: state.loading,
                  onPressed: _submit,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
