import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_stats.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_today_agenda.dart';
import 'package:trim_flow/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:trim_flow/features/reviews/presentation/widgets/review_prompt_card.dart';

import '../../domain/models/home_content.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_view/home_brand_hero.dart';
import '../widgets/home_view/home_about_section.dart';
import '../widgets/home_view/home_locations_section.dart';
import '../widgets/home_view/home_social_footer.dart';
import '../widgets/home_view/home_next_appointment.dart';
import '../widgets/home_view/home_products_section.dart';
import '../widgets/home_view/home_services_section.dart';
import '../widgets/home_view/home_top_bar.dart';

/// HomeView cliente — rediseño premium siguiendo el design language de Profile.
///
/// **Secciones:**
/// 1. Top bar minimalista (greeting + bell badge)
/// 2. Hero card brand (gradient + brand title + CTA Reservar)
/// 3. Próxima cita widget (sincronizado con ProfileBloc)
/// 4. Looks horizontal carousel
/// 5. Servicios estrella (grid 2×N + ver todos)
/// 6. Productos destacados (horizontal scroll)
/// 7. Sobre nosotros (imagen + texto)
/// 8. Ubicaciones (cards)
/// 9. Social footer
///
/// **Mantiene funcionalidad de navegación cross-tab** vía callbacks.
class HomeView extends StatefulWidget {
  final VoidCallback? onNavigateToServices;
  final VoidCallback? onNavigateToProducts;
  final VoidCallback? onNavigateToAppointments;
  final bool isBarberMode;

  const HomeView({
    super.key,
    this.onNavigateToServices,
    this.onNavigateToProducts,
    this.onNavigateToAppointments,
    this.isBarberMode = false,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<AgendaTodaySummary>? _summaryFuture;
  Future<List<AgendaAppointment>>? _agendaFuture;

  @override
  void initState() {
    super.initState();
    // Asegura que el catálogo (servicios/sedes reales) esté cargado para Inicio.
    context.read<CatalogBloc>().add(const CatalogEvent.load());
    if (widget.isBarberMode) _loadBarberDay();
  }

  void _loadBarberDay() {
    final barberId = Supabase.instance.client.auth.currentUser?.id;
    if (barberId == null) return;
    final repo = getIt<AgendaRepository>();
    _summaryFuture = repo.fetchTodaySummary(barberId: barberId);
    _agendaFuture =
        repo.fetchAgendaForDay(barberId: barberId, day: DateTime.now());
  }

  String _nextLabel(DateTime? next) {
    if (next == null) return '—';
    return '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}';
  }

  /// Servicios REALES del catálogo del tenant. Es la fuente principal para la
  /// sección "Servicios" de Inicio (los que configuró la barbería).
  List<HomeStyleItem> _servicesFromCatalog(List<Service> services) {
    return services.map((s) {
      final p = s.price;
      return HomeStyleItem(
        name: s.name,
        image: '',
        price: p > 0
            ? (p % 1 == 0 ? p.toStringAsFixed(0) : p.toStringAsFixed(2))
            : null,
        duration: s.durationInMinutes > 0 ? '${s.durationInMinutes} min' : null,
        featured: s.isFeatured,
      );
    }).toList();
  }

  List<HomeStyleItem> _servicesFrom(HomeContent c) {
    if (c.services.isEmpty) return [];
    return c.services.map((s) {
      final priceRaw = s['price'] ?? '';
      final price = priceRaw.replaceAll('S/', '').replaceAll(RegExp(r'\s+'), '').trim();
      return HomeStyleItem(
        name: s['title'] ?? s['name'] ?? '—',
        image: s['img'] ?? s['image'] ?? '',
        price: price.isEmpty ? null : price,
        duration: s['time'] ?? s['duration'],
        featured: (s['featured'] ?? '') == 'true',
      );
    }).toList();
  }

  List<HomeProductSpotlightItem> _productsFrom(HomeContent c) {
    if (c.products.isEmpty) return [];
    return c.products.map((p) {
      final priceRaw = p['price'] ?? '';
      final price = priceRaw.replaceAll('S/', '').replaceAll(RegExp(r'\s+'), '').trim();
      return HomeProductSpotlightItem(
        name: p['name'] ?? '—',
        image: p['img'] ?? p['image'] ?? '',
        price: price,
        description: p['desc'] ?? p['description'] ?? '',
      );
    }).toList();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    context.read<HomeBloc>().add(const HomeEvent.load());
    if (widget.isBarberMode && mounted) setState(_loadBarberDay);
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading) {
          return Container(
            color: const Color(0xFF0A0A0A),
            child: Center(
              child: CupertinoActivityIndicator(color: context.primaryGold, radius: 14),
            ),
          );
        }

        return Container(
          color: const Color(0xFF0A0A0A),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: context.primaryGold,
            backgroundColor: const Color(0xFF0E0E0E),
            displacement: 60,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                HomeTopBar(),
                HomeBrandHero(content: state.content),
                if (widget.isBarberMode && _summaryFuture != null)
                  SliverToBoxAdapter(
                    child: FutureBuilder<AgendaTodaySummary>(
                      future: _summaryFuture,
                      builder: (context, snap) {
                        final s = snap.data;
                        return BarberProfileStatsRow(
                          cutsToday: s?.completedCuts ?? 0,
                          revenueToday: s?.revenue ?? 0,
                          nextLabel: _nextLabel(s?.nextStart),
                        );
                      },
                    ),
                  ),
                if (widget.isBarberMode && _agendaFuture != null)
                  SliverToBoxAdapter(
                    child: FutureBuilder<List<AgendaAppointment>>(
                      future: _agendaFuture,
                      builder: (context, snap) {
                        return BarberProfileTodayAgenda(
                          appointments: snap.data ?? const [],
                          loading:
                              snap.connectionState == ConnectionState.waiting,
                        );
                      },
                    ),
                  ),
                if (!widget.isBarberMode)
                  HomeNextAppointmentWidget(
                    onTap: widget.onNavigateToAppointments,
                  ),
                if (!widget.isBarberMode)
                  const SliverToBoxAdapter(child: ReviewPromptCard()),
                HomeInfiniteServicesSection(
                  items: () {
                    final catalogServices =
                        context.watch<CatalogBloc>().state.services;
                    return catalogServices.isNotEmpty
                        ? _servicesFromCatalog(catalogServices)
                        : _servicesFrom(state.content);
                  }(),
                  onSeeAll: widget.onNavigateToServices,
                  onItemTap: widget.onNavigateToAppointments == null
                      ? null
                      : (item) {
                          HomePage.requestedService.value = {'title': item.name};
                          widget.onNavigateToAppointments!();
                        },
                ),
                HomeProductSpotlightSection(
                  products: _productsFrom(state.content),
                  onSeeAll: widget.onNavigateToProducts,
                  onItemTap: widget.onNavigateToProducts == null
                      ? null
                      : (item) {
                          HomePage.requestedProductId.value = item.name;
                          widget.onNavigateToProducts!();
                        },
                ),
                HomeAboutSection(content: state.content),
                HomeLocationsSection(
                  content: state.content,
                  onReserve: (branch) {
                    HomePage.requestedService.value = {'branch': branch};
                    widget.onNavigateToAppointments?.call();
                  },
                ),
                HomeSocialFooter(content: state.content),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// 1. TOP BAR
// ============================================================================

