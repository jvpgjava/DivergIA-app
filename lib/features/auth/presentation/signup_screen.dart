import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'signup_controller.dart';

/// Tela de cadastro — fidelidade ao frame "signup" do Figma.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _termosAceitos = false;
  bool _tentouEnviarSemAceitarTermos = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formValido = _formKey.currentState!.validate();
    if (!_termosAceitos) {
      setState(() => _tentouEnviarSemAceitarTermos = true);
    }
    if (!formValido || !_termosAceitos) return;

    await ref
        .read(signupControllerProvider.notifier)
        .submit(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                          color: AppColors.surfaceInput,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.chevronLeft, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Criar nova conta',
                      style: AppTypography.titleMedium.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Junte-se à DivergIA',
                  style: AppTypography.displayLarge.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  'Analise e corrija os desvios de sentido criados por revisões de IAs.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Nome completo',
                  hint: 'Seu nome',
                  controller: _nomeController,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Informe seu nome'
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
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
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Senha',
                  hint: 'Crie uma senha forte',
                  controller: _senhaController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe uma senha';
                    }
                    if (value.length < 8) {
                      return 'A senha deve ter ao menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Confirmar Senha',
                  hint: 'Repita sua senha',
                  controller: _confirmarSenhaController,
                  obscureText: true,
                  validator: (value) => value != _senhaController.text
                      ? 'As senhas não coincidem'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCheckbox(
                      value: _termosAceitos,
                      onChanged: (value) => setState(() {
                        _termosAceitos = value;
                        _tentouEnviarSemAceitarTermos = false;
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: AppTypography.caption.copyWith(fontSize: 13),
                          children: [
                            const TextSpan(text: 'Li e concordo com os '),
                            TextSpan(
                              text: 'Termos de Serviço',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' e a '),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_tentouEnviarSemAceitarTermos) ...[
                  const SizedBox(height: 6),
                  Text(
                    'É preciso aceitar os termos para continuar.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
                if (signupState.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    signupState.errorMessage!,
                    style: AppTypography.body.copyWith(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Criar conta',
                  loading: signupState.loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: [
                    Text('Já tem cadastro?', style: AppTypography.body),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Fazer login',
                        style: AppTypography.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
