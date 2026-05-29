import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/staff/domain/models/staff_member.dart';
import 'package:trim_flow/core/staff/domain/repositories/staff_repository.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_create_form_view.dart';


class GalleryAdminDashboardView extends StatefulWidget {
  const GalleryAdminDashboardView({super.key});

  @override
  State<GalleryAdminDashboardView> createState() => _GalleryAdminDashboardViewState();
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PANEL ADMINISTRATIVO',
          style: TextStyle(
            color: Color(0xFFF5F5DC),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: gold,
          dividerColor: Colors.transparent,
          labelColor: gold,
          unselectedLabelColor: Colors.white30,
          labelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
          tabs: const [
            Tab(text: 'PORTAFOLIOS', icon: Icon(Icons.photo_library_outlined, size: 18)),
            Tab(text: 'STAFF', icon: Icon(Icons.groups_2_outlined, size: 18)),
            Tab(text: 'CATEGORIAS', icon: Icon(Icons.label_outline_rounded, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PortfoliosTab(),
          _StaffTab(),
          _CategoriesTab(),
        ],
      ),
    );
  }
}

class _PortfoliosTab extends StatelessWidget {
  const _PortfoliosTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        final gb = context.read<GalleryBloc>();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: gb,
                      child: const GalleryCreateFormView(),
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryGold,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text(
                  'CREAR NUEVO PORTAFOLIO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.allItems.isEmpty
                  ? const Center(
                      child: Text(
                        'AUN NO HAY PORTAFOLIOS',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: state.allItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = state.allItems[i];
                        return _PortfolioTile(
                          item: item,
                          onEdit: () => _openEdit(context, gb, item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _openEdit(BuildContext context, GalleryBloc gb, GalleryItem item) {
    final baseId = item.externalId.replaceAll(RegExp(r'_\d+$'), '');
    final groupItems = gb.state.allItems.where((i) {
      return i.externalId.replaceAll(RegExp(r'_\d+$'), '') == baseId;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: gb,
          child: GalleryCreateFormView(editingGroup: groupItems.isEmpty ? [item] : groupItems),
        ),
      ),
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({required this.item, required this.onEdit});

  final GalleryItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SafeImage(
              url: item.imageUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item.barberFullName ?? 'Sin barbero').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.categoryLabel.toUpperCase(),
                  style: TextStyle(
                    color: gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: gold,
              side: BorderSide(color: gold.withValues(alpha: 0.45)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text(
              'EDITAR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffTab extends StatefulWidget {
  const _StaffTab();

  @override
  State<_StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends State<_StaffTab> {
  late Future<List<StaffMember>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<StaffMember>> _load() {
    final repo = getIt<StaffRepository>();
    final tenantId = getIt<TenantThemeBloc>().state.tenantId;
    final resolved = tenantId == kDefaultTenantId ? null : tenantId;
    return repo.listActiveBarbers(tenantId: resolved);
  }

  Future<void> _refresh() async {
    final next = await _load();
    if (!mounted) return;
    setState(() => _future = Future.value(next));
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return FutureBuilder<List<StaffMember>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: gold, strokeWidth: 2),
          );
        }
        final list = snap.data ?? const [];
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_2_outlined,
                      color: Colors.white.withValues(alpha: 0.18), size: 56),
                  const SizedBox(height: 14),
                  const Text(
                    'SIN STAFF REGISTRADO',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pide a tu administrador agregar barberos en profiles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          color: gold,
          backgroundColor: const Color(0xFF111111),
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _StaffTile(member: list[i]),
          ),
        );
      },
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          AvatarPremium(
            displayName: member.fullName,
            photoUrl: member.avatarUrl,
            size: 46,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                if (member.specialty != null && member.specialty!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    member.specialty!,
                    style: TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: gold.withValues(alpha: 0.3)),
            ),
            child: Text(
              member.role.toUpperCase(),
              style: TextStyle(
                color: gold,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: GestureDetector(
                onTap: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (c) => const _CategoryDialog(
                      title: 'NUEVA CATEGORIA',
                      initialValue: '',
                    ),
                  );
                  if (result != null && result.isNotEmpty && context.mounted) {
                    context.read<GalleryBloc>().add(GalleryEvent.categoryAdded(result));
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.primaryGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.black, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'NUEVA CATEGORIA',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final cat = state.categories[index];
                  return _CategoryTile(label: cat.label, slug: cat.slug);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.label, required this.slug});

  final String label;
  final String slug;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (c) => _CategoryDialog(
                  title: 'EDITAR CATEGORIA',
                  initialValue: label,
                ),
              );
              if (result != null && result.isNotEmpty && result != label && context.mounted) {
                context.read<GalleryBloc>().add(GalleryEvent.categoryUpdated(slug, result));
              }
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.trashCan, color: Colors.redAccent, size: 14),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  title: const Text(
                    'Eliminar Categoria',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Esta accion no se puede deshacer. ¿Continuar?',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('ELIMINAR', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                context.read<GalleryBloc>().add(GalleryEvent.categoryDeleted(slug));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final String title;
  final String initialValue;

  const _CategoryDialog({required this.title, required this.initialValue});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(
        widget.title,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Nombre de la categoria',
          hintStyle: const TextStyle(color: Colors.white38),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.primaryGold.withValues(alpha: 0.3)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.primaryGold),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          child: Text(
            'GUARDAR',
            style: TextStyle(color: context.primaryGold, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
