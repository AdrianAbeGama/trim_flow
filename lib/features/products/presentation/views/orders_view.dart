import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_state.dart';
import 'package:trim_flow/features/products/presentation/views/order_detail_view.dart';
import 'package:trim_flow/features/products/presentation/widgets/order_card.dart';

enum OrderFilter { todos, porPagar, enPreparacion, listos, recogidos, cancelados }

extension _OrderFilterX on OrderFilter {
  String get label {
    switch (this) {
      case OrderFilter.todos:
        return 'Todos';
      case OrderFilter.porPagar:
        return 'Por pagar';
      case OrderFilter.enPreparacion:
        return 'En preparación';
      case OrderFilter.listos:
        return 'Listos';
      case OrderFilter.recogidos:
        return 'Recogidos';
      case OrderFilter.cancelados:
        return 'Cancelados';
    }
  }

  bool matches(ProductOrder o) {
    switch (this) {
      case OrderFilter.todos:
        return true;
      case OrderFilter.porPagar:
        return o.status == OrderStatus.pendingPayment;
      case OrderFilter.enPreparacion:
        return o.status == OrderStatus.paid;
      case OrderFilter.listos:
        return o.status == OrderStatus.ready;
      case OrderFilter.recogidos:
        return o.status == OrderStatus.completed;
      case OrderFilter.cancelados:
        return o.status == OrderStatus.cancelled;
    }
  }
}

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  OrderFilter _filter = OrderFilter.todos;

  Future<void> _openFilterMenu(BuildContext context) async {
    final gold = context.read<TenantThemeBloc>().state.colors.primaryGold;
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final topRight = box.localToGlobal(box.size.topRight(Offset.zero), ancestor: overlay);
    final position = RelativeRect.fromLTRB(topRight.dx - 200, topRight.dy + 8, 20, 0);

    final selected = await showMenu<OrderFilter>(
      context: context,
      position: position,
      color: const Color(0xFF1A1A1A),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      items: OrderFilter.values.map((f) {
        final isSel = f == _filter;
        return PopupMenuItem<OrderFilter>(
          value: f,
          height: 40,
          child: Row(
            children: [
              Icon(isSel ? Icons.check_rounded : Icons.circle_outlined,
                  size: 14, color: isSel ? gold : Colors.white.withValues(alpha: 0.25)),
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

  void _openDetail(BuildContext context, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrdersBloc>(),
          child: OrderDetailView(orderId: orderId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          final orders = state.orders;
          final showRecent = _filter == OrderFilter.todos;
          final recent = showRecent ? orders.take(2).toList() : const <ProductOrder>[];
          final rest = showRecent ? orders.skip(2).toList() : orders.where(_filter.matches).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  count: orders.length,
                  filter: _filter,
                  onFilter: _openFilterMenu,
                ),
              ),
              if (orders.isEmpty)
                const SliverFillRemaining(hasScrollBody: false, child: _EmptyOrders())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (recent.isNotEmpty) ...[
                        _SectionLabel(text: 'RECIENTES', gold: gold),
                        const SizedBox(height: 10),
                        ...recent.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: OrderCard(
                                order: e.value,
                                featured: e.key == 0,
                                onTap: () => _openDetail(context, e.value.id),
                              ).animate().fadeIn(delay: (60 * e.key).ms, duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                            )),
                        const SizedBox(height: 18),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionLabel(text: showRecent ? 'ANTERIORES' : _filter.label.toUpperCase(), gold: gold),
                          if (rest.isNotEmpty)
                            Text('${rest.length}', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.35), fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (rest.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              showRecent ? 'No hay más pedidos' : 'Sin pedidos en "${_filter.label}"',
                              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.35), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      else
                        ...rest.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: OrderCard(
                                order: e.value,
                                onTap: () => _openDetail(context, e.value.id),
                              ).animate().fadeIn(delay: (40 * e.key).clamp(0, 400).ms, duration: 400.ms),
                            )),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.filter, required this.onFilter});

  final int count;
  final OrderFilter filter;
  final void Function(BuildContext) onFilter;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_rounded, color: gold, size: 13),
                      const SizedBox(width: 5),
                      Text('$count ${count == 1 ? "PEDIDO" : "PEDIDOS"}',
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: gold, letterSpacing: 1.5)),
                    ],
                  ),
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
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: filter == OrderFilter.todos ? const Color(0xFF161616) : gold.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(color: filter == OrderFilter.todos ? Colors.white.withValues(alpha: 0.06) : gold.withValues(alpha: 0.45)),
                      ),
                      child: Icon(Icons.tune_rounded, size: 17, color: filter == OrderFilter.todos ? Colors.white.withValues(alpha: 0.7) : gold),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 22),
            Text('Mis', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2))
                .animate().fadeIn(delay: 120.ms, duration: 500.ms),
            const SizedBox(height: 4),
            Text('Pedidos', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.6, height: 1.05))
                .animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(width: 16, height: 1.5, color: gold),
                const SizedBox(width: 8),
                Text(
                  count == 0 ? 'Aún no tienes pedidos' : 'Tus compras y dónde recogerlas',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45), letterSpacing: -0.1),
                ),
              ],
            ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.gold});

  final String text;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 1.5, color: gold),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.8)),
      ],
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(color: gold.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.receipt_long_rounded, color: gold.withValues(alpha: 0.75), size: 42),
            ),
            const SizedBox(height: 22),
            Text('Aún no tienes pedidos', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
            const SizedBox(height: 6),
            Text(
              'Cuando compres productos, aparecerán aquí con su estado y punto de recojo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
