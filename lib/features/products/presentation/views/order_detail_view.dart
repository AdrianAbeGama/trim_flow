import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_state.dart';
import 'package:trim_flow/features/products/presentation/widgets/order_cancel_sheet.dart';
import 'package:trim_flow/features/products/presentation/widgets/order_ticket_card.dart';

class OrderDetailView extends StatefulWidget {
  const OrderDetailView({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  bool _showTicket = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          final order = state.orders.where((o) => o.id == widget.orderId).firstOrNull;
          if (order == null) return const SizedBox.shrink();
          final cancelled = order.status == OrderStatus.cancelled;

          return CustomScrollView(
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
                        Row(
                          children: [
                            PremiumBackButton(onTap: () => Navigator.pop(context)),
                            const Spacer(),
                            _CircleIconButton(
                              icon: Icons.info_outline_rounded,
                              onTap: () => _showHowItWorks(context),
                            ),
                            if (order.isCancellable) ...[
                              const SizedBox(width: 10),
                              _CancelCircleButton(order: order),
                            ],
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('Pedido', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2)),
                        const SizedBox(height: 2),
                        Text(order.code, style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.2)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (cancelled)
                      _CancelledBanner(reason: order.cancellationReason)
                          .animate().fadeIn(delay: 80.ms, duration: 450.ms)
                    else
                      _ProgressSteps(order: order)
                          .animate().fadeIn(delay: 80.ms, duration: 450.ms),
                    const SizedBox(height: 26),
                    _InfoRows(order: order)
                        .animate().fadeIn(delay: 160.ms, duration: 450.ms),
                    const SizedBox(height: 24),
                    _TicketToggleButton(
                      open: _showTicket,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _showTicket = !_showTicket);
                      },
                    ),
                    if (_showTicket) ...[
                      const SizedBox(height: 18),
                      OrderTicketCard(order: order)
                          .animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHowItWorks(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _HowItWorksSheet(),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.9,
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }
}

/// Botón cancelar (círculo rojo con X), estilo del "eliminar" de productos.
class _CancelCircleButton extends StatelessWidget {
  const _CancelCircleButton({required this.order});

  final ProductOrder order;

  static const Color _danger = Color(0xFFCF6679);

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.85,
      onTap: () async {
        HapticFeedback.mediumImpact();
        final bloc = context.read<OrdersBloc>();
        final reason = await OrderCancelSheet.show(context);
        if (reason != null) {
          bloc.add(OrdersEvent.cancelOrder(orderId: order.id, reason: reason));
        }
      },
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: _danger.withValues(alpha: 0.8), width: 1.2),
          boxShadow: [BoxShadow(color: _danger.withValues(alpha: 0.22), blurRadius: 8, spreadRadius: 1)],
        ),
        child: const Icon(Icons.close_rounded, size: 18, color: _danger),
      ),
    );
  }
}

class _TicketToggleButton extends StatelessWidget {
  const _TicketToggleButton({required this.open, required this.onTap});

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
            Icon(open ? Icons.visibility_off_rounded : Icons.receipt_long_rounded, color: gold, size: 17),
            const SizedBox(width: 8),
            Text(
              open ? 'OCULTAR COMPROBANTE' : 'VER COMPROBANTE',
              style: GoogleFonts.inter(color: gold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({required this.order});

  final ProductOrder order;

  static const List<String> _labels = ['Pedido', 'Pagado', 'Listo', 'Recogido'];

  int get _doneCount {
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
    final done = _doneCount;
    return Row(
      children: List.generate(_labels.length, (i) {
        final isDone = i < done;
        final isActive = i == done;
        final color = isDone ? const Color(0xFF6FAE8A) : (isActive ? gold : Colors.white.withValues(alpha: 0.18));
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i == 0 ? Colors.transparent : (i <= done ? const Color(0xFF6FAE8A) : Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFF6FAE8A) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded, color: Colors.black, size: 15)
                        : (isActive
                            ? Center(child: Container(width: 7, height: 7, decoration: BoxDecoration(color: gold, shape: BoxShape.circle)))
                            : null),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i == _labels.length - 1 ? Colors.transparent : (i < done ? const Color(0xFF6FAE8A) : Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                _labels[i],
                style: GoogleFonts.inter(
                  color: isDone || isActive ? Colors.white.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.3),
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
              width: 40, height: 40,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.cancel_rounded, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pedido cancelado', style: GoogleFonts.inter(color: accent, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
                  const SizedBox(height: 2),
                  Text('Este pedido ya no será preparado.', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        if (reason != null && reason!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 14),
          Text('MOTIVO', style: GoogleFonts.inter(color: accent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(reason!, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
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
        _row(gold, Icons.storefront_rounded, 'SEDE DE RECOJO', order.branchName, sub: order.pickupAddress),
        _divider(),
        _row(gold, Icons.payments_rounded, 'MÉTODO DE PAGO', order.paymentMethod.label),
      ],
    );
  }

  Widget _divider() => Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 16), color: Colors.white.withValues(alpha: 0.05));

  Widget _row(Color gold, IconData icon, String label, String value, {String? sub}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: gold, size: 17),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, height: 1.3)),
              if (sub != null && sub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(sub, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HowItWorksSheet extends StatelessWidget {
  const _HowItWorksSheet();

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final steps = <(IconData, String, String)>[
      (Icons.shopping_bag_rounded, 'Haces tu pedido', 'Eliges productos y confirmas el método de pago.'),
      (Icons.payments_rounded, 'Pagas', 'Yape o BCP se confirman al instante; en efectivo pagas al recoger.'),
      (Icons.inventory_2_rounded, 'Lo preparamos', 'Cuando esté listo verás el estado "Listo para recoger".'),
      (Icons.store_mall_directory_rounded, 'Recoges en la sede', 'Muestra el código del comprobante en recepción y listo.'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: gold, size: 18),
                const SizedBox(width: 10),
                Text('¿Cómo funciona?', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Tus pedidos se recogen en la sede de la barbería.', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            ...steps.asMap().entries.map((e) {
              final (icon, title, desc) = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: gold, size: 17),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${e.key + 1}. $title', style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                          const SizedBox(height: 2),
                          Text(desc, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 12, fontWeight: FontWeight.w500, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            Text('Puedes cancelar mientras el pedido no haya sido recogido.', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.35), fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
