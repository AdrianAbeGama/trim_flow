import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_reports.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_cash_adjust_sheet.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_visuals.dart';

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

  Future<void> _openAdjust() async {
    final ok = await showCashAdjust(
      context,
      onSubmit: (amount, reasonCode, reasonText, idempotencyKey) =>
          getIt<AdminRepository>().registerCashAdjustment(
        tenantId: widget.tenantId,
        amount: amount,
        reasonCode: reasonCode,
        reasonText: reasonText,
        idempotencyKey: idempotencyKey,
      ),
    );
    if (ok == true && mounted) {
      adminSnack(context, 'Ajuste registrado');
      setState(_load);
    }
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
              title: 'Caja',
              subtitle: 'Cierre del día',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: AdminPeriodChips(
                labels: const ['Hoy', 'Ayer', 'Semana'],
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
                    onTap: _openAdjust,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        children: [
                          Icon(Icons.add_rounded,
                              color: context.primaryGold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Registrar ajuste de caja',
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
              child: FutureBuilder<AdminCashReport>(
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
                    child: _CashBody(data: snap.data!),
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

class _CashBody extends StatelessWidget {
  const _CashBody({required this.data});

  final AdminCashReport data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        AdminHeroMetric(
          label: 'Total cobrado',
          value: adminMoney(data.revenueTotal),
          caption:
              '${data.serviceCount} ${data.serviceCount == 1 ? 'servicio cobrado' : 'servicios cobrados'}',
        ),
        const SizedBox(height: 22),
        AdminStatStrip(
          stats: [
            AdminStat(
                label: 'Descuentos', value: adminMoney(data.discountTotal)),
            AdminStat(
                label: 'Balance neto', value: adminMoney(data.netBalance)),
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
      ],
    );
  }
}
