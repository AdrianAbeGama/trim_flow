import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/presentation/permissions/permissions_store.dart';
import 'package:trim_flow/features/barber/staff/presentation/barber_staff_view.dart';

/// Seccion propia "Equipo" del perfil del barbero admin, aparte del panel de
/// Administracion. Oculta en modo "ver como" (un barbero no gestiona staff).
class BarberStaffSection extends StatelessWidget {
  const BarberStaffSection({super.key, required this.tenantId});

  final String tenantId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PreviewRole?>(
      valueListenable: PermissionsStore.instance.preview,
      builder: (context, preview, _) {
        if (preview != null) return const SizedBox.shrink();
        final gold = context.primaryGold;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 1.5, color: gold),
                  const SizedBox(width: 7),
                  Text(
                    'EQUIPO',
                    style: GoogleFonts.inter(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              PremiumPressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => BarberStaffView(tenantId: tenantId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.badge_outlined, color: gold, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Barberos',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Agrega y revisa tu equipo',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.25), size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
