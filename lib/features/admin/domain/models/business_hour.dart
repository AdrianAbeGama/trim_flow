// Horario de atención de un día (tabla business_hours). day_of_week: 0=Lun..6=Dom.

class BusinessHour {
  const BusinessHour({
    required this.dayOfWeek,
    required this.isClosed,
    this.open,
    this.close,
  });

  final int dayOfWeek;
  final bool isClosed;
  final String? open; // 'HH:MM'
  final String? close; // 'HH:MM'

  BusinessHour copyWith({String? open, String? close, bool? isClosed}) =>
      BusinessHour(
        dayOfWeek: dayOfWeek,
        isClosed: isClosed ?? this.isClosed,
        open: open ?? this.open,
        close: close ?? this.close,
      );

  factory BusinessHour.fromRow(Map<String, dynamic> r) => BusinessHour(
        dayOfWeek: (r['day_of_week'] as num?)?.toInt() ?? 0,
        isClosed: (r['is_closed'] as bool?) ?? false,
        open: _hhmm(r['open_time'] as String?),
        close: _hhmm(r['close_time'] as String?),
      );

  Map<String, dynamic> toSpec() => {
        'day_of_week': dayOfWeek,
        'is_closed': isClosed,
        'open_time': isClosed ? null : '${open ?? '09:00'}:00',
        'close_time': isClosed ? null : '${close ?? '18:00'}:00',
      };
}

String? _hhmm(String? t) {
  if (t == null || t.length < 5) return null;
  return t.substring(0, 5);
}
