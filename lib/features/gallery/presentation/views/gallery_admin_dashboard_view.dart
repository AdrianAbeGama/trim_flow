import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_admin_categories_tab.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_admin_portfolios_tab.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_admin_staff_tab.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_admin_widgets.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Panel administrativo de la galería — orquestador limpio.
/// 3 tabs: portafolios, staff, categorías. Cada tab vive en widgets/.
class GalleryAdminDashboardView extends StatefulWidget {
  const GalleryAdminDashboardView({super.key});

  @override
  State<GalleryAdminDashboardView> createState() =>
      _GalleryAdminDashboardViewState();
}

class _GalleryAdminDashboardViewState extends State<GalleryAdminDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _PremiumHeader(onBack: () => Navigator.pop(context)),
              GalleryAdminTabBar(controller: _tabController, gold: gold),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    GalleryAdminPortfoliosTab(),
                    GalleryAdminStaffTab(),
                    GalleryAdminCategoriesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GalleryBackButton(onTap: onBack),
              const SizedBox(width: 12),
              const GalleryPill(
                icon: Icons.tune_rounded,
                label: 'PANEL ADMIN',
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 16),
          Text(
            'Panel',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.55),
              letterSpacing: -0.2,
            ),
          ).animate().fadeIn(delay: 120.ms, duration: 500.ms),
          const SizedBox(height: 4),
          Text(
            'Administrativo',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.2,
              height: 1.05,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 14, height: 1.5, color: gold),
              const SizedBox(width: 7),
              Text(
                'Gestiona portafolios, staff y categorías',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
        ],
      ),
    );
  }
}
