import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/orders/barber_orders_mock.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';
import 'package:trim_flow/features/products/presentation/widgets/order_ticket_card.dart';

/// Detalle de un pedido visto por el BARBERO: el comprobante (mismo que el
/// cliente) con info extra (cliente), más el botón de avanzar el estado. Mock.
class BarberOrderDetailView extends StatefulWidget {
  const BarberOrderDetailView({super.key, required this.orderId});

  final String orderId;

  @override
  State<BarberOrderDetailView> createState() => _BarberOrderDetailViewState();
}

class _BarberOrderDetailViewState extends State<BarberOrderDetailView> {
  final _store = BarberOrdersStore.instance;

  String? _nextActionLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pendingPayment:
        return 'MARCAR COMO PAGADO';
      case OrderStatus.paid:
        return 'MARCAR COMO LISTO';
      case OrderStatus.ready:
        return 'MARCAR COMO RECOGIDO';
      default:
        return null;
    }
  }

  void _revert(ProductOrder order) {
    HapticFeedback.lightImpact();
    setState(() => _store.revert(order.id));
  }

  Future<void> _cancel(ProductOrder order) async {
    HapticFeedback.mediumImpact();
    final ok = await PremiumConfirmDelete.show(
      context,
      title: 'Cancelar pedido',
      message: '¿Seguro que quieres cancelar el pedido de ${order.customerName.isEmpty ? "este cliente" : order.customerName}?',
      confirmLabel: 'CANCELAR PEDIDO',
      icon: Icons.cancel_rounded,
    );
    if (ok && mounted) {
      setState(() => _store.cancel(order.id, 'Cancelado por la barbería'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _store.byId(widget.orderId);
    if (order == null) {
      return const Scaffold(backgroundColor: Color(0xFF0A0A0A), body: SizedBox.shrink());
    }
    final cancelled = order.status == OrderStatus.cancelled;
    final nextLabel = _nextActionLabel(order.status);
    final canRevert = order.status == OrderStatus.paid ||
        order.status == OrderStatus.ready ||
        order.status == OrderStatus.completed;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    PremiumBackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('PEDIDO', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.45), letterSpacing: 1.6)),
                          const SizedBox(height: 2),
                          Text(order.code, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                OrderTicketCard(order: order, customerName: order.customerName)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 450.ms)
                    .slideY(begin: 0.06, end: 0, delay: 100.ms, duration: 450.ms, curve: Curves.easeOutCubic),
                if (nextLabel != null && canRevert) ...[
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _SecondaryButton(icon: Icons.undo_rounded, label: 'Revertir', onTap: () => _revert(order)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _AdvanceButton(
                          label: nextLabel,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            setState(() => _store.advance(order.id));
                          },
                        ),
                      ),
                    ],
                  ),
                ] else if (nextLabel != null) ...[
                  const SizedBox(height: 22),
                  _AdvanceButton(
                    label: nextLabel,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _store.advance(order.id));
                    },
                  ),
                ] else if (canRevert) ...[
                  const SizedBox(height: 22),
                  _SecondaryButton(icon: Icons.undo_rounded, label: 'Revertir estado', onTap: () => _revert(order)),
                ],
                if (cancelled) ...[
                  const SizedBox(height: 22),
                  _SecondaryButton(icon: Icons.restart_alt_rounded, label: 'Reactivar pedido', onTap: () => _revert(order)),
                ],
                if (!cancelled && order.status != OrderStatus.completed) ...[
                  const SizedBox(height: 14),
                  Center(
                    child: PremiumPressable(
                      pressedScale: 0.96,
                      onTap: () => _cancel(order),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Text('Cancelar pedido', style: GoogleFonts.inter(color: const Color(0xFFCF6679), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.1)),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.97,
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.85)),
            const SizedBox(width: 7),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w800, fontSize: 12.5, letterSpacing: 0.3)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvanceButton extends StatelessWidget {
  const _AdvanceButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final fg = premiumOnAccent(gold);
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_rounded, size: 17, color: fg),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(color: fg, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.6)),
          ],
        ),
      ),
    );
  }
}
