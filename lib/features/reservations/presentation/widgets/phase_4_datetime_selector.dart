import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/premium/smart_calendar.dart';

class Phase4DateTimeSelector extends StatefulWidget {
  final int totalDurationInMinutes;
  final DateTime? selectedDate;
  final String? selectedTime;
  final List<String> occupiedTimes;
  final void Function(DateTime date, String time) onSelectTime;
  final bool isCompleted;

  const Phase4DateTimeSelector({
    super.key,
    required this.totalDurationInMinutes,
    required this.selectedDate,
    required this.selectedTime,
    required this.occupiedTimes,
    required this.onSelectTime,
    required this.isCompleted,
  });

  @override
  State<Phase4DateTimeSelector> createState() => _Phase4DateTimeSelectorState();
}

class _Phase4DateTimeSelectorState extends State<Phase4DateTimeSelector> {
  late DateTime _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _selectedTime = widget.selectedTime;
  }

  List<String> _buildTimeSlots() {
    final step = (widget.totalDurationInMinutes > 0 ? widget.totalDurationInMinutes : 30).clamp(30, 120);
    final slots = <String>[];
    for (int m = 8 * 60; m < 21 * 60; m += step) {
      final h = (m ~/ 60).toString().padLeft(2, '0');
      final min = (m % 60).toString().padLeft(2, '0');
      slots.add('$h:$min');
    }
    return slots;
  }

  int _hourOf(String time) => int.parse(time.split(':')[0]);

  bool _isPast(String time, DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (!isToday) return false;
    final parts = time.split(':');
    final slotMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final nowMinutes = now.hour * 60 + now.minute;
    return slotMinutes <= nowMinutes;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompleted && widget.selectedDate != null && widget.selectedTime != null) {
      return _buildCompletedState(context);
    }

    final timeSlots = _buildTimeSlots();

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionLabel('4 · Fecha y hora'),
          const SizedBox(height: 18),
          SmartCalendar(
            selectedDate: _selectedDate,
            firstSelectableDate: DateTime.now(),
            onDaySelected: (date) => setState(() {
              _selectedDate = date;
              _selectedTime = null;
            }),
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
          _buildPeriodSection(context, 'MAÑANA', Icons.wb_sunny_rounded,
              timeSlots.where((t) => _hourOf(t) < 12).toList()),
          _buildPeriodSection(context, 'TARDE', Icons.wb_twilight_rounded,
              timeSlots.where((t) => _hourOf(t) >= 12 && _hourOf(t) < 18).toList()),
          _buildPeriodSection(context, 'NOCHE', Icons.nightlight_round,
              timeSlots.where((t) => _hourOf(t) >= 18).toList()),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPeriodSection(BuildContext context, String label, IconData icon, List<String> slots) {
    if (slots.isEmpty) return const SizedBox.shrink();
    final gold = context.primaryGold;
    final available = slots.where((t) => !_isPast(t, _selectedDate) && !widget.occupiedTimes.contains(t)).length;
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
                '$available libre${available == 1 ? '' : 's'}',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.28), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slots.map((time) => _buildTimeTile(context, time)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(BuildContext context, String time) {
    final isPast = _isPast(time, _selectedDate);
    final isOccupied = widget.occupiedTimes.contains(time);
    final isBlocked = isPast || isOccupied;
    final isSelected = _selectedTime == time;
    final gold = context.primaryGold;

    return PremiumPressable(
      pressedScale: 0.9,
      onTap: isBlocked
          ? null
          : () {
              setState(() => _selectedTime = time);
              widget.onSelectTime(_selectedDate, time);
            },
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
              color: isSelected
                  ? gold
                  : isBlocked
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [BoxShadow(color: gold.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: -2)] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: GoogleFonts.inter(
                  color: isSelected
                      ? gold
                      : isBlocked
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white,
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
    final dateStr = DateFormat("EEEE d 'de' MMMM", 'es').format(widget.selectedDate!);
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
                  '${dateStr[0].toUpperCase()}${dateStr.substring(1)} · ${widget.selectedTime}',
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
