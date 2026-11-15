import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(loginControllerProvider.notifier)
        .submit(
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        );
  }

  Future<void> _entrarComGoogle() async {
    await ref.read(loginControllerProvider.notifier).entrarComGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bem-vindo', style: AppTypography.displayLarge(context)),
                const SizedBox(height: 8),
                Text(
                  'Entre na sua conta para analisar a integridade do seu conteúdo.',
                  style: AppTypography.body(context),
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Senha',
                  hint: 'Sua senha secreta',
                  controller: _senhaController,
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Informe sua senha'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/esqueci-senha'),
                    child: Text(
                      'Esqueci minha senha',
                      style: AppTypography.body(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (loginState.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    loginState.errorMessage!,
                    style: AppTypography.body(
                      context,
                    ).copyWith(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Entrar',
                  // Durante o login o botão só fica esmaecido e sem toque, sem spinner.
                  onPressed: loginState.loading ? null : _submit,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: context.colors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'ou continue com',
                        style: AppTypography.caption(context),
                      ),
                    ),
                    Expanded(child: Divider(color: context.colors.border)),
                  ],
                ),
                const SizedBox(height: 16),
                _SocialButton(
                  label: 'Google',
                  icone: 'assets/icon/google-icon.png',
                  carregando: loginState.loading,
                  onTap: _entrarComGoogle,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        'Não tem uma conta?',
                        style: AppTypography.body(context),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: Text(
                          'Criar conta',
                          style: AppTypography.body(context).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icone,
    required this.onTap,
    this.carregando = false,
  });

  final String label;
  final String icone;
  final VoidCallback onTap;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    // Durante o login o botão só fica esmaecido e sem toque, sem spinner.
    return Opacity(
      opacity: carregando ? 0.5 : 1,
      child: InkWell(
        onTap: carregando ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // cacheWidth: o PNG tem 1200 px; decodifica só no tamanho exibido.
              Image.asset(icone, width: 20, height: 20, cacheWidth: 60),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.bodyEmphasis(
                  context,
                ).copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
