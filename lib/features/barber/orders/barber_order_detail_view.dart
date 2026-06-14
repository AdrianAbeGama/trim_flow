import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/barber/orders/barber_orders_mock.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';
import 'package:trim_flow/features/products/presentation/widgets/order_ticket_card.dart';

/// Detalle de un pedido visto por el BARBERO: datos del cliente, productos,
/// pago, y avance de estado (pagado/listo/recogido). Mock para demo.
class BarberOrderDetailView extends StatefulWidget {
  const BarberOrderDetailView({super.key, required this.orderId});

  final String orderId;

  @override
  State<BarberOrderDetailView> createState() => _BarberOrderDetailViewState();
}

class _BarberOrderDetailViewState extends State<BarberOrderDetailView> {
  final _store = BarberOrdersStore.instance;
  bool _showTicket = false;

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

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final order = _store.byId(widget.orderId);
    if (order == null) {
      return const Scaffold(
          backgroundColor: Color(0xFF0A0A0A), body: SizedBox.shrink());
    }
    final cancelled = order.status == OrderStatus.cancelled;
    final nextLabel = _nextActionLabel(order.status);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumBackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(height: 16),
                    Text('Pedido',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.55),
                            letterSpacing: -0.2)),
                    const SizedBox(height: 2),
                    Text(order.code,
                        style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.2)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(width: 16, height: 1.5, color: gold),
                        const SizedBox(width: 8),
                        Text(order.customerName.isEmpty ? 'Cliente' : order.customerName,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: -0.2)),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(
                begin: -0.2, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (cancelled)
                  _CancelledBanner(reason: order.cancellationReason)
                else
                  _Steps(order: order),
                const SizedBox(height: 24),
                _ClientCard(order: order),
                const SizedBox(height: 18),
                _ItemsCard(order: order),
                const SizedBox(height: 18),
                _InfoRows(order: order),
                const SizedBox(height: 22),
                _TicketToggle(
                  open: _showTicket,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _showTicket = !_showTicket);
                  },
                ),
                if (_showTicket) ...[
                  const SizedBox(height: 16),
                  OrderTicketCard(order: order),
                ],
                if (nextLabel != null) ...[
                  const SizedBox(height: 22),
                  _AdvanceButton(
                    label: nextLabel,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _store.advance(order.id));
                    },
                  ),
                ],
                if (!cancelled && order.status != OrderStatus.completed) ...[
                  const SizedBox(height: 10),
                  _CancelButton(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() =>
                          _store.cancel(order.id, 'Cancelado por la barbería'));
                    },
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

class _Steps extends StatelessWidget {
  const _Steps({required this.order});

  final ProductOrder order;

  static const List<String> _labels = ['Pedido', 'Pagado', 'Listo', 'Recogido'];

  int get _done {
    switch (order.status) {
      case OrderStatus.pendingPayment:
        return 1;
      case OrderStatus.paid:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.completed:
        return 4;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final done = _done;
    return Row(
      children: List.generate(_labels.length, (i) {
        final isDone = i < done;
        final isActive = i == done;
        final color = isDone
            ? gold
            : (isActive ? gold : Colors.white.withValues(alpha: 0.18));
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i == 0
                          ? Colors.transparent
                          : (i <= done ? gold : Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isDone ? gold : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: isDone
                        ? Icon(Icons.check_rounded,
                            color: premiumOnAccent(gold), size: 15)
                        : (isActive
                            ? Center(
                                child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                        color: gold, shape: BoxShape.circle)))
                            : null),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i == _labels.length - 1
                          ? Colors.transparent
                          : (i < done ? gold : Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                _labels[i],
                style: GoogleFonts.inter(
                  color: isDone || isActive
                      ? Colors.white.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.3),
                  fontSize: 9.5,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.order});

  final ProductOrder order;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final initial =
        order.customerName.isNotEmpty ? order.customerName[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.35)),
            ),
            child: Text(initial,
                style: GoogleFonts.inter(
                    color: gold, fontSize: 17, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CLIENTE',
                    style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
                const SizedBox(height: 3),
                Text(order.customerName.isEmpty ? 'Cliente' : order.customerName,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
                if (order.customerPhone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(order.customerPhone,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(order.status.short,
                style: GoogleFonts.inter(
                    color: gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final ProductOrder order;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 14, height: 1.5, color: gold),
            const SizedBox(width: 8),
            Text('PRODUCTOS',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8)),
          ],
        ),
        const SizedBox(height: 12),
        ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: SafeImage(
                        url: item.product.imageUrl,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2)),
                        const SizedBox(height: 2),
                        Text('Cantidad: ${item.quantity}',
                            style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Text('S/ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2)),
                ],
              ),
            )),
        Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.white.withValues(alpha: 0.05)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TOTAL',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
            Text('S/ ${order.total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                    color: gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4)),
          ],
        ),
      ],
    );
  }
}

class _InfoRows extends StatelessWidget {
  const _InfoRows({required this.order});

  final ProductOrder order;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      children: [
        _row(gold, Icons.storefront_rounded, 'SEDE DE RECOJO', order.branchName,
            sub: order.pickupAddress),
        Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 14),
            color: Colors.white.withValues(alpha: 0.05)),
        _row(gold, Icons.payments_rounded, 'MÉTODO DE PAGO',
            order.paymentMethod.label),
      ],
    );
  }

  Widget _row(Color gold, IconData icon, String label, String value,
      {String? sub}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: gold, size: 17),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(value,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3)),
              if (sub != null && sub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(sub,
                    style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketToggle extends StatelessWidget {
  const _TicketToggle({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(open ? Icons.visibility_off_rounded : Icons.receipt_long_rounded,
                color: gold, size: 17),
            const SizedBox(width: 8),
            Text(open ? 'OCULTAR COMPROBANTE' : 'VER COMPROBANTE',
                style: GoogleFonts.inter(
                    color: gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.8)),
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
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gold,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_rounded,
                color: premiumOnAccent(gold), size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    color: premiumOnAccent(gold),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  static const Color _danger = Color(0xFFCF6679);

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _danger.withValues(alpha: 0.4)),
        ),
        child: Text('CANCELAR PEDIDO',
            style: GoogleFonts.inter(
                color: _danger,
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
                letterSpacing: 1)),
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner({required this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFCF6679);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.cancel_rounded, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Pedido cancelado',
                  style: GoogleFonts.inter(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2)),
            ),
          ],
        ),
        if (reason != null && reason!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(reason!,
              style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }
}
