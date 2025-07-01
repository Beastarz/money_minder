import 'package:flutter_test/flutter_test.dart';
import 'package:date_format/date_format.dart';
import 'package:money_minder/models/date_filter.dart';

void main() {
  group('DateFilter', () {
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    test('DateFilter.fromType - DateFilterType.all', () {
      final filter = DateFilter.fromType(DateFilterType.all);
      expect(filter.type, DateFilterType.all);
      expect(filter.duration, null);
      expect(filter.startDates.length, greaterThan(0));
      expect(filter.startDates.first, DateTime(1975));
      expect(filter.convertString(0), 'ALL TIME');
      expect(filter.initialPageIndex, 50);
    });

    test('DateFilter.fromType - DateFilterType.year', () {
      final filter = DateFilter.fromType(DateFilterType.year);
      expect(filter.type, DateFilterType.year);
      expect(filter.duration, null);
      expect(filter.startDates.length, greaterThan(0));
      expect(filter.startDates.contains(DateTime(today.year)), isTrue);
      expect(filter.convertString(filter.initialPageIndex), 'YEAR ${today.year}');
      expect(filter.startDates.first.year, lessThan(today.year));
      expect(filter.startDates.last.year, greaterThan(today.year));
    });

    test('DateFilter.fromType - DateFilterType.month', () {
      final filter = DateFilter.fromType(DateFilterType.month);
      expect(filter.type, DateFilterType.month);
      expect(filter.duration, null);
      expect(filter.startDates.length, greaterThan(0));
      expect(filter.startDates.contains(DateTime(today.year, today.month)), isTrue);
      expect(filter.convertString(filter.initialPageIndex), formatDate(DateTime(today.year, today.month), [M, ' ', yyyy]));
      expect(filter.startDates.first.month, isNot(today.month));
      expect(filter.startDates.last.month, isNot(today.month));
    });

    test('DateFilter.fromType - DateFilterType.week', () {
      final filter = DateFilter.fromType(DateFilterType.week);
      expect(filter.type, DateFilterType.week);
      expect(filter.duration, Duration(days: 7));
      expect(filter.startDates.length, greaterThan(0));

      DateTime startOfWeek = today.subtract(Duration(days: today.weekday));
      expect(filter.startDates.contains(startOfWeek), isTrue);

    });

    test('DateFilter.fromDuration - DateFilterType.day', () {
      final filter = DateFilter.fromDuration(DateFilterType.day, Duration(days: 1));
      expect(filter.type, DateFilterType.day);
      expect(filter.duration, Duration(days: 1));
      expect(filter.startDates.length, greaterThan(0));
      expect(filter.startDates.contains(today), isTrue);
      expect(filter.convertString(filter.initialPageIndex), formatDate(today, [d, ' ', M, ' ',yyyy]));
    });

    test('DateFilter.fromSelectedRange', () {
      DateTime customStartDate = DateTime(2025, 10, 15);
      Duration customDuration = Duration(days: 30);
      final filter = DateFilter.fromSelectedRange(customStartDate, customDuration);

      expect(filter.type, DateFilterType.range);
      expect(filter.duration, customDuration);
      expect(filter.startDate, customStartDate);
      expect(filter.startDates.first, customStartDate.subtract(customDuration * 50));
      expect(filter.startDates[filter.initialPageIndex + 50], customStartDate.add(customDuration * 50));

      expect(filter.convertString(filter.initialPageIndex), '15 Oct - 13 Nov 2025');
    });

    test('DateFilter.fromSelectedDate', () {
      DateTime customDate = DateTime(2024, 5, 20);
      final filter = DateFilter.fromSelectedDate(customDate);

      expect(filter.type, DateFilterType.day);
      expect(filter.duration, Duration(days: 1));
      expect(filter.startDate, customDate);
      expect(filter.startDates.first, customDate.subtract(Duration(days: 50)));
      expect(filter.startDates[filter.initialPageIndex + 50], customDate.add(Duration(days: 50)));
      expect(filter.convertString(filter.initialPageIndex), '20 May 2024');
    });

    group('DateFilter.fromMap and toMap', () {
      test('should convert DateFilterType.month to map and back', () {
        final originalFilter = DateFilter.fromType(DateFilterType.month);
        final map = originalFilter.toMap();
        expect(map['type'], 'month');
        expect(map['duration'], null);

        final newFilter = DateFilter.fromMap(map);
        expect(newFilter.type, DateFilterType.month);
        expect(newFilter.duration, null);
      });

      test('should convert DateFilterType.week to map and back', () {
        final originalFilter = DateFilter.fromType(DateFilterType.week);
        final map = originalFilter.toMap();
        expect(map['type'], 'week');
        expect(map['duration'], 7);

        final newFilter = DateFilter.fromMap(map);
        expect(newFilter.type, DateFilterType.week);
        expect(newFilter.duration, Duration(days: 7));
      });

      test('should convert DateFilterType.day to map and back', () {
        final originalFilter = DateFilter.fromDuration(DateFilterType.day, Duration(days: 1));
        final map = originalFilter.toMap();
        expect(map['type'], 'day');
        expect(map['duration'], 1);

        final newFilter = DateFilter.fromMap(map);
        expect(newFilter.type, DateFilterType.day);
        expect(newFilter.duration, Duration(days: 1));
      });
    });

    group('toDateFilterType', () {
      test('should convert string "all" to DateFilterType.all', () {
        expect(DateFilter.toDateFilterType('all'), DateFilterType.all);
      });
      test('should convert string "year" to DateFilterType.year', () {
        expect(DateFilter.toDateFilterType('year'), DateFilterType.year);
      });
      test('should convert string "month" to DateFilterType.month', () {
        expect(DateFilter.toDateFilterType('month'), DateFilterType.month);
      });
      test('should convert string "week" to DateFilterType.week', () {
        expect(DateFilter.toDateFilterType('week'), DateFilterType.week);
      });
      test('should convert string "day" to DateFilterType.day', () {
        expect(DateFilter.toDateFilterType('day'), DateFilterType.day);
      });
      test('should convert string "range" to DateFilterType.range', () {
        expect(DateFilter.toDateFilterType('range'), DateFilterType.range);
      });
      test('should return DateFilterType.month for unknown string', () {
        expect(DateFilter.toDateFilterType('unknown'), DateFilterType.month);
      });
    });

    group('convertString', () {
      test('should return "ALL TIME" for DateFilterType.all', () {
        final filter = DateFilter.fromType(DateFilterType.all);
        expect(filter.convertString(0), 'ALL TIME');
      });

      test('should format year correctly', () {
        final filter = DateFilter.fromType(DateFilterType.year);
        int index = filter.initialPageIndex;
        expect(filter.convertString(index), 'YEAR ${DateTime.now().year}');
      });

      test('should format month correctly', () {
        final filter = DateFilter.fromType(DateFilterType.month);
        int index = filter.initialPageIndex;
        expect(filter.convertString(index), formatDate(DateTime(DateTime.now().year, DateTime.now().month), [M.toUpperCase(), ' ',yyyy]));
      });

      test('should format day correctly', () {
        final filter = DateFilter.fromType(DateFilterType.day);
        int index = filter.initialPageIndex;
        expect(filter.convertString(index), formatDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day), [d, ' ', M.toUpperCase(), ' ',yyyy]));
      });

      test('should format selected day correctly', () {
        final filter = DateFilter.fromSelectedDate(DateTime(2025, 6, 15));
        expect(filter.convertString(filter.initialPageIndex), '15 Jun 2025');
      });

      test('should format week/range correctly when months are the same', () {
        final filter = DateFilter.fromSelectedRange(DateTime(2025, 6, 15), Duration(days: 7));
        int index = filter.initialPageIndex;
        String expected = '15 - 21 Jun 2025';
        expect(filter.convertString(index), expected);
      });

      test('should format week/range correctly when months are different', () {
        DateTime startOfCrossMonthRange = DateTime(2025, 2, 28); // February 28, 2025 (Friday)
        final filter = DateFilter.fromSelectedRange(startOfCrossMonthRange, Duration(days: 7)); // Goes into March
        int index = filter.initialPageIndex;
        String expected = '28 Feb - 6 Mar 2025';
        expect(filter.convertString(index), expected);
      });

      test('should return empty string for out of bounds index', () {
        final filter = DateFilter.fromType(DateFilterType.month);
        expect(filter.convertString(-1), '');
        expect(filter.convertString(filter.startDates.length), '');
      });
    });

    group('_initDates logic', () {
      test('DateFilterType.all should add DateTime(1975) and DateTime(2100) multiple times', () {
        final filter = DateFilter.fromType(DateFilterType.all);
        expect(filter.startDates.first, DateTime(1975));
        expect(filter.startDates.last, DateTime(2100)); // The last added is always DateTime(2100) due to the final add
        expect(filter.startDates.length, 102);
      });

      test('DateFilterType.year should generate years correctly centered around current year', () {
        final filter = DateFilter.fromType(DateFilterType.year);
        expect(filter.startDates.contains(DateTime(today.year)), isTrue);
        expect(filter.startDates[filter.initialPageIndex], DateTime(today.year));
        expect(filter.startDates.map((t) => t.day).toSet().length, 1); // should have same date
        expect(filter.startDates.map((t) => t.month).toSet().length, 1); // should have same date
      });

      test('DateFilterType.month should generate months correctly centered around current month', () {
        final filter = DateFilter.fromType(DateFilterType.month);
        expect(filter.startDates.contains(DateTime(today.year, today.month)), isTrue);
        expect(filter.startDates[filter.initialPageIndex], DateTime(today.year, today.month));
        expect(filter.startDates.map((t) => t.day).toSet().length, 1); // should have same date
      });

      test('DateFilterType.week should generate weeks correctly', () {
        final filter = DateFilter.fromType(DateFilterType.week);
        expect(filter.startDates.contains(today.subtract(Duration(days: today.weekday))), isTrue);
        expect(filter.startDates[50].weekday, 7); // starts from Sunday
      });
    });
  });
}