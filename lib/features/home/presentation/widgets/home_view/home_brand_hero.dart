import 'package:trim_flow/features/home/presentation/widgets/home_view/home_list_form_editors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/domain/models/home_content.dart';
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_edit_helpers.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';

class HomeBrandHero extends StatelessWidget {
  const HomeBrandHero({
    super.key,required this.content});
  final HomeContent content;

  /// Nombre real del negocio activo (TenantThemeBloc). Si content.heroTitle ya
  /// trae un valor editado se respeta; si no, se usa el name del tenant activo.
  /// Nunca devuelve datos mockeados.
  String _resolvedTitle(BuildContext context) {
    if (content.heroTitle.isNotEmpty) return content.heroTitle;
    final theme = context.watch<TenantThemeBloc>().state;
    final active = theme.availableTenants
        .where((t) => t.id == theme.tenantId)
        .firstOrNull;
    return active?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final title = _resolvedTitle(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 16 / 11,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen de fondo
                HomeSmartImage(path: content.heroImageUrl),
                // Overlay gradiente para legibilidad
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      // Eyebrow tag (solo si hay etiqueta real)
                      if (content.heroTag1.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: gold.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                content.heroTag1,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: gold,
                                  letterSpacing: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.8,
                          height: 1.05,
                        ),
                      ),
                      if (content.heroSubtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          content.heroSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // === Edit pencil flotante top-right (solo en modo edición) ===
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (_, hs) {
                    if (!hs.isEditing) return const SizedBox.shrink();
                    return Positioned(
                      top: 14,
                      right: 14,
                      child: HomeMiniEditPencil(
                        onTap: () => _showEditHero(context, content),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 120.ms, duration: 700.ms)
            .slideY(
              begin: 0.06,
              end: 0,
              delay: 120.ms,
              duration: 700.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }

  void _showEditHero(BuildContext context, HomeContent content) {
    final titleCtrl = TextEditingController(text: content.heroTitle);
    final subtitleCtrl = TextEditingController(text: content.heroSubtitle);
    final tag1Ctrl = TextEditingController(text: content.heroTag1);
    final bloc = context.read<HomeBloc>();
    String imagePath = content.heroImageUrl;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (innerCtx, setSheet) {
            return HomeFormEditorSheet(
              title: 'Editar portada',
              onClose: () => Navigator.pop(sheetCtx),
              onSave: () {
                homeConfirmAndSave(
                  context: innerCtx,
                  message: '¿Guardar cambios de la portada?',
                  onConfirm: () {
                    HapticFeedback.mediumImpact();
                    bloc.add(HomeEvent.updateHero(
                      title: titleCtrl.text,
                      subtitle: subtitleCtrl.text,
                      imageUrl: imagePath,
                      tag1: tag1Ctrl.text,
                    ));
                    Navigator.pop(sheetCtx);
                  },
                );
              },
              fields: [
                HomeEditField(label: 'ETIQUETA', controller: tag1Ctrl),
                const SizedBox(height: 10),
                HomeEditField(label: 'TÍTULO', controller: titleCtrl, maxLines: 2),
                const SizedBox(height: 10),
                HomeEditField(label: 'SUBTÍTULO', controller: subtitleCtrl, maxLines: 2),
                const SizedBox(height: 10),
                HomeImageFieldPicker(
                  label: 'IMAGEN DE PORTADA',
                  path: imagePath,
                  height: 140,
                  aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 11),
                  onPicked: (p) => setSheet(() => imagePath = p),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Diálogo de confirmación reutilizable para guardar cambios.

