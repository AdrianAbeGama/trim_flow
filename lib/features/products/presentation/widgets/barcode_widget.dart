import 'package:flutter/material.dart';

/// Código de barras dibujado (compartido entre el comprobante de productos y el
/// de pedidos). Las barras siempre son negras para que sea escaneable; en
/// tickets oscuros se coloca sobre un azulejo blanco.
class BarcodeWidget extends StatelessWidget {
  const BarcodeWidget({
    super.key,
    required this.code,
    this.height = 50.0,
    this.width = 240.0,
  });

  final String code;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height,
          width: width,
          child: CustomPaint(painter: _DynamicBarcodePainter(code: code)),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            code.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

/// Muestra el código de barras en grande (al tocar el comprobante).
Future<void> showBarcodeZoom(BuildContext context, String code) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar',
    barrierColor: Colors.black.withValues(alpha: 0.92),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, _, _) => GestureDetector(
      onTap: () => Navigator.of(ctx).pop(),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: BarcodeWidget(code: code, height: 120, width: 280),
        ),
      ),
    ),
  );
}

class _DynamicBarcodePainter extends CustomPainter {
  _DynamicBarcodePainter({required this.code});

  final String code;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final String sanitized = code.toUpperCase();

    const double thinWidth = 1.5;
    const double thickWidth = 3.5;
    const double spaceThin = 1.5;
    const double spaceThick = 3.5;

    double totalWidth = 0.0;
    totalWidth += thinWidth + spaceThin + thinWidth + spaceThin;
    for (int i = 0; i < sanitized.length; i++) {
      final int charVal = sanitized.codeUnitAt(i);
      for (int bit = 0; bit < 6; bit++) {
        final bool isBar = bit % 2 == 0;
        final bool isWide = ((charVal >> bit) & 1) == 1;
        if (isBar) {
          totalWidth += isWide ? thickWidth : thinWidth;
        } else {
          totalWidth += isWide ? spaceThick : spaceThin;
        }
      }
      totalWidth += spaceThin;
    }
    totalWidth += thinWidth + spaceThin + thinWidth;

    double currentX = (size.width - totalWidth) / 2;
    if (currentX < 0) currentX = 0.0;

    void drawBar(double width) {
      canvas.drawRect(Rect.fromLTWH(currentX, 0, width, size.height), paint);
      currentX += width;
    }

    void drawSpace(double width) {
      currentX += width;
    }

    drawBar(thinWidth);
    drawSpace(spaceThin);
    drawBar(thinWidth);
    drawSpace(spaceThin);

    for (int i = 0; i < sanitized.length; i++) {
      final int charVal = sanitized.codeUnitAt(i);
      for (int bit = 0; bit < 6; bit++) {
        final bool isBar = bit % 2 == 0;
        final bool isWide = ((charVal >> bit) & 1) == 1;
        if (isBar) {
          drawBar(isWide ? thickWidth : thinWidth);
        } else {
          drawSpace(isWide ? spaceThick : spaceThin);
        }
      }
      drawSpace(spaceThin);
    }

    drawBar(thinWidth);
    drawSpace(spaceThin);
    drawBar(thinWidth);
  }

  @override
  bool shouldRepaint(covariant _DynamicBarcodePainter oldDelegate) => oldDelegate.code != code;
}
