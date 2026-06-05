import 'package:trim_flow/features/home/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
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
                borderRadius: BorderRadius.circular(500),
                offset: 20,
                alignment: Alignment.bottomCenter,
              ),
              scrollBehavior: BottomBarScrollBehavior(
                hideOnScroll: !isPersistent,
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
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: const [
                  Tab(icon: Icon(Icons.home_filled, size: 22)),
                  Tab(icon: Icon(Icons.grid_view_rounded, size: 22)),
                  Tab(icon: FaIcon(FontAwesomeIcons.scissors, size: 20)),
                  Tab(icon: Icon(Icons.shopping_bag_rounded, size: 22)),
                  Tab(icon: Icon(Icons.person_rounded, size: 22)),
                ],
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
      );
  }


}
