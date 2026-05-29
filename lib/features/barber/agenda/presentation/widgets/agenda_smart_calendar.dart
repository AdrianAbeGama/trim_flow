import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_event.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_state.dart';

class AgendaSmartCalendar extends StatefulWidget {
  const AgendaSmartCalendar({super.key});

  @override
  State<AgendaSmartCalendar> createState() => _AgendaSmartCalendarState();
}

class _AgendaSmartCalendarState extends State<AgendaSmartCalendar> {
  bool _isCalendarExpanded = false;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final initialDate = context.read<AgendaBloc>().state.selectedDay;
    _focusedMonth = DateTime(initialDate.year, initialDate.month, 1);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgendaBloc, AgendaUiState>(
      buildWhen: (p, c) => p.selectedDay != c.selectedDay,
      builder: (context, state) {
        final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
        final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
        
        final firstVisibleDay = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
        final lastVisibleDay = lastDayOfMonth.add(Duration(days: 7 - lastDayOfMonth.weekday));
        final totalDaysCount = lastVisibleDay.difference(firstVisibleDay).inDays + 1;
        final weeksCount = (totalDaysCount / 7).ceil();

        final weeks = List.generate(weeksCount, (weekIdx) {
          return List.generate(7, (dayIdx) {
            return firstVisibleDay.add(Duration(days: weekIdx * 7 + dayIdx));
          });
        });

        // Current week to show when collapsed
        final bool isCurrentFocusedMonth = _focusedMonth.year == state.selectedDay.year && _focusedMonth.month == state.selectedDay.month;
        final DateTime targetRef = isCurrentFocusedMonth ? state.selectedDay : firstDayOfMonth;
        
        int activeWeekIdx = weeks.indexWhere((week) => week.any((d) => d.year == targetRef.year && d.month == targetRef.month && d.day == targetRef.day));
        if (activeWeekIdx == -1) activeWeekIdx = 0;

        return Column(
          children: [
            // Current Month and Day Header (when collapsed)
            if (!_isCalendarExpanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat("d 'DE' MMMM 'DE' yyyy", 'es').format(state.selectedDay).toUpperCase(),
                      style: TextStyle(
                        color: context.primaryGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        final now = DateTime.now();
                        context.read<AgendaBloc>().add(AgendaEvent.daySelected(DateTime(now.year, now.month, now.day)));
                        if (_isCalendarExpanded) {
                          setState(() => _isCalendarExpanded = false);
                        }
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: context.primaryGold.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded, color: context.primaryGold, size: 10),
                            const SizedBox(width: 4),
                            Text(
                              'HOY',
                              style: TextStyle(
                                color: context.primaryGold,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Month Header (Only when expanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutQuart,
              child: SizedBox(
                height: _isCalendarExpanded ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.primaryGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        DateFormat('MMMM yyyy', 'es').format(_focusedMonth).toUpperCase(),
                        style: TextStyle(
                          color: context.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            RepaintBoundary(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    if (_isCalendarExpanded) {
                      _changeMonth(1);
                    } else {
                      context.read<AgendaBloc>().add(AgendaEvent.daySelected(state.selectedDay.add(const Duration(days: 7))));
                    }
                  } else if (details.primaryVelocity! > 0) {
                    if (_isCalendarExpanded) {
                      _changeMonth(-1);
                    } else {
                      context.read<AgendaBloc>().add(AgendaEvent.daySelected(state.selectedDay.subtract(const Duration(days: 7))));
                    }
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutQuart,
                  switchOutCurve: Curves.easeInQuart,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final inAnimation = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(animation);
                    final outAnimation = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(animation);
                    return SlideTransition(
                      position: child.key == ValueKey('${_focusedMonth.year}-${_focusedMonth.month}-${state.selectedDay.year}-${state.selectedDay.month}-${state.selectedDay.day}') 
                          ? inAnimation : outAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Column(
                    key: ValueKey('week_${weeks[activeWeekIdx].first.toIso8601String()}_exp_$_isCalendarExpanded'),
                    children: [
                      // Previous weeks
                      AnimatedSize(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutQuart,
                        child: SizedBox(
                          height: _isCalendarExpanded ? null : 0,
                          child: Column(
                            children: weeks.sublist(0, activeWeekIdx).map((week) => _buildWeekRow(context, week, state.selectedDay)).toList(),
                          ),
                        ),
                      ),
                      
                      // Active week (Always visible)
                      _buildWeekRow(context, weeks[activeWeekIdx], state.selectedDay),
                      
                      // Next weeks
                      AnimatedSize(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutQuart,
                        child: SizedBox(
                          height: _isCalendarExpanded ? null : 0,
                          child: Column(
                            children: weeks.sublist(activeWeekIdx + 1).map((week) => _buildWeekRow(context, week, state.selectedDay)).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            
            // Togle Button
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
                        _isCalendarExpanded ? Icons.close_rounded : Icons.calendar_month_rounded,
                        color: context.primaryGold,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCalendarExpanded ? 'CERRAR CALENDARIO' : 'VER CALENDARIO',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Month navigation controls
            if (_isCalendarExpanded) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMonthNavButton(
                    context: context,
                    label: 'MES ANTERIOR',
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => _changeMonth(-1),
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
      },
    );
  }

  Widget _buildWeekRow(BuildContext context, List<DateTime> week, DateTime selectedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: week.map((date) => _buildDayTile(context, date, selectedDate)).toList(),
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

  Widget _buildDayTile(BuildContext context, DateTime date, DateTime selectedDate) {
    final isSelected = selectedDate.day == date.day &&
        selectedDate.month == date.month &&
        selectedDate.year == date.year;
    
    final bool isFromFocusedMonth = date.month == _focusedMonth.month;
    final bool isDisabled = _isCalendarExpanded && !isFromFocusedMonth;
    final bool hasMockedOrder = date.day == 29; // Hardcodeado según audio "viernes 29 que están mockeados"
        
    return Expanded(
      flex: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isDisabled ? null : () {
          context.read<AgendaBloc>().add(AgendaEvent.daySelected(date));
          if (_isCalendarExpanded) {
            setState(() => _isCalendarExpanded = false);
          }
        },
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
              if (hasMockedOrder) ...[
                const SizedBox(height: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.cyanAccent.shade700 : Colors.cyanAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: isSelected ? 0.2 : 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 9),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
