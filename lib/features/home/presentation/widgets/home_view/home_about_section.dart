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
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';

class HomeAboutSection extends StatefulWidget {
  const HomeAboutSection({
    super.key,required this.content});
  final HomeContent content;

  @override
  State<HomeAboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<HomeAboutSection> {

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final hasVideo = widget.content.aboutUsVideoUrl.isNotEmpty;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionTitle(
              text: widget.content.aboutUsTitle,
              subtitle: 'Conoce nuestra historia',
              onEdit: () => _showEditAbout(context, widget.content),
            ),
            const SizedBox(height: 12),
            // Hero image grande arriba con fade hacia el body
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    HomeSmartImage(path: widget.content.aboutUsImageUrl),
                    // Fade hacia el bottom (más oscuro abajo)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Play button si hay video — sin glow excesivo, elegante
                    if (hasVideo)
                      Center(
                        child: HomePressable(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _showVideoSheet(context, widget.content.aboutUsVideoUrl);
                          },
                          pressedScale: 0.92,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    // Texto sobre la imagen — quote + paragraph
                    Positioned(
                      left: 22,
                      right: 22,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 1.5,
                            color: gold,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.content.aboutUsText,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.92),
                              height: 1.55,
                              letterSpacing: -0.1,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                  color: Color(0xCC000000),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasVideo) ...[
              const SizedBox(height: 10),
              HomePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showVideoSheet(context, widget.content.aboutUsVideoUrl);
                },
                pressedScale: 0.99,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_outline_rounded, color: gold, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Ver video completo',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_rounded, color: gold, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ],
        )
            .animate()
            .fadeIn(delay: 740.ms, duration: 600.ms),
      ),
    );
  }

  void _showEditAbout(BuildContext context, HomeContent content) {
    final textCtrl = TextEditingController(text: content.aboutUsText);
    final videoCtrl = TextEditingController(text: content.aboutUsVideoUrl);
    final bloc = context.read<HomeBloc>();
    String imgPath = content.aboutUsImageUrl;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (innerCtx, setSheet) {
            return HomeFormEditorSheet(
              title: 'Editar sección',
              onClose: () => Navigator.pop(sheetCtx),
              onSave: () {
                homeConfirmAndSave(
                  context: innerCtx,
                  message: '¿Guardar cambios de Sobre Nosotros?',
                  onConfirm: () {
                    HapticFeedback.mediumImpact();
                    bloc.add(HomeEvent.updateAboutUs(
                      text: textCtrl.text,
                      videoUrl: videoCtrl.text,
                      imageUrl: imgPath,
                    ));
                    Navigator.pop(sheetCtx);
                  },
                );
              },
              fields: [
                HomeEditField(label: 'TEXTO', controller: textCtrl, maxLines: 4),
                const SizedBox(height: 10),
                HomeEditField(
                  label: 'URL VIDEO (YouTube)',
                  controller: videoCtrl,
                  hint: 'https://youtube.com/...',
                ),
                const SizedBox(height: 10),
                HomeImageFieldPicker(
                  label: 'IMAGEN',
                  path: imgPath,
                  aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 10),
                  onPicked: (p) => setSheet(() => imgPath = p),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showVideoSheet(BuildContext context, String url) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Video',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link_rounded,
                    color: context.primaryGold,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      url,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'El video se abrirá en tu navegador o app de YouTube.',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 8. UBICACIONES
// ============================================================================

