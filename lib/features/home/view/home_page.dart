// ignore_for_file: deprecated_member_use
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/home/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
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
                  barDecoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(500),
                    border: Border.all(
                      color: context.primaryGold.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                ),
                showIcon: false,
                body: BlocBuilder<ProfileBloc, ProfileState>(
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
                  builder: (context, state) {
                    return TabBar(
                      controller: tabController,
                      onTap: (index) {
                        // Navegación libre
                      },
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(color: context.primaryGold, width: 2),
                        insets: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      labelPadding: EdgeInsets.zero,
                      dividerColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      tabs: [
                        const Tab(icon: Icon(Icons.home_filled, size: 22)),
                        const Tab(icon: Icon(Icons.grid_view_rounded, size: 22)),
                        _buildReservarTab(2),
                        const Tab(icon: Icon(Icons.shopping_bag_rounded, size: 22)),
                        Tab(
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.person_rounded, size: 22),
                              if (state.hasPendingBadge)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
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

  Widget _buildReservarTab(int index) {
    final isSelected = currentPage == index;
    return Tab(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryGold
              : context.primaryGold.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.primaryGold.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Image.asset(
          'images/mustache.png',
          color: isSelected ? context.backgroundBlack : context.primaryGold,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
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
