import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              painter: _GridPainter(gridColor: Colors.white.withValues(alpha: 0.08)),
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
          top: top - 6,
          width: _kHourLabelWidth - 8,
          child: Text(
            '${hour.toString().padLeft(2, '0')}:00',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
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

class _GridPainter extends CustomPainter {
  _GridPainter({required this.gridColor});
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;
    final dashedPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 0.6;

    for (var hour = _kStartHour; hour <= _kEndHour; hour++) {
      final y = (hour - _kStartHour) * _kHourHeight;
      canvas.drawLine(Offset(_kHourLabelWidth, y), Offset(size.width, y), linePaint);
      final halfY = y + _kHourHeight / 2;
      if (halfY < size.height) {
        _drawDashedLine(canvas, Offset(_kHourLabelWidth, halfY), Offset(size.width, halfY), dashedPaint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const gap = 4.0;
    double x = start.dx;
    while (x < end.dx) {
      canvas.drawLine(Offset(x, start.dy), Offset((x + dashWidth).clamp(0, end.dx), start.dy), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.gridColor != gridColor;
}

class _MatrixBlock extends StatelessWidget {
  const _MatrixBlock({required this.appointment});

  final AgendaAppointment appointment;

  Color getStatusColor() {
    switch (appointment.status) {
      case AgendaStatus.confirmed: return const Color(0xFF3B82F6);
      case AgendaStatus.pending: return const Color(0xFFF59E0B);
      case AgendaStatus.completed: return const Color(0xFF4ADE80);
      case AgendaStatus.cancelled:
      case AgendaStatus.noShow: return const Color(0xFFCF6679);
      default: return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor();
    
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (ctx) => BlocProvider.value(
              value: context.read<AgendaBloc>(),
              child: AppointmentActionSheet(appointment: appointment),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withValues(alpha: 1.0),
              width: 1.5,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - _kHourLabelWidth - 36,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (appointment.customerName ?? 'Cliente').toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      AgendaStatusBadge(status: appointment.status, compact: true),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.serviceName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
