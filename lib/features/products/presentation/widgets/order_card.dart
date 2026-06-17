import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';

/// Tarjeta de pedido (recientes / anteriores): abierta, sin recuadro de fondo,
/// imagen grande a la izquierda, total directo y flechita para desplegar el
/// resto de productos (imágenes grandes). Tocar abre el detalle.
class OrderCard extends StatefulWidget {
  const OrderCard({super.key, required this.order, required this.onTap, this.featured = false});

  final ProductOrder order;
  final VoidCallback onTap;
  final bool featured;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _expanded = false;

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final gold = context.primaryGold;
    final first = order.items.isNotEmpty ? order.items.first.product : null;
    final extras = order.items.skip(1).toList();
    final hasExtras = extras.isNotEmpty;

    return PremiumPressable(
      pressedScale: 0.99,
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: first != null
                    ? SafeImage(url: first.imageUrl, width: 100, height: 100, fit: BoxFit.cover)
                    : Container(width: 100, height: 100, color: Colors.white.withValues(alpha: 0.04)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      first?.name ?? 'Pedido',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.15),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'S/ ${order.total.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(color: gold, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.6),
                    ),
                    if (hasExtras) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _toggle,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _expanded ? 'Ocultar productos' : '+${extras.length} ${extras.length == 1 ? "producto" : "productos"}',
                              style: GoogleFonts.inter(color: gold, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: -0.1),
                            ),
                            const SizedBox(width: 3),
                            AnimatedRotation(
                              turns: _expanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              child: Icon(Icons.keyboard_arrow_down_rounded, color: gold, size: 19),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: (_expanded && hasExtras)
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: extras
                          .map((it) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: SafeImage(url: it.product.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            it.product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${it.quantity} ${it.quantity == 1 ? "unidad" : "unidades"}',
                                            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'S/ ${(it.product.price * it.quantity).toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
        ],
      ),
    );
  }
}
