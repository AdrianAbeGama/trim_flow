import 'package:flutter/material.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_reports.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_visuals.dart';

enum _DashPeriod { today, week, month }

(DateTime, DateTime) _rangeFor(_DashPeriod p) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (p) {
    case _DashPeriod.today:
      return (today, today.add(const Duration(days: 1)));
    case _DashPeriod.week:
      return (today.subtract(const Duration(days: 6)),
          today.add(const Duration(days: 1)));
    case _DashPeriod.month:
      return (DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1));
  }
}

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key, required this.tenantId});

  final String tenantId;

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  _DashPeriod _period = _DashPeriod.month;
  late Future<AdminDashboard> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final (start, end) = _rangeFor(_period);
    _future = getIt<AdminRepository>().fetchDashboard(
      tenantId: widget.tenantId,
      start: start,
      end: end,
    );
  }

  void _select(int i) => setState(() {
        _period = _DashPeriod.values[i];
        _load();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminScreenHeader(
              title: 'Resumen',
              subtitle: 'Tu negocio en números',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: AdminPeriodChips(
                labels: const ['Hoy', 'Semana', 'Mes'],
                selected: _period.index,
                onSelected: _select,
              ),
            ),
            Expanded(
              child: FutureBuilder<AdminDashboard>(
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
                    child: _DashboardBody(data: snap.data!),
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

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final AdminDashboard data;

  @override
  Widget build(BuildContext context) {
    final maxComm = data.byBarber
        .fold<double>(0, (m, b) => b.commission > m ? b.commission : m);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        AdminHeroMetric(
          label: 'Ingresos',
          value: adminMoney(data.revenueTotal),
          caption:
              '${data.serviceCount} ${data.serviceCount == 1 ? 'corte' : 'cortes'} en el periodo',
        ),
        const SizedBox(height: 22),
        AdminStatStrip(
          stats: [
            AdminStat(
                label: 'Comisiones', value: adminMoney(data.commissionTotal)),
            AdminStat(
                label: 'Descuentos', value: adminMoney(data.discountTotal)),
            AdminStat(label: 'Cortes', value: '${data.serviceCount}'),
          ],
        ),
        const SizedBox(height: 22),
        const AdminHairline(),
        const SizedBox(height: 20),
        const PremiumSectionLabel('Por método de pago'),
        const SizedBox(height: 16),
        AdminSeriesChart(
          segments: [
            for (final m in data.byPayment)
              ChartSeg(
                label: m.label,
                value: m.total,
                color: adminPaymentColor(m.method),
                note: '${m.count}',
              ),
          ],
          formatValue: adminMoney,
          centerTop: 'COBROS',
        ),
        const SizedBox(height: 20),
        const AdminHairline(),
        const SizedBox(height: 20),
        const PremiumSectionLabel('Por barbero'),
        const SizedBox(height: 8),
        if (data.byBarber.isEmpty)
          const AdminEmptyHint(text: 'Sin cortes en este periodo')
        else
          for (final b in data.byBarber)
            AdminBarRow(
              leading: AdminInitialAvatar(name: b.barberName),
              title: b.barberName,
              amount: adminMoney(b.commission),
              fraction: maxComm <= 0 ? 0 : b.commission / maxComm,
              note:
                  '${b.serviceCount} ${b.serviceCount == 1 ? 'corte' : 'cortes'}',
            ),
      ],
    );
  }
}
