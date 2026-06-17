import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/admin/presentation/permissions/permissions_store.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_primitives.dart';

/// Header del perfil del barbero: avatar con anillo + greeting + nombre +
/// ID badge + botón settings.
class BarberProfileHeader extends StatelessWidget {
  const BarberProfileHeader({
    super.key,
    required this.user,
    required this.onAvatarTap,
    required this.onSettingsTap,
    required this.onOrdersTap,
  });

  final UserProfile user;
  final VoidCallback onAvatarTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onOrdersTap;

  String _idShort(UserProfile u) {
    final raw = u.barberId ?? u.id;
    if (raw.isEmpty) return '—';
    return raw.length >= 8 ? raw.substring(0, 8).toUpperCase() : raw.toUpperCase();
  }

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
              _AvatarRing(
                photoUrl: user.photoUrl,
                initials: initials,
                gold: gold,
                onTap: onAvatarTap,
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
                        .slideY(begin: 0.3, end: 0, delay: 80.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 2),
                    Text(
                      fullName.isEmpty ? 'Barbero' : fullName,
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
                        .slideY(begin: 0.2, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: gold.withValues(alpha: 0.18)),
                      ),
                      child: Text(
                        'BARBERO · ${_idShort(user)}',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: gold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ).animate().fadeIn(delay: 160.ms, duration: 500.ms),
                  ],
                ),
              ),
              ValueListenableBuilder<PreviewRole?>(
                valueListenable: PermissionsStore.instance.preview,
                builder: (context, _, _) {
                  if (!PermissionsStore.instance.can('orders_manage')) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BarberIconButton(
                        icon: Icons.shopping_bag_outlined,
                        onTap: onOrdersTap,
                      )
                          .animate()
                          .fadeIn(delay: 170.ms, duration: 500.ms)
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1, 1),
                            delay: 170.ms,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(width: 10),
                    ],
                  );
                },
              ),
              BarberIconButton(
                icon: Icons.settings_outlined,
                onTap: onSettingsTap,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    delay: 200.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarRing extends StatefulWidget {
  const _AvatarRing({
    required this.photoUrl,
    required this.initials,
    required this.gold,
    required this.onTap,
  });

  final String photoUrl;
  final String initials;
  final Color gold;
  final VoidCallback onTap;

  @override
  State<_AvatarRing> createState() => _AvatarRingState();
}

class _AvatarRingState extends State<_AvatarRing> {
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
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 48, height: 48,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: widget.gold.withValues(alpha: 0.5), width: 1.4),
          ),
          child: ClipOval(
            child: widget.photoUrl.isEmpty
                ? _fallback()
                : CachedNetworkImage(
                    imageUrl: widget.photoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _fallback(),
                    placeholder: (_, _) => _fallback(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF181818),
      alignment: Alignment.center,
      child: Text(
        widget.initials,
        style: GoogleFonts.inter(
          color: widget.gold,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
