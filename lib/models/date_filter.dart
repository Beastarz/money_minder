import 'package:date_format/date_format.dart';

enum DateFilterType {
  // does not have duration
  all,
  year,
  month,

  // have duration
  week, // 7 days
  day, // 1 day
  range, // range of days
}

class DateFilter {
  late final DateFilterType type;
  Duration? duration;
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// a list of start dates, use this to filter transactions
  final List<DateTime> _startDates = [];

  List<DateTime> get startDates => _startDates;


  /// the index to locate initial page to show, will be 50
  final int initialPageIndex = 50;

  /// for all time, year, and month
  DateFilter.fromType(this.type) {
    if (type == DateFilterType.week) {
      duration = Duration(days: 7);
    } else if (type == DateFilterType.day || type == DateFilterType.range) {
      duration = Duration(days: 1);
    }
    _initDates();
  }

  /// for week, day,
  DateFilter.fromDuration(this.type, this.duration) {
    _initDates();
  }

  /// for selected range
  DateFilter.fromSelectedRange(this.startDate, this.duration) {
    type = DateFilterType.range;
    _initDates();
  }

  /// for selected date
  DateFilter.fromSelectedDate(this.startDate) {
    duration = Duration(days: 1);
    type = DateFilterType.day;
    _initDates();
  }

  /// initializes starting dates based on the type of date filter
  _initDates() {
    switch(type) {
      case DateFilterType.all:
        _startDates.add(DateTime(1975));
        for (int i = 0; i < 50; i++) {
          _startDates.add(DateTime(2100));
          _startDates.insert(0, DateTime(1975));
        }
      case DateFilterType.year:
        startDate = DateTime(startDate.year);
        _startDates.add(startDate);
        DateTime fw = startDate.copyWith(year: startDate.year + 1);
        DateTime bw = startDate.copyWith(year: startDate.year - 1);
        for (int i = 0; i < 50; i++) {
          _startDates.add(fw);
          _startDates.insert(0, bw);
          fw = fw.copyWith(year: fw.year + 1);
          bw = bw.copyWith(year: bw.year - 1);
        }
      case DateFilterType.month:
        startDate = DateTime(startDate.year, startDate.month);
        _startDates.add(startDate);
        DateTime fw = startDate.copyWith(month: startDate.month + 1);
        DateTime bw = startDate.copyWith(month: startDate.month - 1);
        for (int i = 0; i < 50; i++) {
          _startDates.add(fw);
          _startDates.insert(0, bw);
          fw = fw.copyWith(month: fw.month + 1);
          bw = bw.copyWith(month: bw.month - 1);
        }
      case DateFilterType.week:
        duration ??= Duration(days: 7);
        startDate= startDate.subtract(Duration(days: startDate.weekday));
        _startDates.add(startDate);
        DateTime fw = startDate.add(duration!);
        DateTime bw = startDate.subtract(duration!);
        for (int i = 0; i < 50; i++) {
          _startDates.add(fw);
          _startDates.insert(0, bw);
          fw = fw.add(duration!);
          bw = bw.subtract(duration!);
        }
      default:
        if (duration == null) {
          return;
        }
        _startDates.add(startDate);
        DateTime fw = startDate.add(duration!);
        DateTime bw = startDate.subtract(duration!);
        for (int i = 0; i < 50; i++) {
          _startDates.add(fw);
          _startDates.insert(0, bw);
          fw = fw.add(duration!);
          bw = bw.subtract(duration!);
        }
    }
    _startDates.add(DateTime(2100));
  }

  /// convert map from database to DateFilter
  factory DateFilter.fromMap(Map<String, dynamic> map) {
    if (map['duration'] == null) {
      return DateFilter.fromType(DateFilter.toDateFilterType(map['type']));
    }
    return DateFilter.fromDuration(DateFilter.toDateFilterType(map['type']) ,Duration(days: map['duration']));
  }

  /// convert string to DateFilterType
  static DateFilterType toDateFilterType(String label) {
    switch(label) {
      case('all'):
        return DateFilterType.all;
      case('year'):
        return DateFilterType.year;
      case('month'):
        return DateFilterType.month;
      case('week'):
        return DateFilterType.week;
      case('day'):
        return DateFilterType.day;
      case('range'):
        return DateFilterType.range;
      default:
        return DateFilterType.month;
    }
  }

  /// convert DateFilter to map for database
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'duration': duration?.inDays,
    };
  }

  /// convert DateFilter to string for display
  String convertString(int index) {
    if (type == DateFilterType.all) {
      return 'ALL TIME';
    }
    if (index < 0 || index > _startDates.length - 1) {
      return '';
    }
    switch(type) {
      case DateFilterType.year:
        return 'YEAR ${_startDates[index].year.toString()}';
      case DateFilterType.month:
        return formatDate(_startDates[index], [M.toUpperCase(), ' ', yyyy]);
      case DateFilterType.day:
        return formatDate(_startDates[index], [d, ' ', M.toUpperCase(), ' ', yyyy]);
      default:
        if (_startDates[index].month == _startDates[index + 1].month) {
          return '${_startDates[index].day} - ${formatDate(_startDates[index+1].subtract(Duration(days: 1)), [d, ' ', M.toUpperCase(), ' ', yyyy])}';
        }
        return '${formatDate(_startDates[index], [d, ' ', M.toUpperCase()])} '
            '- ${formatDate(_startDates[index+1].subtract(Duration(days: 1)), [d, ' ', M.toUpperCase(), ' ', yyyy])}';
    }
  }
}