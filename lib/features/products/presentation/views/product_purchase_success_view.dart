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
import 'package:trim_flow/core/settings/ticket_style.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/widgets/barcode_widget.dart';

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
                            child: Text('COMPARTIR', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 12.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
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
                            child: Text('VER MIS PEDIDOS', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.6, fontSize: 12.5)),
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

    return ValueListenableBuilder<bool>(
      valueListenable: TicketStyle.dark,
      builder: (context, dark, _) {
        final gold = context.primaryGold;
        final bg = dark ? const Color(0xFF1A1A1A) : Colors.white;
        final textPrimary = dark ? Colors.white : Colors.black;
        final textMuted = dark ? Colors.white.withValues(alpha: 0.55) : Colors.black54;
        final label = dark ? Colors.white.withValues(alpha: 0.4) : Colors.black38;
        final divider = dark ? Colors.white.withValues(alpha: 0.12) : Colors.black12;
        final folio = dark ? Colors.white.withValues(alpha: 0.3) : Colors.black26;

        return ClipPath(
          clipper: _TicketClipper(),
          child: Container(
            width: double.infinity,
            color: bg,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: dark ? gold.withValues(alpha: 0.14) : gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: dark ? gold.withValues(alpha: 0.45) : Colors.white, width: 2),
                  ),
                  child: Icon(Icons.check_rounded, color: dark ? gold : Colors.white, size: 24),
                ),
                const SizedBox(height: 12),
                Text('PAGO EXITOSO', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 24),
                _buildDetailRow('FECHA', DateFormat("dd / MM / yyyy").format(DateTime.now()), label, textPrimary),
                const SizedBox(height: 12),
                _buildDetailRow('MÉTODO', widget.paymentMethod.toUpperCase(), label, textPrimary),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PRODUCTOS', style: TextStyle(color: label, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      ...widget.cartState.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}X ${item.product.name.toUpperCase()}',
                                    style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('S/ ${(item.product.price * item.quantity).toStringAsFixed(2)}', style: TextStyle(color: textMuted, fontSize: 11)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildDashedLine(divider),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL PAGADO', style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w900)),
                    Text('S/ ${widget.cartState.totalPrice.toStringAsFixed(2)}', style: TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 32),
                // Código de barras (toca para ampliar). Sobre azulejo blanco en modo oscuro.
                GestureDetector(
                  onTap: () => showBarcodeZoom(context, barcodeToShow),
                  child: dark
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: BarcodeWidget(code: barcodeToShow),
                        )
                      : BarcodeWidget(code: barcodeToShow),
                ),
                const SizedBox(height: 20),
                Text('GRACIAS POR TU PREFERENCIA', style: TextStyle(color: folio, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildDashedLine(Color color) {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : color,
            height: 1.5,
          ),
        ),
      ),
    );
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
