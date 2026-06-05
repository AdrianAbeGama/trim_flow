import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_event.dart';
import 'package:trim_flow/features/products/presentation/views/orders_view.dart';
import 'package:trim_flow/features/products/presentation/views/product_purchase_success_view.dart';
import 'checkout_payment_details.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  String? _selectedMethod;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: _buildPaymentSelection(context),
      ),
    );
  }

  Widget _buildPaymentSelection(BuildContext context) {
    final gold = context.primaryGold;
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PremiumBackButton(onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PROCESO DE PAGO',
                                style: GoogleFonts.inter(color: gold, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Resumen de tu compra',
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1.05),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.25, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [gold, gold.withValues(alpha: 0.0)],
                        ),
                      ),
                    ).animate().fadeIn(delay: 120.ms, duration: 500.ms).scaleX(begin: 0.3, end: 1, alignment: Alignment.centerLeft, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 24),
                    ...state.items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SafeImage(
                                url: item.product.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name.toUpperCase(),
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity} x S/ ${item.product.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'S/ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (200 + 70 * i).ms, duration: 400.ms).slideX(begin: 0.08, end: 0, delay: (200 + 70 * i).ms, duration: 400.ms, curve: Curves.easeOutCubic);
                    }),
                    Divider(color: Colors.white.withValues(alpha: 0.08), height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL A PAGAR', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
                        Text('S/ ${state.totalPrice.toStringAsFixed(2)}', style: GoogleFonts.inter(color: gold, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      ],
                    ).animate().fadeIn(delay: 360.ms, duration: 500.ms).scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1), delay: 360.ms, duration: 500.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Container(width: 16, height: 1.5, color: gold),
                        const SizedBox(width: 8),
                        Text('MÉTODO DE PAGO', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      ],
                    ).animate().fadeIn(delay: 440.ms, duration: 400.ms),
                    const SizedBox(height: 20),
                    _buildAccordionMethodCard(
                      title: 'YAPE',
                      subtitle: 'Pago rápido con QR',
                      icon: Icons.qr_code_2_rounded,
                      content: const YapePaymentDetails(),
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 500.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 12),
                    _buildAccordionMethodCard(
                      title: 'BCP',
                      subtitle: 'Transferencia bancaria',
                      icon: Icons.account_balance_rounded,
                      content: const BcpPaymentDetails(),
                    ).animate().fadeIn(delay: 560.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 560.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 12),
                    _buildAccordionMethodCard(
                      title: 'EFECTIVO',
                      subtitle: 'Paga en recepción',
                      icon: Icons.payments_rounded,
                      content: const EfectivoPaymentDetails(),
                    ).animate().fadeIn(delay: 620.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 620.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
            ),
            _buildConfirmButton(context, state),
          ],
        );
      },
    );
  }

  Widget _buildConfirmButton(BuildContext context, CartState state) {
    final enabled = _selectedMethod != null && !_isProcessing;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PremiumPressable(
        pressedScale: 0.98,
        onTap: enabled ? () => _confirmOrder(context, state) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFF7F3EC) : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _isProcessing
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : Text(
                  _selectedMethod == null ? 'ELIGE UN MÉTODO DE PAGO' : 'CONFIRMAR PEDIDO',
                  style: GoogleFonts.inter(
                    color: enabled ? Colors.black : Colors.white.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAccordionMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget content,
  }) {
    final gold = context.primaryGold;
    final isSelected = _selectedMethod == title;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? gold.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: gold.withValues(alpha: 0.05), blurRadius: 20)]
              : null,
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedMethod = _selectedMethod == title ? null : title;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? gold.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? gold.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Icon(icon, color: isSelected ? gold : Colors.white38, size: 24),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 250),
                      turns: isSelected ? 0.5 : 0.0,
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: isSelected ? gold : Colors.white38, size: 24),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  ClipRect(child: content),
                ],
              ),
              crossFadeState: isSelected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context, CartState state) async {
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    if (!mounted) return;

    final cartBloc = context.read<CartBloc>();
    final ordersBloc = context.read<OrdersBloc>();
    final navigator = Navigator.of(context);
    final method = PaymentMethodX.fromLabel(_selectedMethod!);

    ordersBloc.add(OrdersEvent.placeOrder(
      items: state.items,
      total: state.totalPrice,
      paymentMethod: method,
    ));

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProductPurchaseSuccessView(
          cartState: state,
          paymentMethod: _selectedMethod!,
          onViewOrders: () {
            cartBloc.add(const CartEvent.clear());
            navigator.popUntil((route) => route.isFirst);
            navigator.push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: ordersBloc,
                  child: const OrdersView(),
                ),
              ),
            );
          },
          onGoHome: () {
            cartBloc.add(const CartEvent.clear());
            navigator.popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }
}
