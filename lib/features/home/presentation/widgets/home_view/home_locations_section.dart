import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/domain/models/home_content.dart';
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_edit_helpers.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_list_form_editors.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_edit_sheets.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';

class HomeLocationsSection extends StatelessWidget {
  const HomeLocationsSection({
    super.key,required this.content, required this.onReserve});
  final HomeContent content;
  final void Function(String branch)? onReserve;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionTitle(
              text: 'Visítanos',
              subtitle: 'Encuentra tu sucursal más cercana',
              onEdit: () => _showEditLocations(context, content),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < content.locations.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _LocationCard(
                location: content.locations[i],
                onReserve: onReserve,
              ),
            ],
          ],
        )
            .animate()
            .fadeIn(delay: 860.ms, duration: 600.ms),
      ),
    );
  }

  void _showEditLocations(BuildContext context, HomeContent content) {
    _LocationEditSheets.showList(context);
  }
}



class _LocationEditSheets {
  static const int _maxLocations = 5;

  static void showList(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (_, state) {
              return HomeListEditorSheet(
                title: 'Sucursales',
                subtitle: '${state.content.locations.length} / $_maxLocations',
                addLabel: '+ AGREGAR SUCURSAL',
                items: state.content.locations,
                titleKey: 'label',
                subtitleKey: 'address',
                imageKey: 'img',
                maxItems: _maxLocations,
                onAdd: () {
                  Navigator.pop(sheetCtx);
                  _showLocationForm(context);
                },
                onEdit: (i, data) {
                  Navigator.pop(sheetCtx);
                  _showLocationForm(context, index: i, initialData: data);
                },
                onRemove: (i) async {
                  final ok = await HomeEditSheets.confirmDelete(sheetCtx, 'esta sucursal');
                  if (ok) {
                    HapticFeedback.lightImpact();
                    // No hay removeLocation event — emulamos vía updateContent
                    final newLocs = List<Map<String, String>>.from(state.content.locations)
                      ..removeAt(i);
                    bloc.add(HomeEvent.updateContent(
                      state.content.copyWith(locations: newLocs),
                    ));
                  }
                },
                onClose: () => Navigator.pop(sheetCtx),
              );
            },
          ),
        );
      },
    );
  }

  static void _showLocationForm(
    BuildContext context, {
    int? index,
    Map<String, String>? initialData,
  }) {
    final labelCtrl = TextEditingController(text: initialData?['label'] ?? '');
    final addressCtrl = TextEditingController(text: initialData?['address'] ?? '');
    final mapCtrl = TextEditingController(text: initialData?['mapUrl'] ?? '');
    final bloc = context.read<HomeBloc>();
    String imgPath = initialData?['img'] ?? '';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (innerCtx, setSheet) {
            return HomeFormEditorSheet(
              title: index == null ? 'Nueva sucursal' : 'Editar sucursal',
              onClose: () => Navigator.pop(sheetCtx),
              onSave: () {
                homeConfirmAndSave(
                  context: innerCtx,
                  message: index == null
                      ? '¿Agregar esta sucursal?'
                      : '¿Guardar los cambios de la sucursal?',
                  onConfirm: () {
                    HapticFeedback.mediumImpact();
                    final data = {
                      ...?initialData,
                      'label': labelCtrl.text,
                      'address': addressCtrl.text,
                      'mapUrl': mapCtrl.text,
                      'img': imgPath,
                    };
                    if (index == null) {
                      final current = bloc.state.content;
                      final newLocs = List<Map<String, String>>.from(current.locations)
                        ..add(data);
                      bloc.add(HomeEvent.updateContent(
                        current.copyWith(locations: newLocs),
                      ));
                    } else {
                      bloc.add(HomeEvent.updateLocation(index, data));
                    }
                    Navigator.pop(sheetCtx);
                  },
                );
              },
              fields: [
                HomeEditField(label: 'NOMBRE DE LA SUCURSAL', controller: labelCtrl),
                const SizedBox(height: 10),
                HomeEditField(label: 'DIRECCIÓN', controller: addressCtrl, maxLines: 2),
                const SizedBox(height: 10),
                HomeEditField(
                  label: 'URL GOOGLE MAPS (opcional)',
                  controller: mapCtrl,
                  hint: 'https://maps.google.com/...',
                ),
                const SizedBox(height: 10),
                HomeImageFieldPicker(
                  label: 'FOTO DE LA SUCURSAL (opcional)',
                  path: imgPath,
                  aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
                  onPicked: (p) => setSheet(() => imgPath = p),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LocationCard extends StatefulWidget {
  const _LocationCard({required this.location, this.onReserve});
  final Map<String, String> location;
  final void Function(String branch)? onReserve;

  @override
  State<_LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<_LocationCard> {
  bool _expanded = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _expanded
              ? gold.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tappable
          GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _expanded = !_expanded);
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              color: _pressed
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.transparent,
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              child: Row(
                children: [
                  // Pill número (sede 1, 2, etc) — NO icono genérico
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: gold.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      'SEDE',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: gold,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.location['label'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: gold,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Contenido expandible
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dirección con line accent
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 2,
                        height: 26,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.location['address'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.55),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _LocationActionBtn(
                          label: 'ABRIR EN MAPAS',
                          isPrimary: false,
                          onTap: () => HapticFeedback.lightImpact(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _LocationActionBtn(
                          label: 'RESERVAR AQUÍ',
                          isPrimary: true,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onReserve?.call(widget.location['label'] ?? '');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}

class _LocationActionBtn extends StatefulWidget {
  const _LocationActionBtn({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  State<_LocationActionBtn> createState() => _LocationActionBtnState();
}

class _LocationActionBtnState extends State<_LocationActionBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? Colors.white
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.12),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: widget.isPrimary
                  ? Colors.black
                  : Colors.white.withValues(alpha: 0.78),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 9. SOCIAL FOOTER
// ============================================================================

