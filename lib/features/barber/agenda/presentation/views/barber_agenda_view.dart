import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:trim_flow/core/widgets/premium/smart_calendar.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_event.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_state.dart';
import 'package:trim_flow/features/barber/agenda/presentation/views/walk_in_sheet.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/agenda_list_panel.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/agenda_matrix_panel.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/history_sheet.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/view_toggle.dart';

class BarberAgendaView extends StatelessWidget {
  const BarberAgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const _UnauthenticatedView();

    return BlocProvider(
      create: (ctx) {
        final themeTenant = ctx.read<TenantThemeBloc>().state.tenantId;
        final tenantId = themeTenant == kDefaultTenantId ? '' : themeTenant;
        return AgendaBloc(
          barberId: user.id,
          tenantId: tenantId,
          repository: getIt<AgendaRepository>(),
        )..add(const AgendaEvent.started());
      },
      child: const _AgendaScaffold(),
    );
  }
}

class _AgendaScaffold extends StatelessWidget {
  const _AgendaScaffold();

  Future<void> _openWalkIn(BuildContext context) async {
    final bloc = context.read<AgendaBloc>();
    final profileBloc = context.read<ProfileBloc>();
    final baseRefs = bloc.state.lookupRefs;

    if (baseRefs == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Resolviendo configuracion del barbero, intenta de nuevo en un instante.'),
      ));
      bloc.add(const AgendaEvent.resolveRefsRequested());
      return;
    }

    // Usar el branchId en memoria modificado desde el perfil si existe
    final memoryBranchId = profileBloc.state.user?.branchId;
    final refs = baseRefs.copyWith(
      defaultBranchId: memoryBranchId ?? baseRefs.defaultBranchId,
    );

    if (refs.defaultBranchId == null || refs.defaultServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Falta asignar sucursal o servicio activo en tu perfil.'),
      ));
      return;
    }

    final result = await showModalBottomSheet<WalkInResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WalkInSheet(refs: refs, now: DateTime.now()),
    );
    if (result == null || !context.mounted) return;

    bloc.add(AgendaEvent.walkInRequested(WalkInRequest(
      tenantId: bloc.tenantId,
      branchId: refs.defaultBranchId!,
      barberId: bloc.barberId,
      serviceId: refs.defaultServiceId!,
      startTime: result.startTime,
      customerName: result.customerName,
      customerPhone: result.customerPhone,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AgendaBloc, AgendaUiState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? '')),
        );
      },
      builder: (context, state) {
        final gold = context.primaryGold;
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _Header(state: state, onWalkIn: () => _openWalkIn(context)),
                  ),
                ];
              },
              body: RefreshIndicator(
                color: gold,
                backgroundColor: const Color(0xFF111111),
                onRefresh: () async {
                  context.read<AgendaBloc>().add(const AgendaEvent.refreshRequested());
                },
                child: _buildBody(context, state),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AgendaUiState state) {
    if (state.status == AgendaStatusUi.loading && state.appointments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: CircularProgressIndicator(
              color: context.primaryGold,
              strokeWidth: 2,
            ),
          ),
        ],
      );
    }

    switch (state.viewMode) {
      case AgendaViewMode.list:
        return AgendaListPanel(appointments: state.appointments);
      case AgendaViewMode.matrix:
        return AgendaMatrixPanel(
          appointments: state.appointments,
          day: state.selectedDay,
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onWalkIn});

  final AgendaUiState state;
  final VoidCallback onWalkIn;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 19
            ? 'Buenas tardes'
            : 'Buenas noches';
    final dateLong = DateFormat("EEEE d 'de' MMMM", 'es').format(DateTime.now());

    final profile = context.watch<ProfileBloc>().state.user;
    final barberName = profile != null ? '${profile.firstName} ${profile.lastName}'.trim() : '';
    final displayName = barberName.isEmpty ? 'Barbero' : barberName;

    final now = DateTime.now();
    bool isToday(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;
    final completedToday = state.appointments
        .where((a) => a.status == AgendaStatus.completed && isToday(a.startTime));
    final cutsToday = completedToday.length;
    final revenueToday = completedToday.fold<double>(0, (s, a) => s + (a.priceAtBooking ?? 0));
    final upcoming = state.appointments
        .where((a) =>
            a.startTime.isAfter(now) &&
            (a.status == AgendaStatus.confirmed || a.status == AgendaStatus.pending))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final nextStr = upcoming.isNotEmpty
        ? '${upcoming.first.startTime.hour.toString().padLeft(2, '0')}:${upcoming.first.startTime.minute.toString().padLeft(2, '0')}'
        : '—';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === TOP BAR — modo + realtime + historial ===
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: gold.withValues(alpha: 0.25)),
                ),
                child: Text(
                  'MODO BARBERO',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: gold,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RealtimeDot(isLive: state.status == AgendaStatusUi.loaded),
              const Spacer(),
              _HeaderIconButton(
                icon: Icons.info_outline_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => const _StatesLegendSheet(),
                  );
                },
              ),
              const SizedBox(width: 10),
              _HeaderIconButton(
                icon: Icons.history_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => HistorySheet(state: state),
                  );
                },
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms),
          const SizedBox(height: 18),

          // === SALUDO + NOMBRE (suelto, sin caja) ===
          Row(
            children: [
              AvatarPremium(displayName: displayName, photoUrl: profile?.photoUrl, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$greeting,',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.45),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.6,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 80.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0, delay: 80.ms, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 20),

          // === TÍTULO + FECHA ===
          Text(
            'Tu agenda de hoy',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.8,
              height: 1.05,
            ),
          )
              .animate()
              .fadeIn(delay: 140.ms, duration: 500.ms)
              .slideY(begin: 0.12, end: 0, delay: 140.ms, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 4),
          Text(
            _capitalize(dateLong),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.42),
              letterSpacing: -0.1,
            ),
          )
              .animate()
              .fadeIn(delay: 180.ms, duration: 500.ms),
          const SizedBox(height: 22),

          // === MÉTRICAS DEL DÍA (tarjeta unificada premium) ===
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Expanded(child: _HeroMetric(icon: Icons.content_cut_rounded, label: 'Cortes hoy', value: '$cutsToday', accent: gold)),
                _HeroDivider(),
                Expanded(child: _HeroMetric(icon: Icons.payments_rounded, label: 'Ingresos', value: 'S/${revenueToday.toStringAsFixed(0)}', accent: gold)),
                _HeroDivider(),
                Expanded(child: _HeroMetric(icon: Icons.schedule_rounded, label: 'Próxima', value: nextStr, accent: gold)),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 220.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0, delay: 220.ms, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 22),

          // === ACCIONES ROW — toggle + walk-in ===
          Row(
            children: [
              AgendaViewToggle(
                mode: state.viewMode,
                onChanged: (mode) {
                  HapticFeedback.selectionClick();
                  context
                      .read<AgendaBloc>()
                      .add(AgendaEvent.viewModeChanged(mode));
                },
              ),
              const Spacer(),
              _WalkInPill(enabled: !state.isBusy, onTap: onWalkIn),
            ],
          )
              .animate()
              .fadeIn(delay: 240.ms, duration: 500.ms),
          const SizedBox(height: 18),

          SmartCalendar(
            selectedDate: state.selectedDay,
            markedDates: context.read<AgendaBloc>().demoDays,
            collapseOnSelect: true,
            onDaySelected: (date) => context.read<AgendaBloc>().add(AgendaEvent.daySelected(date)),
          )
              .animate()
              .fadeIn(delay: 320.ms, duration: 600.ms)
              .slideY(begin: 0.04, end: 0, delay: 320.ms, duration: 600.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.icon, required this.label, required this.value, required this.accent});

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accent, size: 17),
        const SizedBox(height: 9),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.7, height: 1),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.2),
        ),
      ],
    );
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

class _RealtimeDot extends StatefulWidget {
  const _RealtimeDot({required this.isLive});
  final bool isLive;

  @override
  State<_RealtimeDot> createState() => _RealtimeDotState();
}

class _RealtimeDotState extends State<_RealtimeDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.isLive ? Colors.redAccent.shade400 : Colors.white24;
    final textColor = widget.isLive ? Colors.white : Colors.white24;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _ctrl,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: widget.isLive
                    ? [BoxShadow(color: dotColor.withValues(alpha: 0.5), blurRadius: 4)]
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.isLive ? 'EN VIVO' : 'NO CONECTADO',
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundBlack,
      body: Center(
        child: Text(
          'Inicia sesion para ver tu agenda.',
          style: TextStyle(color: context.primaryGold),
        ),
      ),
    );
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// Leyenda que explica los estados de una cita y cómo funcionan.
class _StatesLegendSheet extends StatelessWidget {
  const _StatesLegendSheet();

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final items = <(Color, String, String)>[
      (gold, 'Pendiente', 'El cliente reservó pero la cita aún no se confirma.'),
      (Colors.white, 'Confirmada', 'La cita está en pie y lista para atender — todavía no se hace el corte.'),
      (const Color(0xFF6E6E6E), 'Completada', 'El corte ya se realizó. Suma a tus ingresos del día.'),
      (const Color(0xFFCF6679), 'Cancelada', 'La cita se canceló (por ti o por el cliente, con motivo).'),
      (const Color(0xFFCF6679), 'No asistió', 'El cliente no llegó a su cita.'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: gold, size: 18),
                const SizedBox(width: 10),
                Text('Estados de una cita', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Una cita avanza así: Pendiente → Confirmada → Completada.',
              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 12.5, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),
            ...items.map((it) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(color: it.$1, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it.$2, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                            const SizedBox(height: 2),
                            Text(it.$3, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Icon(widget.icon, size: 17, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

class _WalkInPill extends StatefulWidget {
  const _WalkInPill({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_WalkInPill> createState() => _WalkInPillState();
}

class _WalkInPillState extends State<_WalkInPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final fg = widget.enabled ? gold : Colors.white.withValues(alpha: 0.3);
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.enabled
          ? () {
              HapticFeedback.mediumImpact();
              widget.onTap();
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: widget.enabled
                ? gold.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.enabled
                  ? gold.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.personWalkingArrowRight,
                size: 11,
                color: fg,
              ),
              const SizedBox(width: 6),
              Text(
                'WALK-IN',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: fg,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
