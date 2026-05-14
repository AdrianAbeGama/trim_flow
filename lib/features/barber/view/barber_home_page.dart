import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/home/presentation/views/home_view.dart';
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/barber/view/barber_profile_view.dart';

class BarberHomePage extends StatefulWidget {
  const BarberHomePage({super.key});

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
            body: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return TabBarView(
                  controller: tabController,
                  dragStartBehavior: DragStartBehavior.down,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    HomeView(
                      onNavigateToServices: () => tabController.animateTo(1), // Assuming Gallery or maybe you want another tab?
                      onNavigateToProducts: () => tabController.animateTo(3),
                      onNavigateToAppointments: () => tabController.animateTo(2),
                    ),
                    const _BarberSectionView(title: 'Galería', icon: Icons.grid_view_rounded),
                    const _BarberSectionView(title: 'Citas', icon: Icons.calendar_today_rounded),
                    const _BarberSectionView(title: 'Productos', icon: Icons.shopping_bag_rounded),
                    const BarberProfileView(),
                  ],
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
                    borderSide: BorderSide(color: context.primaryGold, width: 3),
                    insets: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  labelPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  tabs: [
                    const Tab(icon: Icon(Icons.home_filled, size: 22)),
                    const Tab(icon: Icon(Icons.grid_view_rounded, size: 22)),
                    const Tab(icon: Icon(Icons.calendar_today_rounded, size: 22)),
                    const Tab(icon: Icon(Icons.shopping_bag_rounded, size: 22)),
                    const Tab(icon: Icon(Icons.person_rounded, size: 22)),
                  ],
                );
              },
            ),
          ),
          
          // Etiqueta sutil de MODO BARBERO
          Positioned(
            top: 60,
            right: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.primaryGold.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'MODO BARBERO',
                    style: TextStyle(
                      color: Colors.black, 
                      fontSize: 10, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 1
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () {
                        context.read<HomeBloc>().add(const HomeEvent.toggleEditMode());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: state.isEditing ? Colors.white : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.primaryGold.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isEditing ? Icons.check_circle_rounded : Icons.edit_rounded, 
                              color: state.isEditing ? Colors.black : context.primaryGold, 
                              size: 12
                            ),
                            const SizedBox(width: 6),
                            Text(
                              state.isEditing ? 'LISTO' : 'EDITAR INICIO',
                              style: TextStyle(
                                color: state.isEditing ? Colors.black : context.primaryGold, 
                                fontSize: 9, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Mini Bar Trigger (Abrir bar flotante) - Sincronizado con Cliente
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
                  Icon(icon, color: context.primaryGold, size: 28),
                  const SizedBox(height: 10),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
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
}
