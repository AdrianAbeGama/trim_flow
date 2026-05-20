import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildPaymentSelection(context),
      ),
    );
  }

  Widget _buildPaymentSelection(BuildContext context) {
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
                    // Cabecera Premium Nivelada (Alineada con el botón de regreso)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.primaryGold.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PROCESO DE PAGO',
                                style: TextStyle(
                                  color: context.primaryGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'RESUMEN DE TU COMPRA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.primaryGold,
                            context.primaryGold.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...state.items.map((item) => Padding(
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
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity} x S/ ${item.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'S/ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    )),
                    const Divider(color: Colors.white10, height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL A PAGAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('S/ ${state.totalPrice.toStringAsFixed(2)}', style: TextStyle(color: context.primaryGold, fontSize: 24, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text('MÉTODO DE PAGO', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 20),
                    _buildAccordionMethodCard(
                      title: 'YAPE',
                      subtitle: 'Pago rápido con QR',
                      icon: Icons.qr_code_2_rounded,
                      content: const YapePaymentDetails(),
                    ),
                    const SizedBox(height: 12),
                    _buildAccordionMethodCard(
                      title: 'BCP',
                      subtitle: 'Transferencia bancaria',
                      icon: Icons.account_balance_rounded,
                      content: const BcpPaymentDetails(),
                    ),
                    const SizedBox(height: 12),
                    _buildAccordionMethodCard(
                      title: 'EFECTIVO',
                      subtitle: 'Paga en recepción',
                      icon: Icons.payments_rounded,
                      content: const EfectivoPaymentDetails(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _selectedMethod == null || _isProcessing 
                  ? null 
                  : () => _confirmOrder(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryGold,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.white10,
                ),
                child: _isProcessing 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text('CONFIRMAR PEDIDO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccordionMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget content,
  }) {
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
            color: isSelected ? context.primaryGold.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: context.primaryGold.withValues(alpha: 0.05),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ] : null,
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedMethod == title) {
                    _selectedMethod = null;
                  } else {
                    _selectedMethod = title;
                  }
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
                        color: isSelected ? context.primaryGold.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? context.primaryGold.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? context.primaryGold : Colors.white38,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 250),
                      turns: isSelected ? 0.5 : 0.0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isSelected ? context.primaryGold : Colors.white38,
                        size: 24,
                      ),
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
                  ClipRect(
                    child: content,
                  ),
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
    setState(() => _isProcessing = true);
    
    if (!mounted) return;
    
    final cartBloc = context.read<CartBloc>();
    final navigator = Navigator.of(context);
    
    // Simular proceso de pago
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProductPurchaseSuccessView(
          cartState: state,
          paymentMethod: _selectedMethod!,
          onGoHome: () {
            cartBloc.add(const CartEvent.clear());
            navigator.popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }
}
