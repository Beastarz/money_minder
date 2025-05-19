import 'package:flutter/material.dart';
import 'package:money_minder/components/calendar_bar/period_tile.dart';
import 'package:money_minder/components/calendar_bar/calendar_selector_helper.dart';

import '../../style/app_size.dart';

/// bottom sheet that will appear when the user taps on the calendar icon
class PeriodBottomSheet extends StatelessWidget {
  const PeriodBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSize.bigPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Period',
            style: TextStyle(
                fontSize: AppSize.heading1,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [

              /// set the period between any two date
              PeriodTile(
                  parentContext: context,
                  label: 'Select range',
                  icon: Icons.edit_calendar,
                  onPressed: () {
                    CalendarSelectorHelper.showCustomDateRangePicker(context);
                  },
                  width: MediaQuery.of(context).size.width * 0.84 + 12
              ),

              /// select any date
              PeriodTile(
                  parentContext: context,
                  label: 'Select day',
                  icon: Icons.date_range,
                  onPressed: () {
                    CalendarSelectorHelper.selectDate(context);
                  }
              ),

              /// from the first day of using the app until now
              PeriodTile(
                  parentContext:context,
                  label: 'All time',
                  icon: Icons.all_inclusive,
                  onPressed: () {}
              ),

              /// set today
              PeriodTile(
                  parentContext: context,
                  label: 'Today\n15 May',
                  icon: Icons.today,
                  onPressed: () {}
              ),

              /// set current week
              PeriodTile(
                  parentContext: context,
                  label: 'Week\n11 – 17 May',
                  icon: Icons.calendar_view_week,
                  onPressed: () {}
              ),

              /// set current month
              PeriodTile(
                  parentContext: context,
                  label: 'Month\nMay 2025',
                  icon: Icons.calendar_month,
                  onPressed: () {}
              ),

              /// set current year
              PeriodTile(
                  parentContext: context,
                  label: 'Year\n2025',
                  icon: Icons.calendar_today,
                  onPressed: () {}
              ),
            ],
          ),
        ],
      ),
    );
  }
}
