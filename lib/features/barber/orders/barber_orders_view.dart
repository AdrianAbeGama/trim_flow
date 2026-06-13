import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/orders/barber_order_detail_view.dart';
import 'package:trim_flow/features/barber/orders/barber_orders_mock.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';

enum _BFilter { todos, porPagar, preparacion, listos, recogidos, cancelados }

extension _BFilterX on _BFilter {
  String get label {
    switch (this) {
      case _BFilter.todos:
        return 'Todos';
      case _BFilter.porPagar:
        return 'Por pagar';
      case _BFilter.preparacion:
        return 'En preparación';
      case _BFilter.listos:
        return 'Listos';
      case _BFilter.recogidos:
        return 'Recogidos';
      case _BFilter.cancelados:
        return 'Cancelados';
    }
  }

  bool matches(ProductOrder o) {
    switch (this) {
      case _BFilter.todos:
        return true;
      case _BFilter.porPagar:
        return o.status == OrderStatus.pendingPayment;
      case _BFilter.preparacion:
        return o.status == OrderStatus.paid;
      case _BFilter.listos:
        return o.status == OrderStatus.ready;
      case _BFilter.recogidos:
        return o.status == OrderStatus.completed;
      case _BFilter.cancelados:
        return o.status == OrderStatus.cancelled;
    }
  }
}

Color _statusColor(OrderStatus s, Color gold) {
  switch (s) {
    case OrderStatus.pendingPayment:
      return const Color(0xFFE0A23B);
    case OrderStatus.paid:
    case OrderStatus.ready:
      return gold;
    case OrderStatus.completed:
      return Colors.white.withValues(alpha: 0.5);
    case OrderStatus.cancelled:
      return const Color(0xFFCF6679);
  }
}

class BarberOrdersView extends StatefulWidget {
  const BarberOrdersView({super.key});

  @override
  State<BarberOrdersView> createState() => _BarberOrdersViewState();
}

class _BarberOrdersViewState extends State<BarberOrdersView> {
  final _store = BarberOrdersStore.instance;
  _BFilter _filter = _BFilter.todos;

  void _open(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BarberOrderDetailView(orderId: id)),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final all = _store.list();
    final orders = all.where(_filter.matches).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(count: all.length)),
          SliverToBoxAdapter(
            child: _FilterRow(
              current: _filter,
              onSelect: (f) {
                HapticFeedback.selectionClick();
                setState(() => _filter = f);
              },
            ),
          ),
          if (orders.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'Sin pedidos en "${_filter.label}"',
                    style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final o = orders[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BarberOrderCard(order: o, onTap: () => _open(o.id))
                          .animate()
                          .fadeIn(
                              delay: (40 * i).clamp(0, 400).ms, duration: 360.ms)
                          .slideY(
                              begin: 0.08,
                              end: 0,
                              duration: 360.ms,
                              curve: Curves.easeOutCubic),
                    );
                  },
                  childCount: orders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PremiumBackButton(onTap: () => Navigator.pop(context)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: gold.withValues(alpha: 0.55)),
                  ),
                  child: Text('$count ${count == 1 ? "PEDIDO" : "PEDIDOS"}',
                      style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: gold,
                          letterSpacing: 1.5)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Pedidos de',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: -0.2)),
            const SizedBox(height: 4),
            Text('Clientes',
                style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.4,
                    height: 1.05)),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(width: 16, height: 1.5, color: gold),
                const SizedBox(width: 8),
                Text('Gestiona el estado de cada compra',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.45))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.current, required this.onSelect});

  final _BFilter current;
  final ValueChanged<_BFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _BFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _BFilter.values[i];
          final sel = f == current;
          return GestureDetector(
            onTap: () => onSelect(f),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? gold.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sel
                        ? gold.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.07)),
              ),
              child: Text(f.label,
                  style: GoogleFonts.inter(
                      color: sel ? gold : Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }
}

class _BarberOrderCard extends StatelessWidget {
  const _BarberOrderCard({required this.order, required this.onTap});

  final ProductOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final statusColor = _statusColor(order.status, gold);
    final first = order.items.isNotEmpty ? order.items.first.product.name : 'Productos';
    final extra = order.items.length - 1;
    final summary =
        extra > 0 ? '$first  ·  +$extra más' : first;

    return PremiumPressable(
      pressedScale: 0.99,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.customerName.isEmpty ? 'Cliente' : order.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(order.status.short,
                      style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(order.code,
                    style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payments_rounded,
                    size: 13, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(width: 5),
                Text(order.paymentMethod.label,
                    style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('S/ ${order.total.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                        color: gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3)),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    color: gold, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
