import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_reports.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';

enum _CashPeriod { today, yesterday, week }

(DateTime, DateTime) _rangeFor(_CashPeriod p) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (p) {
    case _CashPeriod.today:
      return (today, today.add(const Duration(days: 1)));
    case _CashPeriod.yesterday:
      return (today.subtract(const Duration(days: 1)), today);
    case _CashPeriod.week:
      return (today.subtract(const Duration(days: 6)),
          today.add(const Duration(days: 1)));
  }
}

class AdminCashView extends StatefulWidget {
  const AdminCashView({super.key, required this.tenantId});

  final String tenantId;

  @override
  State<AdminCashView> createState() => _AdminCashViewState();
}

class _AdminCashViewState extends State<AdminCashView> {
  _CashPeriod _period = _CashPeriod.today;
  late Future<AdminCashReport> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final (start, end) = _rangeFor(_period);
    _future = getIt<AdminRepository>().fetchCashReport(
      tenantId: widget.tenantId,
      start: start,
      end: end,
    );
  }

  void _select(int i) => setState(() {
        _period = _CashPeriod.values[i];
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
              title: 'Caja',
              subtitle: 'Cierre del día',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: AdminPeriodChips(
                labels: const ['Hoy', 'Ayer', 'Semana'],
                selected: _period.index,
                onSelected: _select,
              ),
            ),
            Expanded(
              child: FutureBuilder<AdminCashReport>(
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
                  return _CashBody(data: snap.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashBody extends StatelessWidget {
  const _CashBody({required this.data});

  final AdminCashReport data;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL COBRADO',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                adminMoney(data.revenueTotal),
                style: GoogleFonts.inter(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: gold,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${data.serviceCount} ${data.serviceCount == 1 ? 'servicio cobrado' : 'servicios cobrados'}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AdminStatTile(
                label: 'Descuentos',
                value: adminMoney(data.discountTotal),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatTile(
                label: 'Balance neto',
                value: adminMoney(data.netBalance),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const PremiumSectionLabel('Por método de pago'),
        const SizedBox(height: 12),
        if (data.byPayment.isEmpty)
          const AdminEmptyHint(text: 'Sin cobros en este periodo')
        else
          for (final m in data.byPayment)
            AdminBreakdownRow(
              title: m.label,
              amount: adminMoney(m.total),
              note: '${m.count} ${m.count == 1 ? 'cobro' : 'cobros'}',
            ),
      ],
    );
  }
}
