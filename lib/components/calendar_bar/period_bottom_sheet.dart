import 'package:flutter/material.dart';
import 'package:money_minder/components/calendar_bar/period_tile.dart';
import 'package:money_minder/components/calendar_bar/calendar_selector_helper.dart';
import 'package:money_minder/models/date_filter.dart';
import 'package:money_minder/repositories/date_filter_repositories.dart';
import 'package:provider/provider.dart';

import '../../providers/date_filter_provider.dart';
import '../../style/app_size.dart';

/// bottom sheet that will appear when the user taps on the calendar icon
class PeriodBottomSheet extends StatefulWidget {
  final void Function(DateFilter) onUpdateDateFilter;
  final DateFilterType dateFilterType;

  const PeriodBottomSheet({super.key, required this.onUpdateDateFilter, required this.dateFilterType});

  @override
  State<PeriodBottomSheet> createState() => _PeriodBottomSheetState();
}

class _PeriodBottomSheetState extends State<PeriodBottomSheet> {
  late DateFilterType selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.dateFilterType;
  }

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
                    CalendarSelectorHelper.showCustomDateRangePicker(context, (startDate, duration) {
                        DateFilterRepositories().updateDateFilter(DateFilter.fromSelectedRange(startDate, duration));
                        widget.onUpdateDateFilter(DateFilter.fromSelectedRange(startDate, duration));
                        Navigator.pop(context);
                    });
                  },
                  width: MediaQuery.of(context).size.width * 0.84 + 12,
                  isSelected: selectedFilter == DateFilterType.range
              ),

              /// select any date
              PeriodTile(
                  parentContext: context,
                  label: 'Select day',
                  icon: Icons.date_range,
                  onPressed: () {
                    CalendarSelectorHelper.selectDate(context, (date) {
                      DateFilterRepositories().updateDateFilter(DateFilter.fromSelectedDate(date));
                      widget.onUpdateDateFilter(DateFilter.fromSelectedDate(date));
                      Navigator.pop(context);
                    });
                  },
                isSelected: false,
              ),

              /// from the first day of using the app until now
              PeriodTile(
                  parentContext:context,
                  label: 'All time',
                  icon: Icons.all_inclusive,
                  onPressed: () {
                    setState(() {
                      selectedFilter = DateFilterType.all;
                    });
                    DateFilterRepositories()
                        .updateDateFilter(DateFilter.fromType(DateFilterType.all));
                    widget.onUpdateDateFilter(DateFilter.fromType(DateFilterType.all));
                    Navigator.pop(context);
                  },
                  isSelected: selectedFilter == DateFilterType.all,

              ),

              /// set today
              PeriodTile(
                  parentContext: context,
                  label: 'Today',
                  icon: Icons.today,
                  onPressed: () {
                    setState(() {
                      selectedFilter = DateFilterType.day;
                    });
                    DateFilterRepositories()
                        .updateDateFilter(DateFilter.fromDuration(DateFilterType.day, Duration(days: 1)));
                    widget.onUpdateDateFilter(DateFilter.fromDuration(DateFilterType.day, Duration(days: 1)));
                    Navigator.pop(context);
                  },
                  isSelected: selectedFilter == DateFilterType.day,
              ),

              /// set current week
              PeriodTile(
                  parentContext: context,
                  label: 'Week',
                  icon: Icons.calendar_view_week,
                  onPressed: () {
                    setState(() {
                      selectedFilter = DateFilterType.week;
                    });
                    DateFilterRepositories()
                        .updateDateFilter(DateFilter.fromDuration(DateFilterType.week, Duration(days: 7)));
                    widget.onUpdateDateFilter(DateFilter.fromDuration(DateFilterType.week, Duration(days: 7)));
                    Navigator.pop(context);
                  },

                  isSelected: selectedFilter == DateFilterType.week,
              ),

              /// set current month
              PeriodTile(
                  parentContext: context,
                  label: 'Month',
                  icon: Icons.calendar_month,
                  onPressed: () {
                    setState(() {
                      selectedFilter = DateFilterType.month;
                    });
                    DateFilterRepositories()
                        .updateDateFilter(DateFilter.fromType(DateFilterType.month));
                    Navigator.pop(context);
                    widget.onUpdateDateFilter(DateFilter.fromType(DateFilterType.month));
                  },
                  isSelected: selectedFilter == DateFilterType.month,
              ),

              /// set current year
              PeriodTile(
                  parentContext: context,
                  label: 'Year',
                  icon: Icons.calendar_today,
                  onPressed: () {
                    setState(() {
                      selectedFilter = DateFilterType.year;
                    });
                    DateFilterRepositories()
                        .updateDateFilter(DateFilter.fromType(DateFilterType.year));
                    Navigator.pop(context);
                    widget.onUpdateDateFilter(DateFilter.fromType(DateFilterType.year));
                  },
                  isSelected: selectedFilter == DateFilterType.year,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
