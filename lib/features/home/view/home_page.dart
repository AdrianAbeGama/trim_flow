// ignore_for_file: deprecated_member_use
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/home/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_bar_trigger.dart';
import 'package:trim_flow/core/widgets/premium/premium_bottom_nav_item.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/profile/presentation/views/profile_view.dart';
import 'package:trim_flow/features/reservations/presentation/views/reservation_view.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_bloc.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_event.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_view.dart';
import 'package:trim_flow/features/products/presentation/views/products_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const int galleryTabIndex = 0;
  static const int reservationsTabIndex = 2;
  static final ValueNotifier<bool> enableSwipe = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> persistentNavBar = ValueNotifier<bool>(false);
  static final ValueNotifier<int?> requestedTab = ValueNotifier<int?>(null);
  // Se activa tras confirmar una reserva: la tarjeta de próxima cita del perfil
  // reproduce una vez el efecto de ondas radiales al consumirlo.
  static final ValueNotifier<bool> justBooked = ValueNotifier<bool>(false);
  // Pre-selección cross-tab: cuando el usuario toca un servicio o producto del
  // home, se setea aquí y el destino lo consume al activarse.
  static final ValueNotifier<Map<String, String>?> requestedService = ValueNotifier<Map<String, String>?>(null);
  static final ValueNotifier<String?> requestedProductId = ValueNotifier<String?>(null);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _SectionView extends StatefulWidget {
  const _SectionView({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  State<_SectionView> createState() => _SectionViewState();
}

class _SectionViewState extends State<_SectionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundBlack,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                  color: context.backgroundBlack,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(widget.icon, color: context.primaryGold, size: 28),
                      const SizedBox(height: 10),
                      Text(
                        widget.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(width: 40, height: 2, color: context.primaryGold),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Próximamente',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 14,
                    letterSpacing: 3,
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  final BottomBarController _barController = BottomBarController();
  bool _barVisible = true;

  @override
  void initState() {
    currentPage = 0;
    tabController = TabController(length: 5, vsync: this);
    // Si se pidió un tab inicial antes de construir (ej. tras reservar), arranca ahí.
    final pendingTab = HomePage.requestedTab.value;
    if (pendingTab != null && pendingTab >= 0 && pendingTab < tabController.length) {
      tabController.index = pendingTab;
      currentPage = pendingTab;
      HomePage.requestedTab.value = null;
    }
    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != currentPage && mounted) {
        setState(() {
          currentPage = value;
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
    HomePage.requestedTab.addListener(_onRequestedTab);
    super.initState();
  }

  void _onRequestedTab() {
    final requested = HomePage.requestedTab.value;
    if (!mounted || requested == null) return;
    if (requested < 0 || requested >= tabController.length) {
      HomePage.requestedTab.value = null;
      return;
    }
    tabController.animateTo(requested);
    HomePage.requestedTab.value = null;
  }

  void goToHome() {
    tabController.animateTo(0);
  }


  @override
  void dispose() {
    HomePage.requestedTab.removeListener(_onRequestedTab);
    tabController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.backgroundBlack,
        body: BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) => previous.isBenefitActive != current.isBenefitActive,
          listener: (context, state) {
            if (state.isBenefitActive) {
              // 1. Redirigir a pestaña de reservas (index 2)
              tabController.animateTo(2);
              // 2. Activar descuento en el ReservationBloc
              context.read<ReservationBloc>().add(const ReservationEvent.activateDiscount());
            }
          },
          child: Stack(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: HomePage.persistentNavBar,
                builder: (context, isPersistent, child) {
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
                  barDecoration: premiumBarDecoration(context),
                ),
                showIcon: false,
                body: BlocBuilder<ProfileBloc, ProfileState>(
                  buildWhen: (previous, current) => false,
                  builder: (context, state) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: HomePage.enableSwipe,
                      builder: (context, swipeEnabled, child) {
                        return TabBarView(
                          controller: tabController,
                          dragStartBehavior: DragStartBehavior.down,
                          physics: swipeEnabled
                              ? const BouncingScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          children: [
                            KeepAliveWrapper(
                              child: HomeView(
                                onNavigateToServices: () => tabController.animateTo(2), // Reservas index
                                onNavigateToProducts: () => tabController.animateTo(3),
                                onNavigateToAppointments: () => tabController.animateTo(2), // For clients, maybe same as reservations?
                              ),
                            ),
                            const KeepAliveWrapper(
                              child: GalleryView(isBarberMode: false),
                            ),
                            KeepAliveWrapper(child: ReservationView(onGoHome: goToHome)),
                            const KeepAliveWrapper(
                              child: ProductsView(),
                            ),
                            const KeepAliveWrapper(child: ProfileView()),
                          ],
                        );
                      },
                    );
                  },
                ),
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  buildWhen: (previous, current) =>
                      previous.hasPendingBadge != current.hasPendingBadge,
                  builder: (context, state) {
                    return _buildPremiumBar(context, state);
                  },
                ),
              );
            },
          ),
              
              // Mini Bar Trigger (Abrir bar flotante)
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
        ),
    );
  }

  Widget _buildPremiumBar(BuildContext context, ProfileState state) {
    return SizedBox(
      height: 58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PremiumBottomNavItem(icon: Icons.home_rounded, label: 'Inicio', active: currentPage == 0, onTap: () => tabController.animateTo(0)),
          PremiumBottomNavItem(icon: Icons.grid_view_rounded, label: 'Galería', active: currentPage == 1, onTap: () => tabController.animateTo(1)),
          PremiumBottomNavItem(imageAsset: 'images/mustache.png', label: 'Reservar', active: currentPage == 2, onTap: () => tabController.animateTo(2)),
          PremiumBottomNavItem(icon: Icons.shopping_bag_rounded, label: 'Tienda', active: currentPage == 3, onTap: () => tabController.animateTo(3)),
          PremiumBottomNavItem(icon: Icons.person_rounded, label: 'Perfil', active: currentPage == 4, badge: state.hasPendingBadge, onTap: () => tabController.animateTo(4)),
        ],
      ),
    );
  }
}

class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
