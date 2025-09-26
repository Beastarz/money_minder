import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/components/calendar_bar/calendar_selector_helper.dart';
import 'package:money_minder/models/date_filter.dart';

void main() {
  group('CalendarSelectorHelper.getIcon', () {
    test('returns correct icons for each DateFilterType', () {
      expect(CalendarSelectorHelper.getIcon(DateFilterType.all), Icons.all_inclusive);
      expect(CalendarSelectorHelper.getIcon(DateFilterType.year), Icons.calendar_today);
      expect(CalendarSelectorHelper.getIcon(DateFilterType.month), Icons.calendar_month);
      expect(CalendarSelectorHelper.getIcon(DateFilterType.week), Icons.calendar_view_week);
      expect(CalendarSelectorHelper.getIcon(DateFilterType.day), Icons.date_range);
      expect(CalendarSelectorHelper.getIcon(DateFilterType.range), Icons.edit_calendar);
    });
  });

  group('CalendarSelectorHelper UI', () {
    testWidgets('selectDate shows date picker and calls callback', (WidgetTester tester) async {
      late DateTime selectedDate;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CalendarSelectorHelper.selectDate(context, (date) {
                  selectedDate = date;
                });
              },
              child: const Text('Pick Date'),
            );
          },
        ),
      ));

      await tester.tap(find.text('Pick Date'));
      await tester.pumpAndSettle(); // showDatePicker appears

      // Simulate user selecting today's date and confirming
      await tester.tap(find.text('${DateTime.now().day}')); // tap on current day
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(selectedDate.day, DateTime.now().day);
    });

    testWidgets('showCustomDateRangePicker calls callback with correct range', (WidgetTester tester) async {
      late DateTime startDate;
      late Duration duration;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CalendarSelectorHelper.showCustomDateRangePicker(context, (start, dur) {
                  startDate = start;
                  duration = dur;
                });
              },
              child: const Text('Pick Range'),
            );
          },
        ),
      ));

      await tester.tap(find.text('Pick Range'));
      await tester.pumpAndSettle(); // showDateRangePicker appears

      // Select today as start and end date
      await tester.tap(find.text('${DateTime.now().day}').first);
      await tester.tap(find.text('${DateTime.now().add(const Duration(days: 1)).day}').first);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(startDate.day, DateTime.now().day);
      expect(duration.inDays, 2); // inclusive of both start and end
    });
  });
}
