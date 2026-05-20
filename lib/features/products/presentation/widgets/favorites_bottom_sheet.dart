import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/views/favorites_view.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';

class FavoritesBottomSheet extends StatelessWidget {
  const FavoritesBottomSheet({super.key});

  static void show(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final cartBloc = context.read<CartBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productBloc),
          BlocProvider.value(value: cartBloc),
        ],
        child: const FavoritesBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final favorites = state.products.where((p) => p.isFavorite).toList();
        final isEmpty = favorites.isEmpty;
        
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ADAPTABLE
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Spacer for centering
                  const Text(
                    'MIS FAVORITOS',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen_rounded, color: Colors.white70, size: 26),
                    onPressed: () {
                      Navigator.pop(context);
                      final productBloc = context.read<ProductBloc>();
                      final cartBloc = context.read<CartBloc>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: productBloc),
                              BlocProvider.value(value: cartBloc),
                            ],
                            child: const FavoritesView(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (!isEmpty) ...[
                const SizedBox(height: 8),
                const _PulsingInstructionText(text: 'Desliza a la izquierda para quitar'),
              ],
              const SizedBox(height: 24),
              if (isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'AÚN NO TIENES FAVORITOS',
                    style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                )
              else ...[
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: favorites.length,
                    separatorBuilder: (context, i) => Divider(color: Colors.white.withValues(alpha: 0.05), height: 32),
                    itemBuilder: (context, index) {
                      final product = favorites[index];
                      return Dismissible(
                        key: Key('fav_item_${product.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4D4D),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.favorite_border_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          context.read<ProductBloc>().add(ProductEvent.toggleFavorite(product.id));
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SafeImage(
                                url: product.imageUrl,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'S/ ${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(color: context.primaryGold, fontSize: 13, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite_rounded, color: Color(0xFFFF4D4D), size: 20),
                              onPressed: () => context.read<ProductBloc>().add(ProductEvent.toggleFavorite(product.id)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('CONTINUAR COMPRANDO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PulsingInstructionText extends StatefulWidget {
  final String text;
  const _PulsingInstructionText({required this.text});

  @override
  State<_PulsingInstructionText> createState() => _PulsingInstructionTextState();
}

class _PulsingInstructionTextState extends State<_PulsingInstructionText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
    
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _controller.stop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.primaryGold, 
          fontSize: 9, 
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
