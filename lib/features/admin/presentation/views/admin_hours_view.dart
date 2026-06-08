import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/premium/premium_time_picker.dart';
import 'package:trim_flow/features/admin/domain/models/business_hour.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';

const List<String> _kDayNames = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

class AdminHoursView extends StatefulWidget {
  const AdminHoursView({super.key, required this.tenantId});

  final String tenantId;

  @override
  State<AdminHoursView> createState() => _AdminHoursViewState();
}

class _AdminHoursViewState extends State<AdminHoursView> {
  List<BusinessHour>? _hours;
  bool _loading = true;
  bool _error = false;
  bool _saving = false;

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
      final fetched = await getIt<AdminRepository>()
          .fetchBusinessHours(tenantId: widget.tenantId);
      if (!mounted) return;
      setState(() {
        _hours = _normalize(fetched);
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

  List<BusinessHour> _normalize(List<BusinessHour> fetched) {
    final byDay = {for (final h in fetched) h.dayOfWeek: h};
    return List.generate(
      7,
      (i) =>
          byDay[i] ??
          BusinessHour(
            dayOfWeek: i,
            isClosed: i == 6,
            open: '09:00',
            close: '18:00',
          ),
    );
  }

  void _toggleDay(int i, bool open) {
    setState(() {
      final h = _hours![i];
      _hours![i] = h.copyWith(
        isClosed: !open,
        open: h.open ?? '09:00',
        close: h.close ?? '18:00',
      );
    });
  }

  Future<void> _pickTime(int i, {required bool isOpen}) async {
    HapticFeedback.lightImpact();
    final h = _hours![i];
    final initial = (isOpen ? h.open : h.close) ?? (isOpen ? '09:00' : '18:00');
    final picked = await showPremiumTimePicker(
      context,
      title: isOpen ? 'Hora de apertura' : 'Hora de cierre',
      initial: initial,
    );
    if (picked == null) return;
    setState(() {
      _hours![i] = isOpen ? h.copyWith(open: picked) : h.copyWith(close: picked);
    });
  }

  Future<void> _save() async {
    final hours = _hours;
    if (hours == null) return;
    for (final h in hours) {
      if (!h.isClosed && (h.open ?? '').compareTo(h.close ?? '') >= 0) {
        adminSnack(context,
            'En ${_kDayNames[h.dayOfWeek]} la hora de cierre debe ser mayor a la de apertura');
        return;
      }
    }
    final actorId = Supabase.instance.client.auth.currentUser?.id;
    if (actorId == null) {
      adminSnack(context, 'Tu sesión expiró, vuelve a entrar');
      return;
    }
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      await getIt<AdminRepository>().saveBusinessHours(
        tenantId: widget.tenantId,
        actorId: actorId,
        hours: hours,
      );
      if (!mounted) return;
      adminSnack(context, 'Horarios guardados');
    } catch (_) {
      if (!mounted) return;
      adminSnack(context, 'No se pudo guardar. Revisa tu conexión o permisos.');
    } finally {
      if (mounted) setState(() => _saving = false);
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
              title: 'Horarios',
              subtitle: 'Horario de atención',
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const AdminLoader();
    if (_error || _hours == null) {
      return AdminErrorView(onRetry: _load);
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            physics: const BouncingScrollPhysics(),
            itemCount: 7,
            itemBuilder: (_, i) => _dayCard(i),
          ),
        ),
        _saveBar(),
      ],
    );
  }

  Widget _dayCard(int i) {
    final gold = context.primaryGold;
    final h = _hours![i];
    final open = !h.isClosed;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _kDayNames[i],
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Text(
                open ? 'Abierto' : 'Cerrado',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: open ? gold : Colors.white.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: open,
                activeTrackColor: gold,
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  _toggleDay(i, v);
                },
              ),
            ],
          ),
          if (open) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _timeChip('Abre', h.open ?? '09:00', () => _pickTime(i, isOpen: true))),
                const SizedBox(width: 10),
                Expanded(child: _timeChip('Cierra', h.close ?? '18:00', () => _pickTime(i, isOpen: false))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeChip(String label, String value, VoidCallback onTap) {
    return PremiumPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
      child: AdminPrimaryButton(
        label: 'Guardar horarios',
        loading: _saving,
        onTap: _save,
      ),
    );
  }
}
