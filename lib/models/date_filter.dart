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
  late DateFilterType type;
  Duration? duration;
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// a list of start dates, use this to filter transactions
  List<DateTime> startDates = [];

  /// the index to locate initial page to show
  int initialPageIndex = 0;

  /// for all time, year, and month
  DateFilter.fromType(this.type) {
    _initDates();
  }

  /// for week, day, range
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
        startDates.add(DateTime(2000));
      case DateFilterType.year:
        startDate = DateTime(startDate.year);
        startDates.add(startDate);
        DateTime fw = startDate.copyWith(year: startDate.year + 1);
        DateTime bw = startDate.copyWith(year: startDate.year - 1);
        for (int i = 0; i < 50; i++) {
          startDates.add(fw);
          startDates.insert(0, bw);
          fw = fw.copyWith(year: fw.year + 1);
          bw = bw.copyWith(year: bw.year - 1);
        }
      case DateFilterType.month:
        startDate = DateTime(startDate.year, startDate.month);
        startDates.add(startDate);
        DateTime fw = startDate.copyWith(month: startDate.month + 1);
        DateTime bw = startDate.copyWith(month: startDate.month - 1);
        for (int i = 0; i < 50; i++) {
          startDates.add(fw);
          startDates.insert(0, bw);
          fw = fw.copyWith(month: fw.month + 1);
          bw = bw.copyWith(month: bw.month - 1);
        }
      case DateFilterType.week:
        if (duration == null) {
          return;
        }
        startDate= startDate.subtract(Duration(days: startDate.weekday));
        startDates.add(startDate);
        DateTime fw = startDate.add(duration!);
        DateTime bw = startDate.subtract(duration!);
        for (int i = 0; i < 50; i++) {
          startDates.add(fw);
          startDates.insert(0, bw);
          fw = fw.add(duration!);
          bw = bw.subtract(duration!);
        }
      default:
        if (duration == null) {
          return;
        }
        startDates.add(startDate);
        DateTime fw = startDate.add(duration!);
        DateTime bw = startDate.subtract(duration!);
        for (int i = 0; i < 50; i++) {
          startDates.add(fw);
          startDates.insert(0, bw);
          fw = fw.add(duration!);
          bw = bw.subtract(duration!);
        }
    }
    initialPageIndex = (startDates.length / 2).floor();
    startDates.add(DateTime(2100));
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
    if (index < 0 || index > startDates.length - 1) {
      return '';
    }
    switch(type) {
      case DateFilterType.all:
        return 'All Time';
      case DateFilterType.year:
        return 'YEAR ${startDates[index].year.toString()}';
      case DateFilterType.month:
        return formatDate(startDates[index], [M.toUpperCase(), ' ', yyyy]);
      case DateFilterType.day:
        return formatDate(startDates[index], [d, ' ', M.toUpperCase(), ' ', yyyy]);
      default:
        if (startDates[index].month == startDates[index + 1].month) {
          return '${startDates[index].day} - ${formatDate(startDates[index+1].subtract(Duration(days: 1)), [d, ' ', M.toUpperCase(), ' ', yyyy])}';
        }
        return '${formatDate(startDates[index], [d, ' ', M.toUpperCase()])} '
            '- ${formatDate(startDates[index+1].subtract(Duration(days: 1)), [d, ' ', M.toUpperCase(), ' ', yyyy])}';
    }
  }
}