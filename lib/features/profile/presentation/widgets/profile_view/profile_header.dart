import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_primitives.dart';

class ProfileViewHeader extends StatelessWidget {
  const ProfileViewHeader({
    super.key,
    required this.user,
    required this.onAvatarTap,
    required this.onSettingsTap,
    required this.onOrdersTap,
    this.hasActiveOrders = false,
    this.clientCode,
  });

  final UserProfile user;
  final VoidCallback onAvatarTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onOrdersTap;
  final bool hasActiveOrders;
  final String? clientCode;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 19
            ? 'Buenas tardes'
            : 'Buenas noches';
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    final initials = fullName.isEmpty
        ? '?'
        : fullName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();

    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Row(
            children: [
              // Avatar tappable → editar
              ProfilePressableScale(
                onTap: onAvatarTap,
                pressedScale: 0.92,
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: gold.withValues(alpha: 0.5),
                      width: 1.4,
                    ),
                  ),
                  child: ClipOval(
                    child: user.photoUrl.isEmpty
                        ? _initialsFallback(initials, gold)
                        : CachedNetworkImage(
                            imageUrl: user.photoUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) =>
                                _initialsFallback(initials, gold),
                            placeholder: (_, _) =>
                                _initialsFallback(initials, gold),
                          ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(width: 14),

              // Greeting + nombre completo + ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.42),
                        letterSpacing: 0.2,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 500.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 80.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 2),
                    Text(
                      fullName.isEmpty ? 'Usuario' : fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 120.ms, duration: 500.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 120.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 4),
                    _HeaderIdBadge(id: (clientCode != null && clientCode!.isNotEmpty) ? clientCode! : _headerIdFor(user))
                        .animate()
                        .fadeIn(delay: 160.ms, duration: 500.ms),
                  ],
                ),
              ),

              // Campanita de pedidos
              _OrdersBellButton(onTap: onOrdersTap, active: hasActiveOrders)
                  .animate()
                  .fadeIn(delay: 160.ms, duration: 500.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    delay: 160.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(width: 10),

              // Settings gear
              ProfilePressableScale(
                onTap: onSettingsTap,
                pressedScale: 0.88,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 180.ms, duration: 500.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    delay: 180.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialsFallback(String initials, Color gold) {
    return Container(
      color: const Color(0xFF181818),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          color: gold,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _headerIdFor(UserProfile u) {
    final raw = u.customerId ?? u.id;
    if (raw.isEmpty) return '—';
    return raw.length >= 8 ? raw.substring(0, 8).toUpperCase() : raw.toUpperCase();
  }
}

/// Campanita de pedidos (junto al engranaje). Vibra y muestra un dot dorado
/// cuando hay un pedido activo (por pagar / pagado / listo).
class _OrdersBellButton extends StatelessWidget {
  const _OrdersBellButton({required this.onTap, required this.active});

  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    Widget bell = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Icon(
        Icons.notifications_none_rounded,
        size: 19,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );

    if (active) {
      bell = bell
          .animate(onPlay: (c) => c.repeat())
          .shake(hz: 4, duration: 500.ms, rotation: 0.06)
          .then(delay: 2200.ms);
    }

    return ProfilePressableScale(
      onTap: onTap,
      pressedScale: 0.88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          bell,
          if (active)
            Positioned(
              top: 1,
              right: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0A0A0A), width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Badge ID compacto debajo del nombre en el header (dorado outline pill).
class _HeaderIdBadge extends StatelessWidget {
  const _HeaderIdBadge({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: gold.withValues(alpha: 0.18)),
      ),
      child: Text(
        'ID · $id',
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: gold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ============================================================================
// 2. FIDELITY HERO — Anillo animado estilo Apple Fitness
// ============================================================================

