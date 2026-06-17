import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/presentation/permissions/permissions_store.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_cash_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_business_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_commissions_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_customers_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_dashboard_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_hours_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_promotions_view.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_visuals.dart';

/// Bloque "Administracion" del perfil del barbero. Visible solo si es admin.
/// Respeta los permisos en modo "ver como" (demo): muestra solo las tarjetas
/// permitidas. La entrada "Roles y permisos" solo aparece para el admin real.
class BarberAdminSection extends StatelessWidget {
  const BarberAdminSection({super.key, required this.tenantId});

  final String tenantId;

  void _open(BuildContext context, Widget view) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => view));
  }

  @override
  Widget build(BuildContext context) {
    final store = PermissionsStore.instance;
    return ValueListenableBuilder<PreviewRole?>(
      valueListenable: store.preview,
      builder: (context, preview, _) {
        final gold = context.primaryGold;
        final previewing = preview != null;
        final all =
            <({IconData icon, String title, String subtitle, String cap, Widget view})>[
          (
            icon: Icons.show_chart_rounded,
            title: 'Resumen',
            subtitle: 'Ingresos, cortes y comisiones',
            cap: 'admin_summary',
            view: AdminDashboardView(tenantId: tenantId),
          ),
          (
            icon: Icons.point_of_sale_rounded,
            title: 'Caja',
            subtitle: 'Cierre del día por método',
            cap: 'admin_cash',
            view: AdminCashView(tenantId: tenantId),
          ),
          (
            icon: Icons.schedule_rounded,
            title: 'Horarios',
            subtitle: 'Tu horario de atención',
            cap: 'admin_hours',
            view: AdminHoursView(tenantId: tenantId),
          ),
          (
            icon: Icons.local_offer_rounded,
            title: 'Promociones',
            subtitle: 'Ofertas y cupones',
            cap: 'admin_promos',
            view: AdminPromotionsView(tenantId: tenantId),
          ),
          (
            icon: Icons.percent_rounded,
            title: 'Comisiones',
            subtitle: 'Pago por barbero',
            cap: 'admin_commissions',
            view: AdminCommissionsView(tenantId: tenantId),
          ),
          (
            icon: Icons.groups_rounded,
            title: 'Clientes',
            subtitle: 'Cupones, puntos y VIP',
            cap: 'admin_customers',
            view: AdminCustomersView(tenantId: tenantId),
          ),
          (
            icon: Icons.storefront_rounded,
            title: 'Mi barbería',
            subtitle: 'Datos y recordatorios',
            cap: 'admin_business',
            view: AdminBusinessView(tenantId: tenantId),
          ),
        ];
        final items = all.where((it) => store.can(it.cap)).toList();
        if (previewing && items.isEmpty) return const SizedBox.shrink();

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
                    'ADMINISTRACIÓN',
                    style: GoogleFonts.inter(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const Spacer(),
                  if (!previewing)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: gold.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        'ADMIN',
                        style: GoogleFonts.inter(
                          color: gold,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const AdminHairline(),
                _AdminRow(
                  icon: items[i].icon,
                  title: items[i].title,
                  subtitle: items[i].subtitle,
                  onTap: () => _open(context, items[i].view),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AdminRow extends StatelessWidget {
  const _AdminRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      onTap: onTap,
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
              child: Icon(icon, color: gold, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.25),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
