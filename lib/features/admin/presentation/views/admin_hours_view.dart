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
import 'package:trim_flow/features/admin/presentation/widgets/admin_visuals.dart';

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

  ({bool open, String caption}) _liveStatus() {
    final hours = _hours;
    if (hours == null) return (open: false, caption: '');
    int toMin(String? s) {
      if (s == null || s.length < 5) return 0;
      return (int.tryParse(s.substring(0, 2)) ?? 0) * 60 +
          (int.tryParse(s.substring(3, 5)) ?? 0);
    }

    final now = DateTime.now();
    final idx = now.weekday - 1;
    final today = hours[idx];
    final hm = now.hour * 60 + now.minute;
    if (!today.isClosed) {
      final o = toMin(today.open ?? '09:00');
      final c = toMin(today.close ?? '18:00');
      if (hm >= o && hm < c) {
        return (open: true, caption: 'Abierto ahora · cierra ${today.close ?? '18:00'}');
      }
      if (hm < o) {
        return (open: false, caption: 'Hoy abre a las ${today.open ?? '09:00'}');
      }
    }
    for (var i = 1; i <= 7; i++) {
      final d = hours[(idx + i) % 7];
      if (!d.isClosed) {
        final label = i == 1 ? 'mañana' : _kDayNames[d.dayOfWeek].toLowerCase();
        return (open: false, caption: 'Cerrado · abre $label a las ${d.open ?? '09:00'}');
      }
    }
    return (open: false, caption: 'Cerrado');
  }

  Widget _statusHeader() {
    final gold = context.primaryGold;
    final status = _liveStatus();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
      child: Row(
        children: [
          AdminAnalogClock(size: 76, open: status.open),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: status.open
                            ? gold
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      status.open ? 'ABIERTO' : 'CERRADO',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: status.open
                            ? gold
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  status.caption,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        _statusHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            physics: const BouncingScrollPhysics(),
            itemCount: 7,
            itemBuilder: (_, i) => _dayCard(i),
          ),
        ),
        _saveBar(),
      ],
    );
  }

  double _frac(String? s) {
    if (s == null || s.length < 5) return 0;
    final m = (int.tryParse(s.substring(0, 2)) ?? 0) * 60 +
        (int.tryParse(s.substring(3, 5)) ?? 0);
    return m / 1440.0;
  }

  Widget _timePill(String label, String value, VoidCallback onTap) {
    final gold = context.primaryGold;
    return PremiumPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: gold.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label ',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: gold,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hoursRibbon(int i, BusinessHour h) {
    final gold = context.primaryGold;
    final startF = _frac(h.open ?? '09:00').clamp(0.0, 1.0);
    final endF = _frac(h.close ?? '18:00').clamp(0.0, 1.0);
    final now = DateTime.now();
    final isToday = i == now.weekday - 1;
    final nowF = ((now.hour * 60 + now.minute) / 1440.0).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _timePill('Apertura', h.open ?? '09:00',
                () => _pickTime(i, isOpen: true)),
            const SizedBox(width: 10),
            _timePill('Cierre', h.close ?? '18:00',
                () => _pickTime(i, isOpen: false)),
            const Spacer(),
            if (isToday)
              Text(
                'AHORA',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (_, c) {
            final w = c.maxWidth;
            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Align(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  for (final f in const [0.25, 0.5, 0.75])
                    Positioned(
                      left: f * w,
                      top: 0,
                      bottom: 0,
                      child: Container(
                          width: 1, color: Colors.white.withValues(alpha: 0.06)),
                    ),
                  Positioned(
                    left: startF * w,
                    top: 2,
                    width: ((endF - startF).clamp(0.0, 1.0)) * w,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                              color: gold.withValues(alpha: 0.35),
                              blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                  if (isToday)
                    Positioned(
                      left: (nowF * w).clamp(0.0, w - 1.5),
                      top: -2,
                      bottom: -2,
                      child: Container(
                          width: 1.5,
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final l in const ['12a', '6a', '12p', '6p', '12a'])
              Text(
                l,
                style: GoogleFonts.inter(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _dayCard(int i) {
    final gold = context.primaryGold;
    final h = _hours![i];
    final open = !h.isClosed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                    color: open ? Colors.white : Colors.white.withValues(alpha: 0.5),
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
            const SizedBox(height: 12),
            _hoursRibbon(i, h),
          ],
          const SizedBox(height: 12),
          const AdminHairline(),
        ],
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
