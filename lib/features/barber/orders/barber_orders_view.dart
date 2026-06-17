import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
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

  Future<void> _openFilterMenu(BuildContext btnContext) async {
    final gold = context.primaryGold;
    final box = btnContext.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(btnContext).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final anchor = box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay);
    final position = RelativeRect.fromLTRB(anchor.dx - 200, anchor.dy + 10, 20, 0);

    final selected = await showMenu<_BFilter>(
      context: context,
      position: position,
      color: const Color(0xFF1A1A1A),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      items: _BFilter.values.map((f) {
        final isSel = f == _filter;
        return PopupMenuItem<_BFilter>(
          value: f,
          height: 40,
          child: Row(
            children: [
              Icon(isSel ? Icons.check_rounded : Icons.circle_outlined, size: 14, color: isSel ? gold : Colors.white.withValues(alpha: 0.25)),
              const SizedBox(width: 10),
              Text(
                f.label,
                style: GoogleFonts.inter(
                  color: isSel ? Colors.white : Colors.white.withValues(alpha: 0.7),
                  fontSize: 12.5,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
    if (selected != null) {
      HapticFeedback.selectionClick();
      setState(() => _filter = selected);
    }
  }

  static const List<(OrderStatus, String)> _groups = [
    (OrderStatus.pendingPayment, 'POR PAGAR'),
    (OrderStatus.paid, 'EN PREPARACIÓN'),
    (OrderStatus.ready, 'LISTOS'),
    (OrderStatus.completed, 'RECOGIDOS'),
    (OrderStatus.cancelled, 'CANCELADOS'),
  ];

  Widget _cardAt(ProductOrder o, int i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _BarberOrderCard(order: o, onTap: () => _open(o.id))
            .animate()
            .fadeIn(delay: (40 * i).clamp(0, 400).ms, duration: 360.ms)
            .slideY(begin: 0.08, end: 0, duration: 360.ms, curve: Curves.easeOutCubic),
      );

  List<Widget> _items(List<ProductOrder> all) {
    final children = <Widget>[];
    if (_filter == _BFilter.todos) {
      var first = true;
      for (final g in _groups) {
        final list = all.where((o) => o.status == g.$1).toList();
        if (list.isEmpty) continue;
        children.add(_SectionHeader(label: g.$2, count: list.length, first: first));
        first = false;
        for (var i = 0; i < list.length; i++) {
          children.add(_cardAt(list[i], i));
        }
      }
    } else {
      final list = all.where(_filter.matches).toList();
      for (var i = 0; i < list.length; i++) {
        children.add(_cardAt(list[i], i));
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final all = _store.list();
    final children = _items(all);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(count: all.length, filter: _filter, onFilter: _openFilterMenu)),
          if (children.isEmpty)
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
              sliver: SliverList(delegate: SliverChildListDelegate(children)),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count, required this.first});

  final String label;
  final int count;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, first ? 4 : 16, 0, 10),
      child: Row(
        children: [
          Container(width: 14, height: 1.5, color: gold),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.8)),
          const Spacer(),
          Text('$count', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.35), fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.filter, required this.onFilter});

  final int count;
  final _BFilter filter;
  final void Function(BuildContext) onFilter;

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
                const Spacer(),
                Builder(
                  builder: (btnContext) => PremiumPressable(
                    pressedScale: 0.9,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onFilter(btnContext);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: filter == _BFilter.todos ? const Color(0xFF161616) : gold.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(color: filter == _BFilter.todos ? Colors.white.withValues(alpha: 0.06) : gold.withValues(alpha: 0.45)),
                      ),
                      child: Icon(Icons.tune_rounded, size: 17, color: filter == _BFilter.todos ? Colors.white.withValues(alpha: 0.7) : gold),
                    ),
                  ),
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

class _BarberOrderCard extends StatefulWidget {
  const _BarberOrderCard({required this.order, required this.onTap});

  final ProductOrder order;
  final VoidCallback onTap;

  @override
  State<_BarberOrderCard> createState() => _BarberOrderCardState();
}

class _BarberOrderCardState extends State<_BarberOrderCard> {
  bool _expanded = false;

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final gold = context.primaryGold;
    final statusColor = _statusColor(order.status, gold);
    final first = order.items.isNotEmpty ? order.items.first.product : null;
    final extras = order.items.skip(1).toList();
    final hasExtras = extras.isNotEmpty;
    final summary = first?.name ?? 'Productos';

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
                    ? SafeImage(url: first.imageUrl, width: 96, height: 96, fit: BoxFit.cover)
                    : Container(width: 96, height: 96, color: Colors.white.withValues(alpha: 0.04)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(order.status.short,
                            style: GoogleFonts.inter(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                        const Spacer(),
                        Icon(Icons.event_rounded, size: 12, color: Colors.white.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(DateFormat("d MMM · HH:mm", 'es').format(order.createdAt),
                            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 11.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.customerName.isEmpty ? 'Cliente' : order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('S/ ${order.total.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(color: gold, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const Spacer(),
                        if (hasExtras)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _toggle,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _expanded ? 'Ocultar' : '+${extras.length} ${extras.length == 1 ? "producto" : "productos"}',
                                  style: GoogleFonts.inter(color: gold, fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 2),
                                AnimatedRotation(
                                  turns: _expanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  child: Icon(Icons.keyboard_arrow_down_rounded, color: gold, size: 18),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
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
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      children: extras
                          .map((it) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: SafeImage(url: it.product.imageUrl, width: 52, height: 52, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(it.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                                          const SizedBox(height: 2),
                                          Text('${it.quantity} ${it.quantity == 1 ? "unidad" : "unidades"}', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('S/ ${(it.product.price * it.quantity).toStringAsFixed(2)}', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600)),
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
