import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:core/core.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';

class HomeSmartNotification extends StatefulWidget {
  final bool isEditing;
  final VoidCallback? onNavigateToAppointments;

  const HomeSmartNotification({
    super.key,
    required this.isEditing,
    this.onNavigateToAppointments,
  });

  @override
  State<HomeSmartNotification> createState() => _HomeSmartNotificationState();
}

class _HomeSmartNotificationState extends State<HomeSmartNotification> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<AppModeBloc, AppModeState>(
        builder: (context, appModeState) {
          final isBarber = appModeState.mode == AppMode.barber;
          
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              final name = profileState.user?.firstName ?? 'Usuario';
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutQuart,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: context.primaryGold.withValues(alpha: 0.3), width: 1.5),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1E1E), Color(0xFF111111)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.primaryGold.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: context.primaryGold.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isBarber ? Icons.menu_book_rounded : Icons.event_note_rounded, 
                            color: context.primaryGold, 
                            size: 26
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBarber ? 'MODO BARBERO' : 'TU PRÓXIMA CITA',
                                style: TextStyle(color: context.primaryGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isBarber 
                                  ? '¡Hola $name! Revisa tu agenda.' 
                                  : 'Hola $name, tienes una reserva a las 15:30, no faltes.',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (isBarber) ...[
                      ElevatedButton(
                        onPressed: widget.onNavigateToAppointments ?? () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryGold,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 18),
                            SizedBox(width: 10),
                            Text(
                              'VER AGENDA COMPLETA',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => setState(() => _isExpanded = !_isExpanded),
                        icon: Icon(
                          _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: Colors.white54,
                          size: 18,
                        ),
                        label: Text(
                          _isExpanded ? 'Ocultar resumen del día' : 'Ver resumen del día',
                          style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 0.5),
                        ),
                      ),
                      if (_isExpanded) _buildBarberTimeline(context),
                    ] else
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryGold,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('LISTO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBarberTimeline(BuildContext context) {
    final appointments = [
      {'client': 'Carlos Ruiz', 'time': '09:00 AM', 'type': 'Corte Clásico'},
      {'client': 'Marcos Sosa', 'time': '10:30 AM', 'type': 'Barba + Fade'},
      {'client': 'Luis Mendez', 'time': '12:00 PM', 'type': 'Corte Moderno'},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: appointments.asMap().entries.map((entry) {
          final index = entry.key;
          final app = entry.value;
          return _buildTimelineItem(context, app, index == appointments.length - 1);
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, String> app, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: context.primaryGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: context.primaryGold.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          app['client']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        app['time']!,
                        style: TextStyle(color: context.primaryGold, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app['type']!,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
