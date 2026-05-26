import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/home/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/view/barber_profile_view.dart';
import 'package:trim_flow/features/products/presentation/views/products_view.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/data/repositories/product_repository_impl.dart';
import 'package:trim_flow/features/products/domain/usecases/product_usecases.dart';

class BarberHomePage extends StatefulWidget {
  const BarberHomePage({super.key});

  static final ValueNotifier<bool> showBarberBadge = ValueNotifier<bool>(true);

  @override
  State<BarberHomePage> createState() => _BarberHomePageState();
}

class _BarberHomePageState extends State<BarberHomePage> with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  final BottomBarController _barController = BottomBarController();
  bool _barVisible = true;

  @override
  void initState() {
    currentPage = 0;
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(() {
      if (tabController.index != currentPage && mounted) {
        setState(() {
          currentPage = tabController.index;
        });
      }
    });
    _barController.addListener(() {
      if (mounted) {
        setState(() {
          _barVisible = _barController.isVisible;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repo = ProductRepositoryImpl();
        return ProductBloc(
          getProducts: GetProductsUseCase(repo),
          getCategories: GetCategoriesUseCase(repo),
          searchProducts: SearchProductsUseCase(repo),
          filterByCategory: FilterByCategoryUseCase(repo),
          saveProduct: SaveProductUseCase(repo),
          deleteProduct: DeleteProductUseCase(repo),
        );
      },
      child: Scaffold(
        backgroundColor: context.backgroundBlack,
        body: Stack(
          children: [
            BottomBar(
              controller: _barController,
              layout: BottomBarLayout(
                width: MediaQuery.of(context).size.width * 0.9,
                borderRadius: BorderRadius.circular(500),
                offset: 20,
                alignment: Alignment.bottomCenter,
              ),
              scrollBehavior: const BottomBarScrollBehavior(
                hideOnScroll: true,
              ),
              theme: BottomBarThemeData(
                barDecoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(500),
                  border: Border.all(
                    color: context.primaryGold.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.primaryGold.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              showIcon: false,
              body: ValueListenableBuilder<bool>(
                valueListenable: HomePage.enableSwipe,
                builder: (context, swipeEnabled, child) {
                  return TabBarView(
                    key: ValueKey('barber_tabbarview_swipe_$swipeEnabled'),
                    controller: tabController,
                    physics: swipeEnabled
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    children: [
                      HomeView(
                        onNavigateToServices: () => tabController.animateTo(1),
                        onNavigateToProducts: () => tabController.animateTo(3),
                        onNavigateToAppointments: () => tabController.animateTo(2),
                      ),
                      const _BarberSectionView(title: 'Galería', icon: Icons.grid_view_rounded),
                      const _BarberSectionView(title: 'Citas', icon: Icons.calendar_today_rounded),
                      const ProductsView(),
                      const BarberProfileView(),
                    ],
                  );
                },
              ),
              child: TabBar(
                controller: tabController,
                onTap: (index) {
                  setState(() => currentPage = index);
                },
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: context.primaryGold, width: 3),
                  insets: const EdgeInsets.symmetric(horizontal: 20),
                ),
                labelPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(icon: Icon(Icons.home_filled, size: 22)),
                  Tab(icon: Icon(Icons.grid_view_rounded, size: 22)),
                  Tab(icon: Icon(Icons.calendar_today_rounded, size: 22)),
                  Tab(icon: Icon(Icons.shopping_bag_rounded, size: 22)),
                  Tab(icon: Icon(Icons.person_rounded, size: 22)),
                ],
              ),
            ),
            

  
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              bottom: _barVisible ? -80 : 28,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _barVisible ? 0 : 1,
                child: GestureDetector(
                  onTap: () => _barController.show(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: context.primaryGold.withValues(alpha: 0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.primaryGold.withValues(alpha: 0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_up_rounded, color: context.primaryGold, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Abrir',
                          style: TextStyle(
                            color: context.primaryGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}

class _EditButtonUI extends StatelessWidget {
  final bool isEditing;
  final String label;

  const _EditButtonUI({required this.isEditing, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isEditing ? Colors.white : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.primaryGold.withValues(alpha: 0.5)),
        ),
        child: Text(
          isEditing ? 'LISTO' : label,
          style: TextStyle(
            color: isEditing ? Colors.black : context.primaryGold, 
            fontSize: 9, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5
        ),
      ),
    );
  }
}

class _BarberSectionView extends StatelessWidget {
  const _BarberSectionView({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundBlack,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              color: context.backgroundBlack,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(icon, color: context.primaryGold, size: 28),
                      const SizedBox(width: 12),
                      ValueListenableBuilder<bool>(
                        valueListenable: BarberHomePage.showBarberBadge,
                        builder: (context, showBadge, child) {
                          if (!showBadge) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.primaryGold,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'MODO BARBERO',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildDynamicEditButtonForSection(context),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(width: 40, height: 2, color: context.primaryGold),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: context.primaryGold.withValues(alpha: 0.2), size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'MODO BARBERO'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.1),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Próximamente disponible',
                      style: TextStyle(color: Colors.white12, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicEditButtonForSection(BuildContext context) {
    if (title.toUpperCase() == 'GALERÍA') {
      return const _EditButtonUI(isEditing: false, label: 'EDITAR GALERÍA');
    } else if (title.toUpperCase() == 'CITAS') {
      return const _EditButtonUI(isEditing: false, label: 'EDITAR CITAS');
    }
    return const SizedBox.shrink();
  }
}
