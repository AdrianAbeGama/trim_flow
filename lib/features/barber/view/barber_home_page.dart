import 'package:trim_flow/features/home/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_bar_trigger.dart';
import 'package:trim_flow/core/widgets/premium/premium_bottom_nav_item.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/agenda/presentation/views/barber_agenda_view.dart';
import 'package:trim_flow/features/barber/view/barber_profile_view.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_view.dart';
import 'package:trim_flow/features/products/presentation/views/products_view.dart';

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
    return Scaffold(
        backgroundColor: context.backgroundBlack,
        body: Stack(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: HomePage.persistentNavBar,
              builder: (context, isPersistent, _) {
                return BottomBar(
              controller: _barController,
              layout: BottomBarLayout(
                width: MediaQuery.of(context).size.width * 0.9,
                borderRadius: BorderRadius.circular(18),
                offset: 20,
                alignment: Alignment.bottomCenter,
              ),
              scrollBehavior: BottomBarScrollBehavior(
                hideOnScroll: !isPersistent,
              ),
              theme: BottomBarThemeData(
                barDecoration: premiumBarDecoration(context),
              ),
              showIcon: false,
              body: ValueListenableBuilder<bool>(
                valueListenable: HomePage.enableSwipe,
                builder: (context, swipeEnabled, child) {
                  return TabBarView(
                    controller: tabController,
                    physics: swipeEnabled
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    children: [
                      HomeView(
                        isBarberMode: true,
                        onNavigateToServices: () => tabController.animateTo(1),
                        onNavigateToProducts: () => tabController.animateTo(3),
                        onNavigateToAppointments: () => tabController.animateTo(2),
                      ),
                      const GalleryView(isBarberMode: true),
                      const BarberAgendaView(),
                      const ProductsView(),
                      const BarberProfileView(),
                    ],
                  );
                },
              ),
              child: SizedBox(
                height: 58,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PremiumBottomNavItem(icon: Icons.home_rounded, label: 'Inicio', active: currentPage == 0, onTap: () => tabController.animateTo(0)),
                    PremiumBottomNavItem(icon: Icons.grid_view_rounded, label: 'Galería', active: currentPage == 1, onTap: () => tabController.animateTo(1)),
                    PremiumBottomNavItem(icon: Icons.content_cut_rounded, label: 'Agenda', active: currentPage == 2, onTap: () => tabController.animateTo(2)),
                    PremiumBottomNavItem(icon: Icons.shopping_bag_rounded, label: 'Tienda', active: currentPage == 3, onTap: () => tabController.animateTo(3)),
                    PremiumBottomNavItem(icon: Icons.person_rounded, label: 'Perfil', active: currentPage == 4, onTap: () => tabController.animateTo(4)),
                  ],
                ),
              ),
            );
              },
            ),


  
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              bottom: _barVisible ? -80 : 28,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _barVisible ? 0 : 1,
                child: PremiumBarTrigger(onTap: () => _barController.show()),
              ),
            ),
          ],
        ),
      );
  }


}
