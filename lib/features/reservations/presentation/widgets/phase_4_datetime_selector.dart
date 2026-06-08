import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/premium/smart_calendar.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_state.dart';

class Phase4DateTimeSelector extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime? selectedSlotUtc;
  final List<DateTime> availableSlots;
  final SlotsStatus slotsStatus;
  final bool isCompleted;
  final void Function(DateTime date) onDateChanged;
  final void Function(DateTime startUtc) onSelectSlot;

  const Phase4DateTimeSelector({
    super.key,
    required this.selectedDate,
    required this.selectedSlotUtc,
    required this.availableSlots,
    required this.slotsStatus,
    required this.isCompleted,
    required this.onDateChanged,
    required this.onSelectSlot,
  });

  @override
  State<Phase4DateTimeSelector> createState() => _Phase4DateTimeSelectorState();
}

class _Phase4DateTimeSelectorState extends State<Phase4DateTimeSelector> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDateChanged(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompleted && widget.selectedSlotUtc != null) {
      return _buildCompletedState(context);
    }

    final morning = <DateTime>[];
    final afternoon = <DateTime>[];
    final evening = <DateTime>[];
    for (final utc in widget.availableSlots) {
      final local = utc.toLocal();
      if (local.hour < 12) {
        morning.add(utc);
      } else if (local.hour < 18) {
        afternoon.add(utc);
      } else {
        evening.add(utc);
      }
    }

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionLabel('4 · Fecha y hora'),
          const SizedBox(height: 18),
          SmartCalendar(
            selectedDate: _selectedDate,
            firstSelectableDate: DateTime.now(),
            onDaySelected: (date) {
              setState(() => _selectedDate = date);
              widget.onDateChanged(date);
            },
          ),
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                Text(
                  'SELECCIONA UNA HORA',
                  style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat("EEEE d 'de' MMMM", 'es').format(_selectedDate).toUpperCase(),
                  style: GoogleFonts.inter(color: context.primaryGold.withValues(alpha: 0.65), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildBody(context, morning, afternoon, evening),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<DateTime> morning, List<DateTime> afternoon, List<DateTime> evening) {
    if (widget.slotsStatus == SlotsStatus.loading || widget.slotsStatus == SlotsStatus.initial) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 34),
        child: Center(child: CircularProgressIndicator(color: context.primaryGold, strokeWidth: 2)),
      );
    }
    if (widget.slotsStatus == SlotsStatus.error) {
      return _message('No se pudieron cargar los horarios. Intenta de nuevo.');
    }
    if (widget.availableSlots.isEmpty) {
      return _message('No hay horarios disponibles ese día. Prueba con otra fecha.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPeriodSection(context, 'MAÑANA', Icons.wb_sunny_rounded, morning),
        _buildPeriodSection(context, 'TARDE', Icons.wb_twilight_rounded, afternoon),
        _buildPeriodSection(context, 'NOCHE', Icons.nightlight_round, evening),
      ],
    );
  }

  Widget _message(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildPeriodSection(BuildContext context, String label, IconData icon, List<DateTime> slots) {
    if (slots.isEmpty) return const SizedBox.shrink();
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: gold.withValues(alpha: 0.8)),
              const SizedBox(width: 7),
              Text(
                label,
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6),
              ),
              const SizedBox(width: 8),
              Text(
                '${slots.length} libre${slots.length == 1 ? '' : 's'}',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.28), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slots.map((utc) => _buildTimeTile(context, utc)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(BuildContext context, DateTime utc) {
    final local = utc.toLocal();
    final label = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final isSelected = widget.selectedSlotUtc != null && utc.isAtSameMomentAs(widget.selectedSlotUtc!);
    final gold = context.primaryGold;

    return PremiumPressable(
      pressedScale: 0.9,
      onTap: () => widget.onSelectSlot(utc),
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 76,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? gold.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.02),
            border: Border.all(
              color: isSelected ? gold : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [BoxShadow(color: gold.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: -2)] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isSelected ? gold : Colors.white,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final date = widget.selectedDate ?? widget.selectedSlotUtc!.toLocal();
    final local = widget.selectedSlotUtc!.toLocal();
    final timeStr = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final dateStr = DateFormat("EEEE d 'de' MMMM", 'es').format(date);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.primaryGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.primaryGold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, color: context.primaryGold, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FECHA Y HORA', style: GoogleFonts.inter(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                const SizedBox(height: 2),
                Text(
                  '${dateStr[0].toUpperCase()}${dateStr.substring(1)} · $timeStr',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: context.primaryGold, size: 20),
        ],
      ),
    );
  }
}
