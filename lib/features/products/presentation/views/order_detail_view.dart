import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_state.dart';
import 'package:trim_flow/features/products/presentation/widgets/order_cancel_sheet.dart';
import 'package:trim_flow/features/products/presentation/widgets/order_ticket_card.dart';

/// Detalle de pedido: muestra directo el comprobante (ticket) con la línea de
/// tiempo, sede, método, productos, total y código de barras. Cancelar es un
/// enlace de texto debajo del comprobante.
class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key, required this.orderId});

  final String orderId;

  Future<void> _cancel(BuildContext context, ProductOrder order) async {
    HapticFeedback.mediumImpact();
    final bloc = context.read<OrdersBloc>();
    final reason = await OrderCancelSheet.show(context);
    if (reason != null) {
      bloc.add(OrdersEvent.cancelOrder(orderId: order.id, reason: reason));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          final order = state.orders.where((o) => o.id == orderId).firstOrNull;
          if (order == null) return const SizedBox.shrink();

          return CustomScrollView(
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
                    OrderTicketCard(order: order)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 450.ms)
                        .slideY(begin: 0.06, end: 0, delay: 100.ms, duration: 450.ms, curve: Curves.easeOutCubic),
                    if (order.isCancellable) ...[
                      const SizedBox(height: 22),
                      Center(
                        child: PremiumPressable(
                          pressedScale: 0.96,
                          onTap: () => _cancel(context, order),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Text(
                              'Cancelar pedido',
                              style: GoogleFonts.inter(color: const Color(0xFFCF6679), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.1),
                            ),
                          ),
                        ),
                      ),
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
}
