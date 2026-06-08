import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_commission_config.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';

class AdminCommissionConfigView extends StatefulWidget {
  const AdminCommissionConfigView({super.key, required this.tenantId});

  final String tenantId;

  @override
  State<AdminCommissionConfigView> createState() =>
      _AdminCommissionConfigViewState();
}

class _AdminCommissionConfigViewState extends State<AdminCommissionConfigView> {
  List<AdminBarberRef>? _barbers;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final b = await getIt<AdminRepository>()
          .fetchBarbers(tenantId: widget.tenantId);
      if (!mounted) return;
      setState(() {
        _barbers = b;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void _openBarber(AdminBarberRef b) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            _BarberCommissionsView(tenantId: widget.tenantId, barber: b),
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
              title: 'Configurar comisiones',
              subtitle: 'Elige un barbero',
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const AdminLoader();
    if (_error) return AdminErrorView(onRetry: _load);
    final barbers = _barbers ?? const [];
    if (barbers.isEmpty) {
      return const Center(child: AdminEmptyHint(text: 'No hay barberos'));
    }
    return RefreshIndicator(
      color: context.primaryGold,
      backgroundColor: const Color(0xFF0E0E0E),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        physics: const BouncingScrollPhysics(),
        itemCount: barbers.length,
        itemBuilder: (_, i) => _barberCard(barbers[i]),
      ),
    );
  }

  Widget _barberCard(AdminBarberRef b) {
    final gold = context.primaryGold;
    final initials = b.name.trim().isEmpty
        ? '?'
        : b.name.trim().split(RegExp(r'\s+')).take(2).map((p) => p[0]).join();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumPressable(
        onTap: () => _openBarber(b),
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
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initials.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: gold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  b.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
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

class _BarberCommissionsView extends StatefulWidget {
  const _BarberCommissionsView({required this.tenantId, required this.barber});

  final String tenantId;
  final AdminBarberRef barber;

  @override
  State<_BarberCommissionsView> createState() => _BarberCommissionsViewState();
}

class _BarberCommissionsViewState extends State<_BarberCommissionsView> {
  List<CommissionLine>? _lines;
  bool _loading = true;
  bool _error = false;

  AdminRepository get _repo => getIt<AdminRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final lines = await _repo.fetchCommissionLines(
        tenantId: widget.tenantId,
        barberId: widget.barber.id,
      );
      if (!mounted) return;
      setState(() {
        _lines = lines;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _edit(CommissionLine line) async {
    final ok = await _showCommissionEditor(
      context,
      line,
      onSave: (type, value) => _repo.saveCommissionOverride(
        tenantId: widget.tenantId,
        barberId: widget.barber.id,
        serviceId: line.serviceId,
        type: type,
        value: value,
      ),
      onDelete: () => _repo.deleteCommissionOverride(
        tenantId: widget.tenantId,
        barberId: widget.barber.id,
        serviceId: line.serviceId,
      ),
    );
    if (ok == true && mounted) {
      adminSnack(context, 'Comisión actualizada');
      _load();
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
            AdminScreenHeader(
              title: widget.barber.name,
              subtitle: 'Comisión por servicio',
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const AdminLoader();
    if (_error) return AdminErrorView(onRetry: _load);
    final lines = _lines ?? const [];
    if (lines.isEmpty) {
      return const Center(child: AdminEmptyHint(text: 'No hay servicios'));
    }
    return RefreshIndicator(
      color: context.primaryGold,
      backgroundColor: const Color(0xFF0E0E0E),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        physics: const BouncingScrollPhysics(),
        itemCount: lines.length,
        itemBuilder: (_, i) => _lineCard(lines[i]),
      ),
    );
  }

  Widget _lineCard(CommissionLine line) {
    final gold = context.primaryGold;
    final onAccent = premiumOnAccent(gold);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumPressable(
        onTap: () => _edit(line),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Precio ${adminMoney(line.price)}  ·  ${line.isOverride ? 'Personalizado' : 'Por defecto'}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: line.isOverride
                            ? gold
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      line.valueLabel,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: onAccent,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gana ${adminMoney(line.earns)}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> _showCommissionEditor(
  BuildContext context,
  CommissionLine line, {
  required Future<void> Function(String type, double value) onSave,
  required Future<void> Function() onDelete,
}) {
  return showAdminSheet<bool>(
    context,
    _CommissionEditor(line: line, onSave: onSave, onDelete: onDelete),
  );
}

class _CommissionEditor extends StatefulWidget {
  const _CommissionEditor({
    required this.line,
    required this.onSave,
    required this.onDelete,
  });

  final CommissionLine line;
  final Future<void> Function(String type, double value) onSave;
  final Future<void> Function() onDelete;

  @override
  State<_CommissionEditor> createState() => _CommissionEditorState();
}

class _CommissionEditorState extends State<_CommissionEditor> {
  late bool _percentage = widget.line.isPercentage;
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.line.value == widget.line.value.roundToDouble()
        ? widget.line.value.toStringAsFixed(0)
        : widget.line.value.toString(),
  );
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_ctrl.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0) return adminSnack(context, 'Pon un valor válido');
    if (_percentage && value > 100) {
      return adminSnack(context, 'El porcentaje no puede ser mayor a 100');
    }
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      await widget.onSave(_percentage ? 'percentage' : 'fixed', value);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      adminSnack(context, 'No se pudo guardar');
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await PremiumConfirmDelete.show(
      context,
      title: 'Quitar comisión personalizada',
      message: 'Volverá a la comisión por defecto del servicio.',
    );
    if (!ok) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      await widget.onDelete();
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      adminSnack(context, 'No se pudo quitar');
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminSheetScaffold(
      title: widget.line.serviceName,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Precio ${adminMoney(widget.line.price)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              AdminChoiceChip(
                label: 'Porcentaje %',
                selected: _percentage,
                onTap: () => setState(() => _percentage = true),
              ),
              const SizedBox(width: 8),
              AdminChoiceChip(
                label: 'Monto S/',
                selected: !_percentage,
                onTap: () => setState(() => _percentage = false),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AdminTextField(
            controller: _ctrl,
            autofocus: true,
            number: true,
            hint: _percentage ? 'Ej. 50' : 'Ej. 15',
          ),
          const SizedBox(height: 20),
          AdminPrimaryButton(
            label: 'Guardar comisión',
            loading: _saving,
            onTap: _save,
          ),
          if (widget.line.isOverride) ...[
            const SizedBox(height: 10),
            Center(
              child: PremiumPressable(
                onTap: _saving ? null : _delete,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Volver a la comisión por defecto',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
