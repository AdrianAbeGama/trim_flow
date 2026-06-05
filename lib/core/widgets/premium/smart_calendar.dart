import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

/// Calendario "smart" compartido (reservar + agenda).
/// Semana (colapsado) y mes (expandido) navegables con PageView (slide real).
/// Día seleccionado con contorno animado. Dot blanco para días marcados.
class SmartCalendar extends StatefulWidget {
  const SmartCalendar({
    super.key,
    required this.selectedDate,
    required this.onDaySelected,
    this.firstSelectableDate,
    this.markedDates = const [],
    this.collapseOnSelect = false,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;
  final DateTime? firstSelectableDate;
  final List<DateTime> markedDates;
  final bool collapseOnSelect;

  @override
  State<SmartCalendar> createState() => _SmartCalendarState();
}

class _SmartCalendarState extends State<SmartCalendar> {
  static const int _base = 12000;
  static const double _rowH = 58;

  bool _expanded = false;
  late final PageController _weekController;
  late final PageController _monthController;
  late final DateTime _refWeekStart;
  late final DateTime _refMonth;
  late DateTime _displayedWeekStart;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _refWeekStart = _mondayOf(widget.selectedDate);
    _refMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
    _displayedWeekStart = _refWeekStart;
    _displayedMonth = _refMonth;
    _weekController = PageController(initialPage: _base);
    _monthController = PageController(initialPage: _base);
  }

  @override
  void didUpdateWidget(SmartCalendar old) {
    super.didUpdateWidget(old);
    if (!_sameDay(old.selectedDate, widget.selectedDate)) {
      final newMonday = _mondayOf(widget.selectedDate);
      final weekOffset = newMonday.difference(_refWeekStart).inDays ~/ 7;
      final monthOffset =
          (widget.selectedDate.year - _refMonth.year) * 12 + (widget.selectedDate.month - _refMonth.month);
      if (_weekController.hasClients) {
        _weekController.animateToPage(_base + weekOffset, duration: const Duration(milliseconds: 340), curve: Curves.easeOutCubic);
      }
      if (_monthController.hasClients) {
        _monthController.animateToPage(_base + monthOffset, duration: const Duration(milliseconds: 340), curve: Curves.easeOutCubic);
      }
    }
  }

  @override
  void dispose() {
    _weekController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  DateTime _mondayOf(DateTime d) => DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  DateTime _addMonths(DateTime m, int delta) => DateTime(m.year, m.month + delta, 1);

  void _onTapDay(DateTime date) {
    HapticFeedback.selectionClick();
    widget.onDaySelected(date);
    if (widget.collapseOnSelect && _expanded) {
      setState(() => _expanded = false);
    }
    // La barra de 7 días debe mostrar la semana del día elegido.
    _syncWeekTo(date);
  }

  void _syncWeekTo(DateTime date) {
    final weekOffset = _mondayOf(date).difference(_refWeekStart).inDays ~/ 7;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_weekController.hasClients) {
        _weekController.jumpToPage(_base + weekOffset);
        setState(() => _displayedWeekStart = _refWeekStart.add(Duration(days: weekOffset * 7)));
      }
    });
  }

  bool _isDisabled(DateTime date) {
    final first = widget.firstSelectableDate;
    if (first == null) return false;
    final d = DateTime(date.year, date.month, date.day);
    return d.isBefore(DateTime(first.year, first.month, first.day));
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final headerLabel = DateFormat('MMMM yyyy', 'es').format(_expanded ? _displayedMonth : _displayedWeekStart).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: mes/año centrado (navegación por swipe)
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
            child: Text(
              headerLabel,
              key: ValueKey(headerLabel),
              style: GoogleFonts.inter(color: gold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Letras de los días
        Row(
          children: const ['L', 'M', 'M', 'J', 'V', 'S', 'D']
              .map((l) => Expanded(child: Center(child: _WeekdayLetter(l))))
              .toList(),
        ),
        const SizedBox(height: 4),
        // Grid (semana o mes) con PageView
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: _expanded ? _rowH * 6 : _rowH,
            child: _expanded ? _buildMonthPager() : _buildWeekPager(),
          ),
        ),
        const SizedBox(height: 10),
        // Toggle ver mes / cerrar + ir al día seleccionado
        Row(
          children: [
            Expanded(
              child: PremiumPressable(
                pressedScale: 0.98,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _expanded = !_expanded);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_expanded ? Icons.close_rounded : Icons.calendar_month_rounded, color: gold, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _expanded ? 'CERRAR CALENDARIO' : 'ELEGIR OTRO DÍA',
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            PremiumPressable(
              pressedScale: 0.95,
              onTap: _goToToday,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location_rounded, color: gold, size: 15),
                    const SizedBox(width: 6),
                    Text('HOY', style: GoogleFonts.inter(color: gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _goToToday() {
    HapticFeedback.lightImpact();
    final today = DateTime.now();
    widget.onDaySelected(today);
    if (_expanded) setState(() => _expanded = false);
    _syncWeekTo(today);
  }

  Widget _buildWeekPager() {
    return PageView.builder(
      controller: _weekController,
      onPageChanged: (i) => setState(() => _displayedWeekStart = _refWeekStart.add(Duration(days: (i - _base) * 7))),
      itemBuilder: (context, i) {
        final weekStart = _refWeekStart.add(Duration(days: (i - _base) * 7));
        return Row(
          children: List.generate(7, (d) => _dayTile(weekStart.add(Duration(days: d)), inMonth: true)),
        );
      },
    );
  }

  Widget _buildMonthPager() {
    return PageView.builder(
      controller: _monthController,
      onPageChanged: (i) => setState(() => _displayedMonth = _addMonths(_refMonth, i - _base)),
      itemBuilder: (context, i) {
        final month = _addMonths(_refMonth, i - _base);
        final firstVisible = _mondayOf(DateTime(month.year, month.month, 1));
        return Column(
          children: List.generate(6, (w) {
            return SizedBox(
              height: _rowH,
              child: Row(
                children: List.generate(7, (d) {
                  final date = firstVisible.add(Duration(days: w * 7 + d));
                  return _dayTile(date, inMonth: date.month == month.month);
                }),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _dayTile(DateTime date, {required bool inMonth}) {
    final gold = context.primaryGold;
    final isSelected = _sameDay(date, widget.selectedDate);
    final isMarked = widget.markedDates.any((d) => _sameDay(d, date));
    final disabled = _isDisabled(date) || !inMonth;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : () => _onTapDay(date),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: AnimatedScale(
            scale: isSelected ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? gold.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isSelected ? gold : Colors.white.withValues(alpha: 0.06),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [BoxShadow(color: gold.withValues(alpha: 0.35), blurRadius: 12, spreadRadius: -2)] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${date.day}',
                    style: GoogleFonts.inter(
                      color: disabled
                          ? Colors.white.withValues(alpha: 0.15)
                          : (isSelected ? gold : Colors.white),
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isMarked ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
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

class _WeekdayLetter extends StatelessWidget {
  const _WeekdayLetter(this.letter);
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Text(
      letter,
      style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: 0.3),
    );
  }
}
