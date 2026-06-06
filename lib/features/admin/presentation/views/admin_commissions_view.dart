import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_reports.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: AdminPeriodChips(
                labels: const ['Hoy', 'Semana', 'Mes'],
                selected: _period.index,
                onSelected: _select,
              ),
            ),
            Expanded(
              child: FutureBuilder<AdminCommissionsReport>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CupertinoActivityIndicator(
                          color: context.primaryGold, radius: 14),
                    );
                  }
                  if (snap.hasError || !snap.hasData) {
                    return AdminErrorView(onRetry: () => setState(_load));
                  }
                  return _Body(data: snap.data!);
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatTile(
                label: 'Comisiones',
                value: adminMoney(data.commissionTotal),
                highlight: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatTile(
                label: 'Cortes',
                value: '${data.serviceCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminStatTile(
          label: 'Ingresos del periodo',
          value: adminMoney(data.revenueTotal),
        ),
        const SizedBox(height: 26),
        const PremiumSectionLabel('Por barbero'),
        const SizedBox(height: 12),
        if (data.byBarber.isEmpty)
          const AdminEmptyHint(text: 'Sin comisiones en este periodo')
        else
          for (final b in data.byBarber)
            AdminBreakdownRow(
              title: b.barberName,
              amount: adminMoney(b.commission),
              note:
                  '${b.serviceCount} ${b.serviceCount == 1 ? 'corte' : 'cortes'} · ${adminMoney(b.revenue)}',
            ),
        const SizedBox(height: 18),
        const PremiumSectionLabel('Por servicio'),
        const SizedBox(height: 12),
        if (data.byService.isEmpty)
          const AdminEmptyHint(text: 'Sin servicios en este periodo')
        else
          for (final s in data.byService)
            AdminBreakdownRow(
              title: s.serviceName,
              amount: adminMoney(s.commission),
              note: '${s.serviceCount} ${s.serviceCount == 1 ? 'corte' : 'cortes'}',
            ),
      ],
    );
  }
}
