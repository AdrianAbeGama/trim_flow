import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_event.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_state.dart';
import 'package:trim_flow/features/barber/agenda/presentation/views/walk_in_sheet.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/agenda_smart_calendar.dart';
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
          backgroundColor: context.backgroundBlack,
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
                child: _buildBody(state),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(AgendaUiState state) {
    if (state.status == AgendaStatusUi.loading && state.appointments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.calendarCheck, color: gold, size: 22),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'MODO BARBERO',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              _RealtimeDot(isLive: state.status == AgendaStatusUi.loaded),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'AGENDA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.history_rounded, color: Colors.white70, size: 20),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => HistorySheet(state: state),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              AgendaViewToggle(
                mode: state.viewMode,
                onChanged: (mode) => context
                    .read<AgendaBloc>()
                    .add(AgendaEvent.viewModeChanged(mode)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: state.isBusy ? null : onWalkIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.02),
                  disabledForegroundColor: Colors.white38,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  elevation: 0,
                ),
                icon: const FaIcon(FontAwesomeIcons.personWalkingArrowRight, size: 12, color: Colors.white70),
                label: const Text(
                  'WALK-IN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AgendaSmartCalendar(),
        ],
      ),
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
