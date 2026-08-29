import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/models/arquivo_selecionado.dart';
import 'nova_analise_controller.dart';
import 'widgets/analise_input_field.dart';
import 'widgets/analysis_loading_view.dart';

const _extensoesAceitas = [
  'pdf',
  'docx',
  'doc',
  'txt',
  'md',
  'pptx',
  'html',
  'htm',
];

/// Tela "Nova análise" — fidelidade ao frame "new-analysis-input" do
/// Figma (o carregamento fiel a "analysis-loading" fica em
/// [AnalysisLoadingView]).
class NewAnalysisScreen extends ConsumerStatefulWidget {
  const NewAnalysisScreen({super.key});

  @override
  ConsumerState<NewAnalysisScreen> createState() => _NewAnalysisScreenState();
}

class _NewAnalysisScreenState extends ConsumerState<NewAnalysisScreen> {
  final _originalController = TextEditingController();
  final _editadoController = TextEditingController();
  ArquivoSelecionado? _arquivoOriginal;
  ArquivoSelecionado? _arquivoEditado;
  String? _erroOriginal;
  String? _erroEditado;

  @override
  void dispose() {
    _originalController.dispose();
    _editadoController.dispose();
    super.dispose();
  }

  Future<ArquivoSelecionado?> _escolherArquivo() async {
    final arquivos = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensoesAceitas,
    );
    if (arquivos.isEmpty) return null;
    final arquivo = arquivos.first;
    final bytes = await arquivo.readAsBytes();
    return ArquivoSelecionado(nome: arquivo.name, bytes: bytes);
  }

  Future<void> _anexarOriginal() async {
    final arquivo = await _escolherArquivo();
    if (arquivo == null) return;
    setState(() {
      _arquivoOriginal = arquivo;
      _originalController.clear();
      _erroOriginal = null;
    });
  }

  Future<void> _anexarEditado() async {
    final arquivo = await _escolherArquivo();
    if (arquivo == null) return;
    setState(() {
      _arquivoEditado = arquivo;
      _editadoController.clear();
      _erroEditado = null;
    });
  }

  Future<void> _submit() async {
    final temOriginal =
        _arquivoOriginal != null || _originalController.text.trim().isNotEmpty;
    final temEditado =
        _arquivoEditado != null || _editadoController.text.trim().isNotEmpty;

    setState(() {
      _erroOriginal = temOriginal ? null : 'Cole o texto ou anexe um arquivo';
      _erroEditado = temEditado ? null : 'Cole o texto ou anexe um arquivo';
    });
    if (!temOriginal || !temEditado) return;

    final resultado = await ref
        .read(novaAnaliseControllerProvider.notifier)
        .analisar(
          textoOriginal: _arquivoOriginal == null
              ? _originalController.text.trim()
              : null,
          arquivoOriginal: _arquivoOriginal,
          textoEditado: _arquivoEditado == null
              ? _editadoController.text.trim()
              : null,
          arquivoEditado: _arquivoEditado,
        );

    if (resultado != null && mounted) {
      context.pushReplacement('/historico/${resultado.analiseId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(novaAnaliseControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: state.loading
            ? const AnalysisLoadingView()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nova análise',
                      style: AppTypography.titleMedium.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Identifique alterações feitas pela IA',
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 16),
                    AnaliseInputField(
                      label: 'Texto original',
                      hint: 'Cole aqui o texto que você escreveu...',
                      controller: _originalController,
                      arquivo: _arquivoOriginal,
                      errorText: _erroOriginal,
                      onAnexar: _anexarOriginal,
                      onRemoverArquivo: () =>
                          setState(() => _arquivoOriginal = null),
                    ),
                    const SizedBox(height: 16),
                    AnaliseInputField(
                      label: 'Texto editado pela IA',
                      hint: 'Cole aqui a versão devolvida pela IA...',
                      controller: _editadoController,
                      arquivo: _arquivoEditado,
                      errorText: _erroEditado,
                      onAnexar: _anexarEditado,
                      onRemoverArquivo: () =>
                          setState(() => _arquivoEditado = null),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    PrimaryButton(label: 'Analisar textos', onPressed: _submit),
                  ],
                ),
              ),
      ),
    );
  }
}
