import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';

class ProductPurchaseSuccessView extends StatefulWidget {
  final CartState cartState;
  final String paymentMethod;
  final VoidCallback onGoHome;
  final VoidCallback onViewOrders;

  const ProductPurchaseSuccessView({
    super.key,
    required this.cartState,
    required this.paymentMethod,
    required this.onGoHome,
    required this.onViewOrders,
  });

  @override
  State<ProductPurchaseSuccessView> createState() => _ProductPurchaseSuccessViewState();
}

class _ProductPurchaseSuccessViewState extends State<ProductPurchaseSuccessView> {
  late ConfettiController _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _shareTicketImage() async {
    try {
      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 50),
      );
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imageFile = File('${directory.path}/ticket_trimflow.png');
        await imageFile.writeAsBytes(image);

        // ignore: deprecated_member_use
        await Share.shareXFiles([XFile(imageFile.path)]);
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),
                  
                  Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      color: Colors.black,
                      child: _buildJaggedTicket(context),
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      Expanded(
                        child: PremiumPressable(
                          pressedScale: 0.97,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _shareTicketImage();
                          },
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.ios_share_rounded, size: 17, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('COMPARTIR', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: PremiumPressable(
                          pressedScale: 0.97,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            widget.onViewOrders();
                          },
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F3EC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.receipt_long_rounded, size: 17, color: Colors.black),
                                const SizedBox(width: 8),
                                Text('VER MIS PEDIDOS', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.6, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PremiumPressable(
                    pressedScale: 0.98,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onGoHome();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Ir al inicio',
                        style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [context.primaryGold, Colors.white],
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJaggedTicket(BuildContext context) {
    final firstProduct = widget.cartState.items.isNotEmpty ? widget.cartState.items.first.product : null;
    final barcodeToShow = (firstProduct != null && firstProduct.barcode.isNotEmpty)
        ? firstProduct.barcode
        : (firstProduct != null ? firstProduct.id : 'TF-${100000 + Random().nextInt(900000)}');

    return ClipPath(
      clipper: _TicketClipper(),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.primaryGold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            const Text(
              'PAGO EXITOSO',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 24),
            
            _buildDetailRow('FECHA', DateFormat("dd / MM / yyyy").format(DateTime.now())),
            const SizedBox(height: 12),
            _buildDetailRow('MÉTODO', widget.paymentMethod.toUpperCase()),
            
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PRODUCTOS', style: TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...widget.cartState.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}X ${item.product.name.toUpperCase()}', 
                          style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'S/ ${(item.product.price * item.quantity).toStringAsFixed(2)}', 
                        style: const TextStyle(color: Colors.black54, fontSize: 11)
                      ),
                    ],
                  ),
                )),
              ],
            ),

            const SizedBox(height: 20),
            _buildDashedLine(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL PAGADO', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
                Text(
                  'S/ ${widget.cartState.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: context.primaryGold, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),

            const SizedBox(height: 36),
            
            // TAREA 5: Componente de código de barras centrado y dinámico
            BarcodeWidget(code: barcodeToShow),
            
            const SizedBox(height: 20),
            const Text(
              'GRACIAS POR TU PREFERENCIA',
              style: TextStyle(color: Colors.black26, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        Text(value, style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.black12,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class BarcodeWidget extends StatelessWidget {
  final String code;
  final double height;

  const BarcodeWidget({
    super.key,
    required this.code,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height,
          width: 240,
          child: CustomPaint(
            painter: _DynamicBarcodePainter(code: code),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 2.0), // Compensar el letterSpacing final
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

class _DynamicBarcodePainter extends CustomPainter {
  final String code;

  _DynamicBarcodePainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final String sanitized = code.toUpperCase();
    
    // Dimensiones de barra
    const double thinWidth = 1.5;
    const double thickWidth = 3.5;
    const double spaceThin = 1.5;
    const double spaceThick = 3.5;

    // Calcular ancho total de las barras
    double totalWidth = 0.0;

    // Start Guard: drawBar(thinWidth) + drawSpace(spaceThin) + drawBar(thinWidth) + drawSpace(spaceThin)
    totalWidth += thinWidth + spaceThin + thinWidth + spaceThin;

    // Mapeo pseudo-real de código de barras Code 39 para ancho total
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
      // Espacio fino separador
      totalWidth += spaceThin;
    }

    // Stop Guard: drawBar(thinWidth) + drawSpace(spaceThin) + drawBar(thinWidth)
    totalWidth += thinWidth + spaceThin + thinWidth;

    // Alinear al centro restando del ancho total del lienzo
    double currentX = (size.width - totalWidth) / 2;
    if (currentX < 0) currentX = 0.0;

    void drawBar(double width) {
      canvas.drawRect(Rect.fromLTWH(currentX, 0, width, size.height), paint);
      currentX += width;
    }

    void drawSpace(double width) {
      currentX += width;
    }

    // Delimitador de inicio (Start Guard)
    drawBar(thinWidth);
    drawSpace(spaceThin);
    drawBar(thinWidth);
    drawSpace(spaceThin);

    // Pintar los caracteres
    for (int i = 0; i < sanitized.length; i++) {
      final int charVal = sanitized.codeUnitAt(i);
      
      // Pattern
      for (int bit = 0; bit < 6; bit++) {
        final bool isBar = bit % 2 == 0;
        final bool isWide = ((charVal >> bit) & 1) == 1;

        if (isBar) {
          drawBar(isWide ? thickWidth : thinWidth);
        } else {
          drawSpace(isWide ? spaceThick : spaceThin);
        }
      }
      // Espacio fino separador
      drawSpace(spaceThin);
    }

    // Delimitador de fin (Stop Guard)
    drawBar(thinWidth);
    drawSpace(spaceThin);
    drawBar(thinWidth);
  }

  @override
  bool shouldRepaint(covariant _DynamicBarcodePainter oldDelegate) {
    return oldDelegate.code != code;
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double triangleHeight = 6.0;
    const double triangleWidth = 10.0;
    const double notchRadius = 12.0;
    final double dividerPos = size.height * 0.65; 

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    
    path.lineTo(size.width, dividerPos - notchRadius);
    path.arcToPoint(
      Offset(size.width, dividerPos + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - triangleHeight);
    
    for (double i = size.width; i > 0; i -= triangleWidth) {
      path.lineTo(i - triangleWidth / 2, size.height);
      path.lineTo(i - triangleWidth, size.height - triangleHeight);
    }

    path.lineTo(0, dividerPos + notchRadius);
    path.arcToPoint(
      Offset(0, dividerPos - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
