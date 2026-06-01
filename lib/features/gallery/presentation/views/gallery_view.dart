// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/view/barber_home_page.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_admin_dashboard_view.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_create_form_view.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_fullscreen_viewer.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_card.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_dual_filter_bar.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_favorites_sheet.dart';


class GalleryView extends StatelessWidget {
  const GalleryView({super.key, required this.isBarberMode});

  final bool isBarberMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GalleryBloc>()..add(const GalleryEvent.loadRequested()),
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  Timer? _inactivityTimer;
  Timer? _scrollTimer;
  List<String> _currentKeys = [];
  Map<String, List<GalleryItem>> _groupedItems = {};

  @override
  void initState() {
    super.initState();
    _resetInactivityTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncGroupsFromState(context.read<GalleryBloc>().state);
    });
  }

  void _syncGroupsFromState(GalleryState state) {
    if (!mounted) return;
    final grouped = <String, List<GalleryItem>>{};
    for (var item in state.visibleItems) {
      final name = item.barberFullName ?? 'ESTILISTA';
      final cat = item.categoryLabel;
      final key = '$name - $cat';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    setState(() {
      _currentKeys = sortedKeys;
      _groupedItems = grouped;
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _scrollTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 6), _startAutoScroll);
  }

  void _startAutoScroll() {
    if (!mounted) return;
    _scrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentKeys.length <= 1) return;

      final removedKey = _currentKeys.removeAt(0);
      final removedItems = _groupedItems[removedKey] ?? [];
      
      _listKey.currentState?.removeItem(
        0,
        (context, animation) => _buildAnimatedBlock(context, removedKey, removedItems, animation, true),
        duration: const Duration(milliseconds: 600),
      );

      _currentKeys.add(removedKey);
      _listKey.currentState?.insertItem(
        _currentKeys.length - 1,
        duration: const Duration(milliseconds: 600),
      );
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GalleryBloc, GalleryState>(
      listenWhen: (prev, curr) =>
          prev.visibleItems.length != curr.visibleItems.length ||
          !identical(prev.visibleItems, curr.visibleItems),
      listener: (context, state) => _syncGroupsFromState(state),
      builder: (context, state) {
        return Listener(
          onPointerDown: (_) => _resetInactivityTimer(),
          onPointerMove: (_) => _resetInactivityTimer(),
          onPointerUp: (_) => _resetInactivityTimer(),
          child: Scaffold(
            backgroundColor: context.backgroundBlack,
            body: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _GalleryHeader(isBarberMode: widget.isBarberMode, state: state),
                SliverToBoxAdapter(child: _buildQuickActions(context, state)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _GallerySearchBar(controller: _searchCtrl),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: GalleryDualFilterBar(
                    filterMode: state.filterMode,
                    categories: state.categories,
                    selectedCategorySlug: state.selectedCategorySlug,
                    barbers: state.availableBarbers,
                    selectedBarberName: state.selectedBarberName,
                    onModeChanged: (mode) => context
                        .read<GalleryBloc>()
                        .add(GalleryEvent.filterModeChanged(mode)),
                    onCategorySelected: (slug) => context
                        .read<GalleryBloc>()
                        .add(GalleryEvent.categoryChanged(slug)),
                    onBarberSelected: (name) => context
                        .read<GalleryBloc>()
                        .add(GalleryEvent.barberSelected(name)),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ..._buildGroupedSlivers(context, state),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, GalleryState state) {
    if (!widget.isBarberMode || !state.isEditing) {
      return const SizedBox.shrink();
    }
    final gb = context.read<GalleryBloc>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              label: 'NUEVO PORTAFOLIO',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: gb,
                      child: const GalleryCreateFormView(),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              label: 'PANEL ADMIN',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: gb,
                    child: const GalleryAdminDashboardView(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedSlivers(BuildContext context, GalleryState state) {
    if (state.status == GalleryStatus.loading ||
        state.status == GalleryStatus.initial) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: Center(
              child: CircularProgressIndicator(
                color: context.primaryGold,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ];
    }

    final items = state.visibleItems;
    if (items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
            child: _EmptyState(isEditing: state.isEditing && widget.isBarberMode),
          ),
        ),
      ];
    }

    if (_currentKeys.isEmpty) return [const SliverToBoxAdapter(child: SizedBox.shrink())];

    return [
      SliverAnimatedList(
        key: _listKey,
        initialItemCount: _currentKeys.length,
        itemBuilder: (context, index, animation) {
          if (index >= _currentKeys.length) return const SizedBox.shrink();
          final key = _currentKeys[index];
          final groupItems = _groupedItems[key] ?? [];
          return _buildAnimatedBlock(context, key, groupItems, animation, false);
        },
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ];
  }

  Widget _buildAnimatedBlock(BuildContext context, String key, List<GalleryItem> groupItems, Animation<double> animation, bool isRemoving) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: isRemoving ? 1.0 : -1.0,
      child: FadeTransition(
        opacity: animation,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                children: [
                  Text(
                    key.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 2,
                    color: context.primaryGold,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: groupItems.length,
                itemBuilder: (context, index) {
                  final item = groupItems[index];
                  final globalIndex = context.read<GalleryBloc>().state.visibleItems.indexOf(item);
                  final height = 250.0;
                  final itemId = item.id;
                  return GalleryMasonryCard(
                    item: item,
                    height: height,
                    isEditing: widget.isBarberMode && context.read<GalleryBloc>().state.isEditing,
                    isFirstItem: index == 0,
                    onTap: () => _openFullscreen(context, context.read<GalleryBloc>().state.visibleItems, globalIndex),
                    onDelete: itemId == null
                        ? () {}
                        : () => context
                            .read<GalleryBloc>()
                            .add(GalleryEvent.itemDeleted(itemId)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, List items, int index) {
    final bloc = context.read<GalleryBloc>();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: GalleryFullscreenViewer(
          items: items.cast(),
          initialIndex: index,
        ),
      ),
    ));
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({required this.isBarberMode, required this.state});

  final bool isBarberMode;
  final GalleryState state;

  @override
  Widget build(BuildContext context) {
    final featuredCount = state.allItems.where((it) => it.isFeatured).length;
    final gold = context.primaryGold;
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.images, color: gold, size: 24),
                  if (isBarberMode) ...[
                    const SizedBox(width: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: BarberHomePage.showBarberBadge,
                      builder: (context, showBadge, child) {
                        if (!showBadge) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: gold,
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
                  const Spacer(),
                  GalleryFavoritesActionIcon(
                    count: featuredCount,
                    onTap: () => GalleryFavoritesSheet.show(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'GALERIA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  if (isBarberMode) ...[
                    const SizedBox(width: 12),
                    const _EditToggle(),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Container(width: 40, height: 3, color: gold),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditToggle extends StatelessWidget {
  const _EditToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => context
              .read<GalleryBloc>()
              .add(const GalleryEvent.editModeToggled()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: state.isEditing ? Colors.white : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.primaryGold.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              state.isEditing ? 'LISTO' : 'EDITAR GALERIA',
              style: TextStyle(
                color: state.isEditing ? Colors.black : context.primaryGold,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: context.primaryGold.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFF5F5DC),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _GallerySearchBar extends StatelessWidget {
  const _GallerySearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) => context
            .read<GalleryBloc>()
            .add(GalleryEvent.searchChanged(value)),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: context.primaryGold,
        decoration: InputDecoration(
          hintText: 'Buscar estilo, barbero o categoria...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.primaryGold.withOpacity(0.6),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isEditing});
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      children: [
        FaIcon(FontAwesomeIcons.scissors,
            color: gold.withValues(alpha: 0.18), size: 56),
        const SizedBox(height: 18),
        Text(
          isEditing ? 'AGREGA TU PRIMERA FOTO' : 'AUN NO HAY PIEZAS',
          style: TextStyle(
            color: gold,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isEditing
              ? 'Activa EDITAR GALERIA y abre el panel administrativo.'
              : 'Vuelve pronto, estamos curando el portafolio.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}
