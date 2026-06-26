import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/gallery/data/gallery_favorites_store.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_fullscreen_viewer.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_empty_state.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_quick_actions.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_top_bar.dart';

/// Precio en soles, sin decimales si es entero (45 → "45", 45.5 → "45.50").
String _money(double v) =>
    v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Galería v24 — buscador + filtro en línea + cuadrícula de imágenes grandes,
/// ahora con precio del servicio. En edición: editar/eliminar. Tap → visor.
class GalleryView extends StatelessWidget {
  const GalleryView({super.key, required this.isBarberMode});

  final bool isBarberMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<GalleryBloc>()..add(const GalleryEvent.loadRequested()),
      child: _GalleryScaffold(isBarberMode: isBarberMode),
    );
  }
}

class _GalleryScaffold extends StatefulWidget {
  const _GalleryScaffold({required this.isBarberMode});
  final bool isBarberMode;

  @override
  State<_GalleryScaffold> createState() => _GalleryScaffoldState();
}

class _GalleryScaffoldState extends State<_GalleryScaffold> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _byBarber = false;
  String? _service;
  String? _barber;
  Timer? _searchDebounce;
  // Claves ya animadas: la animacion de entrada corre una sola vez por foto,
  // no cada vez que la celda reaparece al hacer scroll.
  final Set<String> _animatedKeys = <String>{};

  static const List<double> _heights = [252, 320, 224, 296, 240, 312];

  @override
  void initState() {
    super.initState();
    GalleryFavoritesStore.instance.load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Espera a que el usuario deje de teclear antes de refiltrar (evita refiltrar
  // y reconstruir la cuadricula en cada pulsacion).
  void _onQueryChanged(String v) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _query = v);
    });
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    context.read<GalleryBloc>().add(const GalleryEvent.loadRequested());
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  void _openFullscreen(
    BuildContext context,
    List<GalleryItem> items,
    int index,
  ) {
    HapticFeedback.lightImpact();
    final bloc = context.read<GalleryBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: GalleryFullscreenViewer(
            items: items,
            initialIndex: index,
            isBarberMode: widget.isBarberMode,
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, int boxKey) async {
    final bloc = context.read<GalleryBloc>();
    final overlay = Overlay.of(context, rootOverlay: true);
    final ok = await GalleryConfirmDelete.show(
      context,
      title: 'Eliminar foto',
      message: '¿Eliminar esta foto del portafolio?',
    );
    if (ok) {
      bloc.add(GalleryEvent.itemDeleted(boxKey));
      AppToast.showOn(
        overlay,
        type: AppToastType.success,
        title: 'Foto eliminada',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: BlocConsumer<GalleryBloc, GalleryState>(
        listenWhen: (prev, curr) =>
            curr.actionError != null && curr.actionError != prev.actionError,
        listener: (context, state) {
          AppToast.showOn(
            Overlay.of(context, rootOverlay: true),
            type: AppToastType.error,
            title: 'No se pudo completar la acción',
          );
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: context.primaryGold,
            backgroundColor: const Color(0xFF0E0E0E),
            displacement: 60,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                GalleryTopBar(isBarberMode: widget.isBarberMode, state: state),
                if (widget.isBarberMode && state.isEditing)
                  GalleryQuickActionsSliver(isBarberMode: widget.isBarberMode),
                ..._buildContent(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, GalleryState state) {
    if (state.status == GalleryStatus.loading ||
        state.status == GalleryStatus.initial) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: Center(
              child: CupertinoActivityIndicator(
                color: context.primaryGold,
                radius: 14,
              ),
            ),
          ),
        ),
      ];
    }

    final all = state.allItems;
    if (all.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: GalleryEmptyState(
            isEditing: state.isEditing && widget.isBarberMode,
          ),
        ),
      ];
    }

    final services = (<String>{for (final it in all) it.categoryLabel}.toList())
      ..sort();
    final barbers = (<String>{
      for (final it in all) it.barberFullName ?? '',
    }..remove('')).toList()..sort();
    if (_service != null && !services.contains(_service)) _service = null;
    if (_barber != null && !barbers.contains(_barber)) _barber = null;

    final q = _query.trim().toLowerCase();
    final items = all.where((it) {
      final name = (it.barberFullName ?? '').toLowerCase();
      final svc = it.categoryLabel.toLowerCase();
      final okQ = q.isEmpty || name.contains(q) || svc.contains(q);
      final okS = _service == null || it.categoryLabel == _service;
      final okB = _barber == null || it.barberFullName == _barber;
      return okQ && okS && okB;
    }).toList();
    final editing = state.isEditing && widget.isBarberMode;

    return [
      SliverToBoxAdapter(
        child: _FilterArea(
          controller: _searchCtrl,
          onQuery: _onQueryChanged,
          byBarber: _byBarber,
          onMode: (b) => setState(() {
            _byBarber = b;
            _service = null;
            _barber = null;
          }),
          options: _byBarber ? barbers : services,
          selected: _byBarber ? _barber : _service,
          onSelect: (v) => setState(() {
            if (_byBarber) {
              _barber = v;
            } else {
              _service = v;
            }
          }),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      if (items.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Text(
                'Sin resultados',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childCount: items.length,
            itemBuilder: (context, i) {
              final card = SizedBox(
                height: _heights[i % _heights.length],
                child: _WorkCard(
                  item: items[i],
                  editing: editing,
                  onTap: () => _openFullscreen(context, items, i),
                  onDelete: items[i].id == null
                      ? null
                      : () => _delete(context, items[i].id!),
                ),
              );
              // Solo anima la primera vez que aparece esta foto (no en cada
              // scroll-in), para que no parpadee al desplazar la cuadricula.
              final key = items[i].externalId.isNotEmpty
                  ? items[i].externalId
                  : 'idx_$i';
              if (_animatedKeys.contains(key)) return card;
              _animatedKeys.add(key);
              return card
                  .animate()
                  .fadeIn(delay: (45 * (i % 8)).ms, duration: 380.ms)
                  .slideY(
                    begin: 0.12,
                    end: 0,
                    duration: 420.ms,
                    curve: Curves.easeOutCubic,
                  );
            },
          ),
        ),
    ];
  }
}

// ============================================================================
// BUSCADOR + FILTRO EN LÍNEA (interruptor Servicios / Barberos)
// ============================================================================

class _FilterArea extends StatelessWidget {
  const _FilterArea({
    required this.controller,
    required this.onQuery,
    required this.byBarber,
    required this.onMode,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final TextEditingController controller;
  final void Function(String) onQuery;
  final bool byBarber;
  final void Function(bool) onMode;
  final List<String> options;
  final String? selected;
  final void Function(String?) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: _SearchField(controller: controller, onChanged: onQuery),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _ModeToggle(byBarber: byBarber, onChanged: onMode),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _Chip(
                label: 'Todos',
                selected: selected == null,
                onTap: () => onSelect(null),
              ),
              for (final o in options) ...[
                const SizedBox(width: 8),
                _Chip(
                  label: o,
                  selected: selected == o,
                  onTap: () => onSelect(o),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 19,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: gold,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Buscar barbero o servicio',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.clear();
                  onChanged('');
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.byBarber, required this.onChanged});

  final bool byBarber;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          _seg(
            context,
            'Servicios',
            Icons.content_cut_rounded,
            !byBarber,
            () => onChanged(false),
          ),
          _seg(
            context,
            'Barberos',
            Icons.person_rounded,
            byBarber,
            () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _seg(
    BuildContext context,
    String label,
    IconData icon,
    bool active,
    VoidCallback onTap,
  ) {
    final gold = context.primaryGold;
    return Expanded(
      child: PremiumPressable(
        pressedScale: 0.97,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? gold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: active
                    ? premiumOnAccent(gold)
                    : Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? premiumOnAccent(gold)
                      : Colors.white.withValues(alpha: 0.6),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.95,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? gold : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? gold : Colors.white.withValues(alpha: 0.09),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected
                ? premiumOnAccent(gold)
                : Colors.white.withValues(alpha: 0.8),
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TARJETA DE LA CUADRICULA
// ============================================================================

class _WorkCard extends StatelessWidget {
  const _WorkCard({
    required this.item,
    required this.editing,
    required this.onTap,
    this.onDelete,
  });

  final GalleryItem item;
  final bool editing;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeImage(url: item.imageUrl, fit: BoxFit.cover),
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x40000000),
                        Color(0xE6000000),
                      ],
                      stops: [0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
              if (item.isFeatured)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: Icon(
                    Icons.star_rounded,
                    size: 19,
                    color: Color(0xFFFFC93C),
                  ),
                ),
              Positioned(
                left: 13,
                right: 13,
                bottom: 13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.barberFullName ?? 'Estilista',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        shadows: const [
                          Shadow(blurRadius: 5, color: Color(0xBB000000)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.categoryLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: premiumOnAccent(gold),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        if (item.price != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            'S/ ${_money(item.price!)}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              shadows: const [
                                Shadow(blurRadius: 5, color: Color(0xBB000000)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (editing && onDelete != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: _circleBtn(
                    Icons.close_rounded,
                    onDelete!,
                    color: const Color(0xFFE53935),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return PremiumPressable(
      pressedScale: 0.85,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: (color ?? Colors.white).withValues(alpha: 0.6),
            width: 1.1,
          ),
        ),
        child: Icon(icon, size: 15, color: color ?? Colors.white),
      ),
    );
  }
}
