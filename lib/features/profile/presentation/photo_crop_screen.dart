import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Tela de recorte da foto de perfil — aberta logo depois de escolher a
/// imagem, antes de enviar pro servidor. Sem referência no Figma (o
/// protótipo não cobre esse fluxo); usa um recorte circular fixo (1:1),
/// já que é exatamente assim que o avatar aparece no app.
class PhotoCropScreen extends StatefulWidget {
  const PhotoCropScreen({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<PhotoCropScreen> createState() => _PhotoCropScreenState();
}

class _PhotoCropScreenState extends State<PhotoCropScreen> {
  final _controller = CropController();
  bool _recortando = false;

  void _confirmar() {
    setState(() => _recortando = true);
    _controller.crop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      LucideIcons.x,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Ajustar foto',
                    style: AppTypography.cardTitle(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: _recortando ? null : _confirmar,
                    child: Text(
                      'Concluir',
                      style: AppTypography.bodyEmphasis(context).copyWith(
                        color: _recortando
                            ? Colors.white38
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Crop(
                image: widget.bytes,
                controller: _controller,
                withCircleUi: true,
                baseColor: Colors.black,
                maskColor: Colors.black.withValues(alpha: 0.6),
                progressIndicator: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                onCropped: (result) {
                  switch (result) {
                    case CropSuccess(:final croppedImage):
                      context.pop(croppedImage);
                    case CropFailure(:final cause):
                      setState(() => _recortando = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Não foi possível recortar a foto: $cause',
                          ),
                        ),
                      );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Arraste e ajuste o zoom pra enquadrar sua foto',
                style: AppTypography.caption(
                  context,
                ).copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
