import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final MobileScannerController controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _hasScanned = true;
        Navigator.pop(context, code);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Cámara con filtro oscuro premium
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
            child: MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),
          ),

          // Guía de escaneo de código de barras (más horizontal que un QR)
          Center(
            child: Container(
              width: 300,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
                  _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
                  _buildCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
                  _buildCorner(bottom: 0, right: 0, isTop: false, isLeft: false),
                  const _ScanningLineAnimation(),
                ],
              ),
            ),
          ),

          // Texto informativo premium
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'ESCANEANDO CÓDIGO DE BARRAS',
                    style: GoogleFonts.inter(
                      color: context.primaryGold,
                      fontSize: 10,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alinea el código dentro del recuadro',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de volver
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: PremiumBackButton(onTap: () => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: context.primaryGold, width: 2) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: context.primaryGold, width: 2) : BorderSide.none,
            left: isLeft ? BorderSide(color: context.primaryGold, width: 2) : BorderSide.none,
            right: !isLeft ? BorderSide(color: context.primaryGold, width: 2) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(10) : Radius.zero,
            topRight: isTop && !isLeft ? const Radius.circular(10) : Radius.zero,
            bottomLeft: !isTop && isLeft ? const Radius.circular(10) : Radius.zero,
            bottomRight: !isTop && !isLeft ? const Radius.circular(10) : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class _ScanningLineAnimation extends StatefulWidget {
  const _ScanningLineAnimation();

  @override
  State<_ScanningLineAnimation> createState() => _ScanningLineAnimationState();
}

class _ScanningLineAnimationState extends State<_ScanningLineAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryGold;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: 160 * _animationController.value,
          left: 20,
          right: 20,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: accent,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
