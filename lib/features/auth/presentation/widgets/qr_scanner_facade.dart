import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class QrScannerFacade extends StatefulWidget {
  const QrScannerFacade({super.key});

  @override
  State<QrScannerFacade> createState() => _QrScannerFacadeState();
}

class _QrScannerFacadeState extends State<QrScannerFacade> {
  bool _isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo oscuro simulando cámara apagada o blur
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Guía del escáner
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: context.primaryGold.withValues(alpha: 0.5), width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      // Esquinas resaltadas
                      _buildCorner(top: 0, left: 0, borderRadius: const BorderRadius.only(topLeft: Radius.circular(30))),
                      _buildCorner(top: 0, right: 0, borderRadius: const BorderRadius.only(topRight: Radius.circular(30))),
                      _buildCorner(bottom: 0, left: 0, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30))),
                      _buildCorner(bottom: 0, right: 0, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30))),
                      
                      // Línea de escaneo animada (simulada)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Positioned(
                            top: 250 * value,
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: context.primaryGold,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.primaryGold.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        onEnd: () {}, // Re-loop logic would go here if it was a real animation controller
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Escanea el código QR de tu barbero',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Controles superiores
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                ),
                const Text(
                  'ESCANEAR QR',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                IconButton(
                  onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isFlashOn ? context.primaryGold : Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right, required BorderRadius borderRadius}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.primaryGold,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
