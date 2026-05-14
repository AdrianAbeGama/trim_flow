import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/di/injection.dart';

class QrScannerFacade extends StatefulWidget {
  const QrScannerFacade({super.key});

  @override
  State<QrScannerFacade> createState() => _QrScannerFacadeState();
}

class _QrScannerFacadeState extends State<QrScannerFacade> {
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
      if (code != null) {
        // Aceptamos el código de Elite o cualquier UUID
        if (code.contains('-') || code == "1" || code == "2") {
          _hasScanned = true;
          
          // Actualizamos el Tenant
          getIt<TenantThemeBloc>().loadTenant(code);
          
          // Feedback sutil y salida inmediata
          Navigator.pop(context, code);
          break;
        }
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

          // Guía minimalista
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Stack(
                children: [
                  _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
                  _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
                  _buildCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
                  _buildCorner(bottom: 0, right: 0, isTop: false, isLeft: false),
                  const ScanningLineAnimation(),
                ],
              ),
            ),
          ),

          // Texto informativo minimalista
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'ESCANEANDO CÓDIGO QR',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),

          // Botón de cerrar elegante
          Positioned(
            top: 60,
            left: 30,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.white, width: 1.5) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.white, width: 1.5) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.white, width: 1.5) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.white, width: 1.5) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(15) : Radius.zero,
            topRight: isTop && !isLeft ? const Radius.circular(15) : Radius.zero,
            bottomLeft: !isTop && isLeft ? const Radius.circular(15) : Radius.zero,
            bottomRight: !isTop && !isLeft ? const Radius.circular(15) : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class ScanningLineAnimation extends StatefulWidget {
  const ScanningLineAnimation({super.key});

  @override
  State<ScanningLineAnimation> createState() => _ScanningLineAnimationState();
}

class _ScanningLineAnimationState extends State<ScanningLineAnimation> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: 260 * _animationController.value,
          left: 30,
          right: 30,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 10,
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
