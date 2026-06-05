import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap, this.featured = false});

  final ProductOrder order;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final first = order.items.isNotEmpty ? order.items.first.product : null;
    final extra = order.items.length - 1;
    final thumb = featured ? 60.0 : 54.0;

    return PremiumPressable(
      pressedScale: 0.99,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: featured ? gold.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: featured ? gold.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: first != null
                      ? SafeImage(url: first.imageUrl, width: thumb, height: thumb, fit: BoxFit.cover)
                      : SizedBox(width: thumb, height: thumb),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        first?.name ?? 'Pedido',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3, height: 1.2),
                      ),
                      if (extra > 0) ...[
                        const SizedBox(height: 3),
                        Text(
                          '+ $extra ${extra == 1 ? "producto más" : "productos más"}',
                          style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 11.5, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'S/ ${order.total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(color: gold, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Ver detalles',
                  style: GoogleFonts.inter(color: gold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: -0.1),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, color: gold, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
