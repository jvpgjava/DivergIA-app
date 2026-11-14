import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/screen_back_header.dart';
import '../../../core/utils/validacao_texto.dart';
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
  void initState() {
    super.initState();
    _originalController.addListener(_aoEditar);
    _editadoController.addListener(_aoEditar);
  }

  @override
  void dispose() {
    _originalController.dispose();
    _editadoController.dispose();
    super.dispose();
  }

  void _aoEditar() {
    ref.read(novaAnaliseControllerProvider.notifier).limparErros();
    if (_erroOriginal != null || _erroEditado != null) {
      setState(() {
        _erroOriginal = null;
        _erroEditado = null;
      });
    }
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
    FocusScope.of(context).unfocus();
    final controller = ref.read(novaAnaliseControllerProvider.notifier);
    controller.limparErros();

    // Arquivos só podem ser validados pelo servidor, depois da extração do texto.
    var erroOriginal = _arquivoOriginal != null
        ? null
        : validarTextoDaAnalise(
            _originalController.text,
            rotulo: 'texto original',
          );
    var erroEditado = _arquivoEditado != null
        ? null
        : validarTextoDaAnalise(
            _editadoController.text,
            rotulo: 'texto editado',
          );
    if (erroOriginal == null &&
        erroEditado == null &&
        _arquivoOriginal == null &&
        _arquivoEditado == null &&
        textosIdenticos(_originalController.text, _editadoController.text)) {
      erroEditado =
          'O texto editado é igual ao original: não há edição para comparar.';
    }

    setState(() {
      _erroOriginal = erroOriginal;
      _erroEditado = erroEditado;
    });
    if (erroOriginal != null || erroEditado != null) return;

    final resultado = await controller.analisar(
      textoOriginal: _arquivoOriginal == null
          ? limparTexto(_originalController.text)
          : null,
      arquivoOriginal: _arquivoOriginal,
      textoEditado: _arquivoEditado == null
          ? limparTexto(_editadoController.text)
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
                    const ScreenBackHeader(titulo: 'Nova análise'),
                    const SizedBox(height: 4),
                    Text(
                      'Identifique alterações feitas pela IA',
                      style: AppTypography.body(context),
                    ),
                    const SizedBox(height: 16),
                    AnaliseInputField(
                      label: 'Texto original',
                      hint: 'Cole aqui o texto que você escreveu...',
                      controller: _originalController,
                      arquivo: _arquivoOriginal,
                      errorText: _erroOriginal ?? state.erroOriginal,
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
                      errorText: _erroEditado ?? state.erroEditado,
                      onAnexar: _anexarEditado,
                      onRemoverArquivo: () =>
                          setState(() => _arquivoEditado = null),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage!,
                        style: AppTypography.body(
                          context,
                        ).copyWith(color: AppColors.danger),
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
