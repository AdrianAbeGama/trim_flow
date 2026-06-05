import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/appointment_action_sheet.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/status_badge.dart';

const int _kStartHour = 8;
const int _kEndHour = 22;
const double _kHourHeight = 90;
const double _kHourLabelWidth = 56;

class AgendaMatrixPanel extends StatelessWidget {
  const AgendaMatrixPanel({super.key, required this.appointments, required this.day});

  final List<AgendaAppointment> appointments;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final totalHeight = (_kEndHour - _kStartHour) * _kHourHeight;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: SizedBox(
        height: totalHeight + 12,
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _HourLinesPainter(line: Colors.white.withValues(alpha: 0.06)),
            ),
            ..._buildHourLabels(),
            ..._buildAppointmentBlocks(context),
            if (_isToday(day)) _buildNowIndicator(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHourLabels() {
    final labels = <Widget>[];
    for (var hour = _kStartHour; hour <= _kEndHour; hour++) {
      final top = (hour - _kStartHour) * _kHourHeight;
      labels.add(
        Positioned(
          left: 0,
          top: top - 7,
          width: _kHourLabelWidth - 10,
          child: Text(
            '${hour.toString().padLeft(2, '0')}:00',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.32),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      );
    }
    return labels;
  }

  List<Widget> _buildAppointmentBlocks(BuildContext context) {
    final blocks = <Widget>[];
    for (final appt in appointments) {
      if (appt.status == AgendaStatus.cancelled || appt.status == AgendaStatus.noShow) continue;
      final startMinutes = appt.startTime.hour * 60 + appt.startTime.minute;
      final endMinutes = appt.endTime.hour * 60 + appt.endTime.minute;
      final startOffset = _minutesToOffset(startMinutes);
      final endOffset = _minutesToOffset(endMinutes);
      if (endOffset <= 0 || startOffset >= (_kEndHour - _kStartHour) * _kHourHeight) continue;

      final top = startOffset.clamp(0.0, (_kEndHour - _kStartHour) * _kHourHeight);
      final bottom = endOffset.clamp(0.0, (_kEndHour - _kStartHour) * _kHourHeight);
      final height = (bottom - top).clamp(28.0, double.infinity);

      blocks.add(
        Positioned(
          left: _kHourLabelWidth,
          right: 0,
          top: top,
          height: height,
          child: _MatrixBlock(appointment: appt),
        ),
      );
    }
    return blocks;
  }

  Widget _buildNowIndicator() {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    final offset = _minutesToOffset(minutes);
    if (offset < 0 || offset > (_kEndHour - _kStartHour) * _kHourHeight) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: _kHourLabelWidth - 14,
      right: 0,
      top: offset - 1,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.redAccent.shade400,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.6), blurRadius: 6)],
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: Colors.redAccent.shade400,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  double _minutesToOffset(int totalMinutes) {
    final base = _kStartHour * 60;
    return (totalMinutes - base) / 60.0 * _kHourHeight;
  }
}

class _HourLinesPainter extends CustomPainter {
  _HourLinesPainter({required this.line});

  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final left = _kHourLabelWidth;
    final linePaint = Paint()
      ..color = line
      ..strokeWidth = 1;

    // Una sola línea hairline por hora (estilo calendario de día iOS).
    for (var hour = _kStartHour; hour <= _kEndHour; hour++) {
      final y = (hour - _kStartHour) * _kHourHeight;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HourLinesPainter oldDelegate) => oldDelegate.line != line;
}

class _MatrixBlock extends StatelessWidget {
  const _MatrixBlock({required this.appointment});

  final AgendaAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final statusColor = agendaStatusColor(appointment.status, context.primaryGold);
    final hh = appointment.startTime.hour.toString().padLeft(2, '0');
    final mm = appointment.startTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hh:$mm';

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (ctx) => BlocProvider.value(
              value: context.read<AgendaBloc>(),
              child: AppointmentActionSheet(appointment: appointment),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: statusColor),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 54;
                    final service = appointment.serviceName;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 9, vertical: compact ? 4 : 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (appointment.customerName ?? 'Cliente').toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                timeStr,
                                style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                              ),
                            ],
                          ),
                          if (!compact && service != null && service.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              service,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white60, fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
