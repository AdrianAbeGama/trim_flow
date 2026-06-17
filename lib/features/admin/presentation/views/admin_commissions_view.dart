import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_reports.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/views/admin_commission_config_view.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_visuals.dart';

enum _Period { today, week, month }

(DateTime, DateTime) _rangeFor(_Period p) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (p) {
    case _Period.today:
      return (today, today.add(const Duration(days: 1)));
    case _Period.week:
      return (today.subtract(const Duration(days: 6)),
          today.add(const Duration(days: 1)));
    case _Period.month:
      return (DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1));
  }
}

class AdminCommissionsView extends StatefulWidget {
  const AdminCommissionsView({super.key, required this.tenantId});

  final String tenantId;

  @override
  State<AdminCommissionsView> createState() => _AdminCommissionsViewState();
}

class _AdminCommissionsViewState extends State<AdminCommissionsView> {
  _Period _period = _Period.month;
  late Future<AdminCommissionsReport> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final (start, end) = _rangeFor(_period);
    _future = getIt<AdminRepository>().fetchCommissions(
      tenantId: widget.tenantId,
      start: start,
      end: end,
    );
  }

  void _select(int i) => setState(() {
        _period = _Period.values[i];
        _load();
      });

  void _openConfig() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AdminCommissionConfigView(tenantId: widget.tenantId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminScreenHeader(
              title: 'Comisiones',
              subtitle: 'Cuánto gana cada barbero',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: AdminPeriodChips(
                labels: const ['Hoy', 'Semana', 'Mes'],
                selected: _period.index,
                onSelected: _select,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                children: [
                  const AdminHairline(),
                  PremiumPressable(
                    onTap: _openConfig,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded,
                              color: context.primaryGold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Configurar pago por barbero',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: context.primaryGold, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<AdminCommissionsReport>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const AdminLoader();
                  }
                  if (snap.hasError || !snap.hasData) {
                    return AdminErrorView(onRetry: () => setState(_load));
                  }
                  return RefreshIndicator(
                    color: context.primaryGold,
                    backgroundColor: const Color(0xFF0E0E0E),
                    onRefresh: () async {
                      setState(_load);
                      await _future;
                    },
                    child: _Body(data: snap.data!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});

  final AdminCommissionsReport data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        AdminHeroMetric(
          label: 'Comisiones del periodo',
          value: adminMoney(data.commissionTotal),
          caption:
              '${data.serviceCount} ${data.serviceCount == 1 ? 'corte' : 'cortes'} · ${adminMoney(data.revenueTotal)} en ventas',
        ),
        const SizedBox(height: 22),
        const AdminHairline(),
        const SizedBox(height: 20),
        const PremiumSectionLabel('Por barbero'),
        const SizedBox(height: 14),
        AdminSeriesChart(
          segments: [
            for (var i = 0; i < data.byBarber.length; i++)
              ChartSeg(
                label: data.byBarber[i].barberName,
                value: data.byBarber[i].commission,
                color: adminPalette[i % adminPalette.length],
                note:
                    '${data.byBarber[i].serviceCount} ${data.byBarber[i].serviceCount == 1 ? 'corte' : 'cortes'}',
              ),
          ],
          formatValue: adminMoney,
          centerTop: 'COMISIÓN',
        ),
        const SizedBox(height: 20),
        const AdminHairline(),
        const SizedBox(height: 20),
        const PremiumSectionLabel('Por servicio'),
        const SizedBox(height: 14),
        AdminSeriesChart(
          segments: [
            for (var i = 0; i < data.byService.length; i++)
              ChartSeg(
                label: data.byService[i].serviceName,
                value: data.byService[i].commission,
                color: adminPalette[(i + 3) % adminPalette.length],
                note:
                    '${data.byService[i].serviceCount} ${data.byService[i].serviceCount == 1 ? 'corte' : 'cortes'}',
              ),
          ],
          formatValue: adminMoney,
          centerTop: 'COMISIÓN',
        ),
      ],
    );
  }
}
