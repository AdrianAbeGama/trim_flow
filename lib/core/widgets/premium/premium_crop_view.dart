import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

/// Recortador premium dentro de la app (estilo Instagram/Facebook): la foto
/// llena un marco fijo y se arrastra/pellizca para encuadrar. Devuelve la ruta
/// de un archivo temporal con la imagen recortada, o null si se cancela.
class PremiumCropView extends StatefulWidget {
  const PremiumCropView({
    super.key,
    required this.sourcePath,
    this.initialAspect = 1.0,
  });

  final String sourcePath;
  final double initialAspect;

  static Future<String?> show(
    BuildContext context, {
    required String sourcePath,
    double initialAspect = 1.0,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PremiumCropView(
          sourcePath: sourcePath,
          initialAspect: initialAspect,
        ),
      ),
    );
  }

  @override
  State<PremiumCropView> createState() => _PremiumCropViewState();
}

class _PremiumCropViewState extends State<PremiumCropView> {
  final _controller = CropController();
  Uint8List? _bytes;
  late double _aspect = widget.initialAspect;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bytes = await File(widget.sourcePath).readAsBytes();
      if (mounted) setState(() => _bytes = bytes);
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _setAspect(double value) {
    if (_aspect == value) return;
    HapticFeedback.selectionClick();
    _controller.aspectRatio = value;
    setState(() => _aspect = value);
  }

  void _done() {
    if (_busy) return;
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);
    _controller.crop();
  }

  Future<void> _onCropped(CropResult result) async {
    if (result is CropSuccess) {
      try {
        final dir = await getTemporaryDirectory();
        final file = File(
            '${dir.path}/crop_${DateTime.now().microsecondsSinceEpoch}.png');
        await file.writeAsBytes(result.croppedImage);
        if (mounted) Navigator.pop(context, file.path);
        return;
      } catch (_) {}
    }
    if (mounted) {
      setState(() => _busy = false);
      AppToast.error(context, 'No se pudo recortar',
          message: 'Intenta de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final bytes = _bytes;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Recortar foto',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: bytes == null
                  ? Center(
                      child: CupertinoActivityIndicator(color: gold, radius: 14))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Crop(
                        image: bytes,
                        controller: _controller,
                        onCropped: _onCropped,
                        aspectRatio: _aspect,
                        baseColor: const Color(0xFF0A0A0A),
                        maskColor: Colors.black.withValues(alpha: 0.62),
                        radius: 14,
                        interactive: true,
                        fixCropRect: true,
                        cornerDotBuilder: (size, edgeAlignment) =>
                            const SizedBox.shrink(),
                        progressIndicator:
                            CupertinoActivityIndicator(color: gold, radius: 14),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 2),
              child: Text(
                'Arrastra y pellizca para ajustar',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AspectChip(
                    icon: Icons.crop_square_rounded,
                    label: 'Cuadrado',
                    selected: _aspect == 1.0,
                    gold: gold,
                    onTap: () => _setAspect(1.0),
                  ),
                  const SizedBox(width: 10),
                  _AspectChip(
                    icon: Icons.crop_portrait_rounded,
                    label: 'Vertical',
                    selected: _aspect != 1.0,
                    gold: gold,
                    onTap: () => _setAspect(4 / 5),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 6, 20, MediaQuery.of(context).viewPadding.bottom + 14),
              child: Row(
                children: [
                  Expanded(
                    child: PremiumPressable(
                      pressedScale: 0.98,
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          'CANCELAR',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: PremiumPressable(
                      pressedScale: 0.98,
                      onTap: _done,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F3EC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.6, color: Colors.black),
                              )
                            : Text(
                                'LISTO',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AspectChip extends StatelessWidget {
  const _AspectChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.gold,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.96,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7F3EC) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: selected
                    ? Colors.black
                    : Colors.white.withValues(alpha: 0.6)),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.inter(
                color: selected
                    ? Colors.black
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
