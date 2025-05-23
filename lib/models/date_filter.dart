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
  DateTime startDate = DateTime(DateTime.now().toLocal().year, DateTime.now().toLocal().month, DateTime.now().toLocal().day);
  DateTime? endDate;
  List<DateTime> dates = [];
  int initialPageIndex = 0;

  // for all time, year, and month
  DateFilter.fromType(this.type) {
    _initDates();
  }

  // for week, day, range
  DateFilter.fromDuration(this.type, this.duration) {
    _initDates();
  }

  // for selected range or date
  DateFilter.fromSelectedRange(this.startDate, this.duration) {
    type = DateFilterType.range;
    _initDates();
  }

  DateFilter.fromSelectedDate(this.startDate) {
    this.duration = Duration(days: 1);
    type = DateFilterType.day;
    _initDates();
  }

  _initDates() {
    switch(type) {
      case DateFilterType.all:
        dates.add(DateTime(2000));
      case DateFilterType.year:
        dates.add(DateTime(startDate.year));
        DateTime fw = startDate.copyWith(year: startDate.year + 1);
        DateTime bw = startDate.copyWith(year: startDate.year - 1);
        for (int i = startDate.year - 1; i >= 2000; i--) {
          dates.add(fw);
          dates.insert(0, bw);
          fw = fw.copyWith(year: fw.year + 1);
          bw = bw.copyWith(year: bw.year - 1);
        }
      case DateFilterType.month:
        dates.add(DateTime(startDate.year, startDate.month ));
        DateTime fw = startDate.copyWith(month: startDate.month + 1);
        DateTime bw = startDate.copyWith(month: startDate.month - 1);
        for (int i = 0; i < 50; i++) {
          dates.add(fw);
          dates.insert(0, bw);
          fw = fw.copyWith(month: fw.month + 1);
          bw = bw.copyWith(month: bw.month - 1);
        }
      case DateFilterType.week:
        if (duration == null) {
          return;
        }
        startDate= startDate.subtract(Duration(days: startDate.weekday));
        dates.add(startDate);
        DateTime fw = startDate.add(duration!);
        DateTime bw = startDate.subtract(duration!);
        for (int i = 0; i < 50; i++) {
          dates.add(fw);
          dates.insert(0, bw);
          fw = fw.add(duration!);
          bw = bw.subtract(duration!);
        }
      default:
        if (duration == null) {
          return;
        }
        dates.add(startDate);
        DateTime fw = startDate.add(duration!);
        DateTime bw = startDate.subtract(duration!);
        for (int i = 0; i < 50; i++) {
          dates.add(fw);
          dates.insert(0, bw);
          fw = fw.add(duration!);
          bw = bw.subtract(duration!);
        }
    }
    initialPageIndex = (dates.length / 2).floor();
    dates.add(DateTime(2100));
  }

  factory DateFilter.fromMap(Map<String, dynamic> map) {
    if (map['duration'] == null) {
      return DateFilter.fromType(DateFilter.toDateFilterType(map['type']));
    }
    return DateFilter.fromDuration(DateFilter.toDateFilterType(map['type']) ,Duration(days: map['duration']));
  }

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

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'duration': duration?.inDays,
    };
  }

  String convertString(int index) {
    if (index < 0 || index > dates.length - 1) {
      return '';
    }
    switch(type) {
      case DateFilterType.all:
        return 'All Time';
      case DateFilterType.year:
        return 'YEAR ${dates[index].year.toString()}';
      case DateFilterType.month:
        return formatDate(dates[index], [M.toUpperCase(), ' ', yyyy]);
      case DateFilterType.day:
        return formatDate(dates[index], [d, ' ', M.toUpperCase(), ' ', yyyy]);
      default:
        if (dates[index].month == dates[index + 1].month) {
          return '${dates[index].day} - ${formatDate(dates[index+1].subtract(Duration(days: 1)), [d, ' ', M.toUpperCase(), ' ', yyyy])}';
        }
        return '${formatDate(dates[index], [d, ' ', M.toUpperCase()])} '
            '- ${formatDate(dates[index+1].subtract(Duration(days: 1)), [d, ' ', M.toUpperCase(), ' ', yyyy])}';
    }
  }
}