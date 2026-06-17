import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

/// Hoja premium para gestionar la foto de perfil del barbero. Al tocar una
/// opcion cierra la hoja y dispara la accion de inmediato (la cámara/galería
/// arranca en paralelo al cierre, sin esperar la animacion). El trabajo lo hace
/// la pantalla de Perfil para que siga vivo aunque el SO recree la activity.
class BarberAvatarSheet {
  static Future<void> show(
    BuildContext context, {
    required UserProfile user,
    required VoidCallback onGallery,
    required VoidCallback onCamera,
    required VoidCallback onRemove,
    required VoidCallback onEditData,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AvatarSheetBody(
        user: user,
        onGallery: onGallery,
        onCamera: onCamera,
        onRemove: onRemove,
        onEditData: onEditData,
      ),
    );
  }
}

class _AvatarSheetBody extends StatelessWidget {
  const _AvatarSheetBody({
    required this.user,
    required this.onGallery,
    required this.onCamera,
    required this.onRemove,
    required this.onEditData,
  });

  final UserProfile user;
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onRemove;
  final VoidCallback onEditData;

  void _run(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    final hasPhoto = user.photoUrl.trim().isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              _Preview(name: fullName, photoUrl: user.photoUrl, gold: gold),
              const SizedBox(height: 18),
              Text(
                'Foto de perfil',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cámbiala o quítala cuando quieras.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              _Option(
                icon: Icons.photo_library_outlined,
                label: 'Elegir de la galería',
                gold: gold,
                onTap: () => _run(context, onGallery),
              ),
              _divider(),
              _Option(
                icon: Icons.photo_camera_outlined,
                label: 'Tomar una foto',
                gold: gold,
                onTap: () => _run(context, onCamera),
              ),
              if (hasPhoto) ...[
                _divider(),
                _Option(
                  icon: Icons.person_off_outlined,
                  label: 'Quitar foto actual',
                  gold: gold,
                  destructive: true,
                  onTap: () => _run(context, onRemove),
                ),
              ],
              const SizedBox(height: 18),
              _Option(
                icon: Icons.edit_outlined,
                label: 'Editar mis datos',
                gold: gold,
                muted: true,
                onTap: () => _run(context, onEditData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 0.6,
        margin: const EdgeInsets.only(left: 52),
        color: Colors.white.withValues(alpha: 0.06),
      );
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.name,
    required this.photoUrl,
    required this.gold,
  });

  final String name;
  final String photoUrl;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(2),
            child: AvatarPremium(
              displayName: name,
              photoUrl: photoUrl,
              size: 100,
              borderWidth: 1.6,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: gold,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0E0E0E), width: 2.5),
              ),
              child: Icon(Icons.photo_camera_rounded,
                  size: 14, color: premiumOnAccent(gold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.label,
    required this.gold,
    required this.onTap,
    this.destructive = false,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final Color gold;
  final VoidCallback onTap;
  final bool destructive;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF6B7A);
    final tint = destructive ? red : (muted ? Colors.white : gold);
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            SizedBox(width: 36, child: Icon(icon, size: 20, color: tint)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: destructive ? red : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: Colors.white.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }
}
