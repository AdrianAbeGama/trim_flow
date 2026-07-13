import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_bloc.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_event.dart';

/// Seccion opcional en el paso 5 para agregar productos del negocio a la cita.
/// Las cantidades viven en ReservationBloc.productQuantities y se envian como
/// p_product_items al confirmar. Si el negocio no tiene productos, no se muestra.
class ReservationProductsSelector extends StatefulWidget {
  const ReservationProductsSelector({super.key});

  @override
  State<ReservationProductsSelector> createState() =>
      _ReservationProductsSelectorState();
}

class _ReservationProductsSelectorState
    extends State<ReservationProductsSelector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final products = context.read<ProductBloc>().state;
      if (products.allProducts.isEmpty && !products.isLoading) {
        context.read<ProductBloc>().add(const ProductEvent.started());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductBloc>().state.allProducts;
    if (products.isEmpty) return const SizedBox.shrink();

    final quantities = context.watch<ReservationBloc>().state.productQuantities;
    final gold = context.primaryGold;
    final subtotal = products.fold<double>(
        0, (sum, p) => sum + p.price * (quantities[p.id] ?? 0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionLabel('Productos (opcional)'),
          const SizedBox(height: 6),
          Text(
            'Agrégalos a tu cita; los pagas en la barbería.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ...products.map((p) => _ProductRow(
                product: p,
                quantity: quantities[p.id] ?? 0,
                onChanged: (q) => context
                    .read<ReservationBloc>()
                    .add(ReservationEvent.setProductQuantity(p.id, q)),
              )),
          if (subtotal > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Productos',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'S/ ${subtotal.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    color: gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.quantity,
    required this.onChanged,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final selected = quantity > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'S/ ${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!selected)
            PremiumPressable(
              pressedScale: 0.9,
              onTap: () => onChanged(1),
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(11),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'AGREGAR',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                _StepBtn(
                    icon: Icons.remove_rounded,
                    onTap: () => onChanged(quantity - 1)),
                Container(
                  width: 34,
                  alignment: Alignment.center,
                  child: Text(
                    '$quantity',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StepBtn(
                    icon: Icons.add_rounded,
                    color: gold,
                    onTap: () => onChanged(quantity + 1)),
              ],
            ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = color ?? Colors.white;
    return PremiumPressable(
      pressedScale: 0.88,
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: base.withValues(alpha: color != null ? 0.16 : 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: base.withValues(alpha: 0.14)),
        ),
        child: Icon(icon, color: color ?? Colors.white70, size: 18),
      ),
    );
  }
}
