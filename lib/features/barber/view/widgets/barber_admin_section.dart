import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_cash_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_business_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_commissions_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_customers_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_dashboard_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_hours_view.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_promotions_view.dart';

/// Bloque "Administracion" del perfil del barbero. Se muestra SOLO si el barbero
/// es admin (tenant_admin/super_admin). Reune los accesos a las herramientas de
/// gestion. Las pantallas con RPC listo abren; las pendientes muestran "Pronto".
class BarberAdminSection extends StatelessWidget {
  const BarberAdminSection({super.key, required this.tenantId});

  final String tenantId;

  void _open(BuildContext context, Widget view) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => view));
  }

  @override
  Widget build(BuildContext context) {
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
                'ADMINISTRACIÓN',
                style: GoogleFonts.inter(
                  color: gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          const SizedBox(height: 14),
          _AdminCard(
            icon: Icons.insights_rounded,
            title: 'Resumen',
            subtitle: 'Ingresos, cortes y comisiones',
            onTap: () => _open(context, AdminDashboardView(tenantId: tenantId)),
          ),
          _AdminCard(
            icon: Icons.point_of_sale_rounded,
            title: 'Caja',
            subtitle: 'Cierre del día por método',
            onTap: () => _open(context, AdminCashView(tenantId: tenantId)),
          ),
          _AdminCard(
            icon: Icons.schedule_rounded,
            title: 'Horarios',
            subtitle: 'Horario de atención',
            onTap: () => _open(context, AdminHoursView(tenantId: tenantId)),
          ),
          _AdminCard(
            icon: Icons.local_offer_rounded,
            title: 'Promociones',
            subtitle: 'Ofertas y cupones',
            onTap: () =>
                _open(context, AdminPromotionsView(tenantId: tenantId)),
          ),
          _AdminCard(
            icon: Icons.percent_rounded,
            title: 'Comisiones',
            subtitle: 'Pago por barbero',
            onTap: () =>
                _open(context, AdminCommissionsView(tenantId: tenantId)),
          ),
          _AdminCard(
            icon: Icons.people_alt_rounded,
            title: 'Clientes',
            subtitle: 'Dar cupones y puntos',
            onTap: () => _open(context, AdminCustomersView(tenantId: tenantId)),
          ),
          _AdminCard(
            icon: Icons.storefront_rounded,
            title: 'Mi barbería',
            subtitle: 'Datos y recordatorios',
            onTap: () => _open(context, AdminBusinessView(tenantId: tenantId)),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: gold, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: gold, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
