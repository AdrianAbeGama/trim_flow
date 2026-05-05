import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:trim_flow/core/constants/app_colors.dart';
import 'package:trim_flow/features/profile/presentation/views/profile_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _ViewPlaceholder extends StatelessWidget {
  const _ViewPlaceholder({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;

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
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: BottomBar(
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
              color: AppColors.gold.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        // Mantenemos oculto el botón flotante (+) para evitar que aparezca al hacer scroll
        showIcon: false,
        body: TabBarView(
          controller: tabController,
          dragStartBehavior: DragStartBehavior.down,
          physics: const BouncingScrollPhysics(),
          children: const [
            _ViewPlaceholder(title: 'Inicio'),
            _ViewPlaceholder(title: 'Galería'),
            _ViewPlaceholder(title: 'Reservar'),
            _ViewPlaceholder(title: 'Productos'),
            ProfileView(),
          ],
        ),
        child: TabBar(
          controller: tabController,
          // Añadimos la línea indicadora solicitada
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: AppColors.gold, width: 2),
            insets: EdgeInsets.symmetric(horizontal: 20),
          ),
          labelPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: [
            const Tab(icon: Icon(Icons.home_filled, size: 22)),
            const Tab(icon: Icon(Icons.grid_view_rounded, size: 22)),
            // Icono de Reservar más grande, con círculo y estilo diferenciado
            _buildReservarTab(Icons.content_cut_rounded, 2),
            const Tab(icon: Icon(Icons.shopping_bag_rounded, size: 22)),
            const Tab(icon: Icon(Icons.person_rounded, size: 22)),
          ],
        ),
      ),
    );
  }

  Widget _buildReservarTab(IconData icon, int index) {
    final isSelected = currentPage == index;
    return Tab(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10), // Un poco más grande
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.black : AppColors.gold,
          size: 24, // Icono más grande
        ),
      ),
    );
  }
}
