import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === TOP ROW: brand pill + edit toggle (barber) + bell ===
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (_, hs) {
                        if (hs.isEditing) {
                          return _EditingActiveBar();
                        }
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: gold.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              'TRIMFLOW PREMIUM',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: gold,
                                letterSpacing: 1.6,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Edit toggle — SOLO visible en modo barbero
                  BlocBuilder<AppModeBloc, AppModeState>(
                    buildWhen: (a, b) => a.mode != b.mode,
                    builder: (_, appState) {
                      if (appState.mode != AppMode.barber) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: BlocBuilder<HomeBloc, HomeState>(
                          builder: (ctx, hs) => _EditToggleButton(
                            isEditing: hs.isEditing,
                            onTap: () => ctx
                                .read<HomeBloc>()
                                .add(const HomeEvent.toggleEditMode()),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 22),

              // === GREETING BIG ===
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (_, ps) {
                  final firstName = ps.user?.firstName.trim() ?? '';
                  final hour = DateTime.now().hour;
                  final g = hour < 12
                      ? 'Buenos días'
                      : hour < 19
                          ? 'Buenas tardes'
                          : 'Buenas noches';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        g,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.55),
                          letterSpacing: -0.2,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                      const SizedBox(height: 4),
                      // Nombre BIG (multi-line si nombre largo)
                      Text(
                        firstName.isEmpty ? 'Bienvenido' : firstName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.6,
                          height: 1.05,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
                      const SizedBox(height: 4),
                      // Sub-tagline con accent dorado
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 1.5,
                            color: gold,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Listo para tu próximo corte',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.45),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 320.ms, duration: 500.ms),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill prominente que indica "EDITANDO INICIO" cuando el modo edición está activo.
class _EditingActiveBar extends StatefulWidget {
  @override
  State<_EditingActiveBar> createState() => _EditingActiveBarState();
}

class _EditingActiveBarState extends State<_EditingActiveBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF8A95);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10 + 0.05 * _pulse.value),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accent.withValues(alpha: 0.35 + 0.2 * _pulse.value),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18 * _pulse.value),
                blurRadius: 10,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.6 + 0.4 * _pulse.value),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.5 * _pulse.value),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'EDICIÓN ACTIVA · INICIO',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditToggleButton extends StatefulWidget {
  const _EditToggleButton({required this.isEditing, required this.onTap});
  final bool isEditing;
  final VoidCallback onTap;

  @override
  State<_EditToggleButton> createState() => _EditToggleButtonState();
}

class _EditToggleButtonState extends State<_EditToggleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final active = widget.isEditing;
    final color = active ? const Color(0xFFFF8A95) : gold;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: 0.12)
                : const Color(0xFF161616),
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Icon(
            active ? Icons.check_rounded : Icons.edit_rounded,
            size: 17,
            color: active ? color : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. BRAND HERO
// ============================================================================

