import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

/// Header de la pantalla de configuración: back button + título.
class SettingsHeader extends StatefulWidget {
  const SettingsHeader({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onBack();
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedScale(
              scale: _pressed ? 0.88 : 1.0,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 40, height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Configuración',
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview chip premium con avatar + nombre + email.
class SettingsProfilePreview extends StatelessWidget {
  const SettingsProfilePreview({super.key, required this.user});
  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    final initials = fullName.isEmpty
        ? '?'
        : fullName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gold.withValues(alpha: 0.12),
              gold.withValues(alpha: 0.02),
              const Color(0xFF111111),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
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
                    ? _fallback(initials, gold)
                    : CachedNetworkImage(
                        imageUrl: user.photoUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _fallback(initials, gold),
                        placeholder: (_, _) => _fallback(initials, gold),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isEmpty ? 'Usuario' : fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(String initials, Color gold) {
    return Container(
      color: const Color(0xFF181818),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          color: gold,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
