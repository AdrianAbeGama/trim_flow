import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class Phase4DateTimeSelector extends StatefulWidget {
  final int totalDurationInMinutes;
  final DateTime? selectedDate;
  final String? selectedTime;
  final List<String> occupiedTimes;
  final void Function(DateTime date, String time) onSelectTime;
  final VoidCallback onConfirm;
  final bool isCompleted;

  const Phase4DateTimeSelector({
    super.key,
    required this.totalDurationInMinutes,
    required this.selectedDate,
    required this.selectedTime,
    required this.occupiedTimes,
    required this.onSelectTime,
    required this.onConfirm,
    required this.isCompleted,
  });

  @override
  State<Phase4DateTimeSelector> createState() => _Phase4DateTimeSelectorState();
}

class _Phase4DateTimeSelectorState extends State<Phase4DateTimeSelector> {
  late DateTime _selectedDate;
  String? _selectedTime;
  bool _isCalendarExpanded = false;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _selectedTime = widget.selectedTime;
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  List<String> _buildTimeSlots() {
    final step = (widget.totalDurationInMinutes > 0 ? widget.totalDurationInMinutes : 30).clamp(30, 120);
    final slots = <String>[];
    for (int m = 8 * 60; m < 18 * 60; m += step) {
      final h = (m ~/ 60).toString().padLeft(2, '0');
      final min = (m % 60).toString().padLeft(2, '0');
      slots.add('$h:$min');
    }
    return slots;
  }

  bool _isPast(String time, DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (!isToday) return false;
    final parts = time.split(':');
    final slotMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final nowMinutes = now.hour * 60 + now.minute;
    return slotMinutes <= nowMinutes;
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
    });
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
          // Header fijo con Título de Fase
          Text(
            '4. FECHA Y HORA',
            style: TextStyle(
              color: context.primaryGold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          
          // Título del Mes arriba del calendario
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                DateFormat('MMMM yyyy', 'es').format(_focusedMonth).toUpperCase(),
                style: TextStyle(color: context.primaryGold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Calendario de Semanas Expansible
          _buildSmartCalendarGrid(context),

          const SizedBox(height: 16),

          // Título "Selecciona una hora" centrado bajo el calendario
          Center(
            child: Column(
              children: [
                Text(
                  'SELECCIONA UNA HORA',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.primaryGold.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    DateFormat("EEEE d 'de' MMMM", 'es').format(_selectedDate).toUpperCase(),
                    style: TextStyle(color: context.primaryGold.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((time) => _buildTimeTile(context, time)).toList(),
            ),
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: _selectedTime != null ? widget.onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryGold,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
              disabledForegroundColor: Colors.white12,
              elevation: 0,
            ),
            child: const Text('CONFIRMAR CITA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartCalendarGrid(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    // Calcular todas las semanas que contienen días de este mes
    final firstVisibleDay = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    final lastVisibleDay = lastDayOfMonth.add(Duration(days: 7 - lastDayOfMonth.weekday));
    final totalDaysCount = lastVisibleDay.difference(firstVisibleDay).inDays + 1;
    final weeksCount = (totalDaysCount / 7).ceil();

    final weeks = List.generate(weeksCount, (weekIdx) {
      return List.generate(7, (dayIdx) {
        return firstVisibleDay.add(Duration(days: weekIdx * 7 + dayIdx));
      });
    });

    // Encontrar la semana "activa" (la que contiene el día de hoy o el día seleccionado)
    // Para simplificar, si estamos en el mes actual, la semana de "hoy". Si no, la primera semana del mes.
    final bool isCurrentFocusedMonth = _focusedMonth.year == now.year && _focusedMonth.month == now.month;
    final DateTime targetRef = isCurrentFocusedMonth ? now : firstDayOfMonth;
    
    int activeWeekIdx = weeks.indexWhere((week) => week.any((d) => d.year == targetRef.year && d.month == targetRef.month && d.day == targetRef.day));
    if (activeWeekIdx == -1) activeWeekIdx = 0;

    return Column(
      children: [
        RepaintBoundary(
          child: Column(
            children: [
              // Semanas de Arriba (Anterior a la activa)
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutQuart,
                child: SizedBox(
                  height: _isCalendarExpanded ? null : 0,
                  child: Column(
                    children: weeks.sublist(0, activeWeekIdx).map((week) => _buildWeekRow(context, week)).toList(),
                  ),
                ),
              ),
              
              // SEMANA ACTUAL / ACTIVA (Siempre visible)
              _buildWeekRow(context, weeks[activeWeekIdx]),
              
              // Semanas de Abajo (Posterior a la activa)
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutQuart,
                child: SizedBox(
                  height: _isCalendarExpanded ? null : 0,
                  child: Column(
                    children: weeks.sublist(activeWeekIdx + 1).map((week) => _buildWeekRow(context, week)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        
        // BOTÓN ELEGIR OTRO DÍA (Bajo la fila)
        Center(
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() => _isCalendarExpanded = !_isCalendarExpanded),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.04),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCalendarExpanded ? Icons.close_rounded : Icons.calendar_today_rounded,
                    color: context.primaryGold,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isCalendarExpanded ? 'CERRAR CALENDARIO' : 'ELEGIR OTRO DÍA',
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ),

        // CONTROLES DE MES (Solo cuando está expandido)
        if (_isCalendarExpanded) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMonthNavButton(
                context: context,
                label: 'MES ANTERIOR',
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: (_focusedMonth.year < now.year || (_focusedMonth.year == now.year && _focusedMonth.month <= now.month)) 
                  ? null : () => _changeMonth(-1),
                isLeft: true,
              ),
              _buildMonthNavButton(
                context: context,
                label: 'MES SIGUIENTE',
                icon: Icons.arrow_forward_ios_rounded,
                onPressed: () => _changeMonth(1),
                isLeft: false,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildWeekRow(BuildContext context, List<DateTime> week) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: week.map((date) => _buildDayTile(context, date)).toList(),
      ),
    );
  }

  Widget _buildMonthNavButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isLeft,
  }) {
    final color = onPressed == null ? Colors.white10 : context.primaryGold;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLeft) ...[Icon(icon, color: color, size: 14), const SizedBox(width: 8)],
            Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            if (!isLeft) ...[const SizedBox(width: 8), Icon(icon, color: color, size: 14)],
          ],
        ),
      ),
    );
  }

  Widget _buildDayTile(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final isSelected = _selectedDate.day == date.day &&
        _selectedDate.month == date.month &&
        _selectedDate.year == date.year;
    
    final bool isFromFocusedMonth = date.month == _focusedMonth.month;
    final bool isPast = date.isBefore(DateTime(now.year, now.month, now.day));
    final bool isDisabled = !isFromFocusedMonth || isPast;
        
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: isDisabled ? null : () => setState(() {
          _selectedDate = date;
          _selectedTime = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.primaryGold : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? context.primaryGold : (isDisabled ? Colors.transparent : Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('E', 'es').format(date).substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.black : (isDisabled ? Colors.white10 : Colors.white38),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  color: isSelected ? Colors.black : (isDisabled ? Colors.white10 : Colors.white),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile(BuildContext context, String time) {
    final isPast = _isPast(time, _selectedDate);
    final isOccupied = widget.occupiedTimes.contains(time);
    final isBlocked = isPast || isOccupied;
    final isSelected = _selectedTime == time;

    return GestureDetector(
      onTap: isBlocked ? null : () {
        setState(() => _selectedTime = time);
        widget.onSelectTime(_selectedDate, time);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryGold.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? context.primaryGold : isBlocked ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                color: isSelected ? context.primaryGold : isBlocked ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final dateStr = DateFormat("EEEE d 'de' MMMM", 'es').format(widget.selectedDate!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                const Text('FECHA Y HORA', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text(
                  '${dateStr[0].toUpperCase()}${dateStr.substring(1)} · ${widget.selectedTime}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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
