import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

enum _ViewMode { hijri, gregorian }

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  _ViewMode _mode = _ViewMode.hijri;
  late int _year;
  late int _month;

  static const _weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    final today = HijriCalendar.now();
    _year = today.hYear;
    _month = today.hMonth;
  }

  void _changeMonth(int delta) {
    setState(() {
      _month += delta;
      if (_month > 12) {
        _month = 1;
        _year++;
      } else if (_month < 1) {
        _month = 12;
        _year--;
      }
    });
  }

  void _switchMode(_ViewMode mode) {
    if (mode == _mode) return;
    setState(() {
      if (mode == _ViewMode.hijri) {
        final h = HijriCalendar.fromDate(DateTime(_year, _month, 1));
        _year = h.hYear;
        _month = h.hMonth;
      } else {
        final gregorian = HijriCalendar().hijriToGregorian(_year, _month, 1);
        _year = gregorian.year;
        _month = gregorian.month;
      }
      _mode = mode;
    });
  }

  void _goToToday() {
    setState(() {
      if (_mode == _ViewMode.hijri) {
        final h = HijriCalendar.now();
        _year = h.hYear;
        _month = h.hMonth;
      } else {
        final now = DateTime.now();
        _year = now.year;
        _month = now.month;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(icon: const Icon(Icons.today), tooltip: 'Today', onPressed: _goToToday),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: SegmentedButton<_ViewMode>(
              segments: const [
                ButtonSegment(value: _ViewMode.hijri, label: Text('Hijri')),
                ButtonSegment(value: _ViewMode.gregorian, label: Text('Gregorian')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => _switchMode(s.first),
            ),
          ),
          _MonthHeader(
            title: _mode == _ViewMode.hijri ? _hijriMonthTitle() : _gregorianMonthTitle(),
            onPrevious: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _weekdayLabels
                  .map((label) => Expanded(
                        child: Center(
                          child: Text(
                            label,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _mode == _ViewMode.hijri ? _HijriMonthGrid(year: _year, month: _month) : _GregorianMonthGrid(year: _year, month: _month),
          ),
        ],
      ),
    );
  }

  String _hijriMonthTitle() {
    final cal = HijriCalendar()
      ..hYear = _year
      ..hMonth = _month
      ..hDay = 1;
    return '${cal.getLongMonthName()} $_year AH';
  }

  String _gregorianMonthTitle() {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[_month - 1]} $_year';
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.title, required this.onPrevious, required this.onNext});

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrevious),
        SizedBox(
          width: 200,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
      ],
    );
  }
}

class _HijriMonthGrid extends StatelessWidget {
  const _HijriMonthGrid({required this.year, required this.month});

  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final cal = HijriCalendar();
    final daysInMonth = cal.getDaysInMonth(year, month);
    final firstGregorian = cal.hijriToGregorian(year, month, 1);
    final leadingBlanks = firstGregorian.weekday % 7; // Sunday-first
    final today = HijriCalendar.now();

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _DayCell(
          primary: '$day',
          secondary: DateFormatShort.format(cal.hijriToGregorian(year, month, day)),
          isToday: today.hYear == year && today.hMonth == month && today.hDay == day,
        ),
    ];

    return _DayGrid(cells: cells);
  }
}

class _GregorianMonthGrid extends StatelessWidget {
  const _GregorianMonthGrid({required this.year, required this.month});

  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDay = DateTime(year, month, 1);
    final leadingBlanks = firstDay.weekday % 7; // Sunday-first
    final now = DateTime.now();

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _DayCell(
          primary: '$day',
          secondary: HijriCalendar.fromDate(DateTime(year, month, day)).hDay.toString(),
          isToday: now.year == year && now.month == month && now.day == day,
        ),
    ];

    return _DayGrid(cells: cells);
  }
}

class _DayGrid extends StatelessWidget {
  const _DayGrid({required this.cells});

  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 7,
      padding: const EdgeInsets.all(8),
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.primary, required this.secondary, required this.isToday});

  final String primary;
  final String secondary;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isToday ? colorScheme.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              primary,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                color: isToday ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            secondary,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Tiny "d/m" formatter to avoid pulling `intl` into this file just for a
/// two-number label.
class DateFormatShort {
  static String format(DateTime date) => '${date.day}/${date.month}';
}
