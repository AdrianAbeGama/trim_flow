import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/domain/models/home_content.dart';
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_social_wizard.dart';


class HomeSocialFooter extends StatelessWidget {
  const HomeSocialFooter({
    super.key,required this.content});
  final HomeContent content;

  static List<HomeSocialSpec> get _socials => [
        HomeSocialSpec('instagram', 'Instagram', const Color(0xFFE1306C),
            (c, s) => FaIcon(FontAwesomeIcons.instagram, color: c, size: s)),
        HomeSocialSpec('tiktok', 'TikTok', const Color(0xFF00F2EA),
            (c, s) => FaIcon(FontAwesomeIcons.tiktok, color: c, size: s)),
        HomeSocialSpec('whatsapp', 'WhatsApp', const Color(0xFF25D366),
            (c, s) => FaIcon(FontAwesomeIcons.whatsapp, color: c, size: s)),
        HomeSocialSpec('facebook', 'Facebook', const Color(0xFF1877F2),
            (c, s) => FaIcon(FontAwesomeIcons.facebook, color: c, size: s)),
        HomeSocialSpec('youtube', 'YouTube', const Color(0xFFFF0000),
            (c, s) => FaIcon(FontAwesomeIcons.youtube, color: c, size: s)),
        HomeSocialSpec('x', 'X', const Color(0xFFFFFFFF),
            (c, s) => FaIcon(FontAwesomeIcons.xTwitter, color: c, size: s)),
        HomeSocialSpec('threads', 'Threads', const Color(0xFFFFFFFF),
            (c, s) => FaIcon(FontAwesomeIcons.threads, color: c, size: s)),
        HomeSocialSpec('snapchat', 'Snapchat', const Color(0xFFFFFC00),
            (c, s) => FaIcon(FontAwesomeIcons.snapchat, color: c, size: s)),
        HomeSocialSpec('linkedin', 'LinkedIn', const Color(0xFF0A66C2),
            (c, s) => FaIcon(FontAwesomeIcons.linkedin, color: c, size: s)),
        HomeSocialSpec('telegram', 'Telegram', const Color(0xFF26A5E4),
            (c, s) => FaIcon(FontAwesomeIcons.telegram, color: c, size: s)),
        HomeSocialSpec('pinterest', 'Pinterest', const Color(0xFFE60023),
            (c, s) => FaIcon(FontAwesomeIcons.pinterest, color: c, size: s)),
        HomeSocialSpec('web', 'Web', const Color(0xFFD4AF37),
            (c, s) => FaIcon(FontAwesomeIcons.globe, color: c, size: s)),
      ];

  /// Solo muestra las redes que están seleccionadas (link no null/empty
  /// O bien todas las primeras 4 si no hay ninguna configurada — fallback).
  static List<HomeSocialSpec> _visibleSocials(HomeContent content) {
    final configured = _socials
        .where((s) => content.socialLinks.containsKey(s.key))
        .toList();
    if (configured.isEmpty) {
      // fallback: las 4 principales
      return _socials.take(4).toList();
    }
    return configured;
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SÍGUENOS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.42),
                    letterSpacing: 2.2,
                  ),
                ),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (_, hs) {
                    if (!hs.isEditing) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: HomeMiniEditPencil(
                        onTap: () => _showEditSocial(context, content),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Wrap para soportar muchas redes (no salirse de pantalla)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 16,
              children: [
                for (var i = 0; i < _visibleSocials(content).length; i++)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HomeSocialButton(
                        spec: _visibleSocials(content)[i],
                        enabled: (content.socialLinks[_visibleSocials(content)[i].key] ?? '').isNotEmpty,
                        phaseOffset: i * 0.6,
                      )
                          .animate()
                          .fadeIn(
                            delay: (1000 + i * 80).ms,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .scale(
                            begin: const Offset(0.4, 0.4),
                            end: const Offset(1, 1),
                            delay: (1000 + i * 80).ms,
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 8),
                      Text(
                        _visibleSocials(content)[i].label,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.55),
                          letterSpacing: 0.2,
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: (1100 + i * 80).ms,
                            duration: 500.ms,
                          ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'TRIMFLOW · © 2026',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.15),
                letterSpacing: 2.4,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 980.ms, duration: 600.ms),
      ),
    );
  }

  void _showEditSocial(BuildContext context, HomeContent content) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: context.read<HomeBloc>(),
          child: HomeSocialWizardSheet(
            socials: _socials,
            initialContent: content,
            onClose: () => Navigator.pop(sheetCtx),
          ),
        );
      },
    );
  }
}

/// Wizard de 2 pasos para configurar redes sociales:
/// PASO 1: chips multi-selección — elegir qué redes activar
/// PASO 2: lista con URL input solo para las activadas
class HomeSocialButton extends StatefulWidget {
  const HomeSocialButton({
    super.key,
    required this.spec,
    required this.enabled,
    required this.phaseOffset,
  });

  final HomeSocialSpec spec;
  final bool enabled;
  /// Desfase en segundos del ciclo de color para crear efecto wave.
  final double phaseOffset;

  @override
  State<HomeSocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<HomeSocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _cycle;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    // Ciclo lento de color: 2.5s ida, 2.5s vuelta
    _cycle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    if (widget.enabled) {
      _cycle.repeat(reverse: true);
    }
    // Desfase inicial para que cada botón empiece en momento distinto
    Future<void>.delayed(
      Duration(milliseconds: (widget.phaseOffset * 1000).toInt()),
      () {
        if (mounted && widget.enabled) {
          _cycle.value = 0;
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant HomeSocialButton old) {
    super.didUpdateWidget(old);
    if (old.enabled != widget.enabled) {
      if (widget.enabled) {
        _cycle.repeat(reverse: true);
      } else {
        _cycle.stop();
      }
    }
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final brand = widget.spec.brandColor;
    final neutral = widget.enabled ? gold : Colors.white.withValues(alpha: 0.18);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.enabled ? () => HapticFeedback.lightImpact() : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 140),
        child: AnimatedBuilder(
          animation: _cycle,
          builder: (_, _) {
            // Interpolación dorado ↔ brand color (cycle 0..1..0)
            final t = widget.enabled ? _cycle.value : 0.0;
            final iconColor = Color.lerp(neutral, brand, t) ?? neutral;
            final bgColor = widget.enabled
                ? Color.lerp(
                    gold.withValues(alpha: 0.08),
                    brand.withValues(alpha: 0.12),
                    t,
                  )!
                : Colors.white.withValues(alpha: 0.02);
            final borderColor = widget.enabled
                ? Color.lerp(
                    gold.withValues(alpha: 0.28),
                    brand.withValues(alpha: 0.45),
                    t,
                  )!
                : Colors.white.withValues(alpha: 0.05);

            return Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: widget.enabled
                    ? [
                        BoxShadow(
                          color: brand.withValues(alpha: 0.15 * t),
                          blurRadius: 10 * t,
                          spreadRadius: 1 * t,
                        ),
                      ]
                    : null,
              ),
              child: widget.spec.builder(iconColor, 22),
            );
          },
        ),
      ),
    );
  }
}
