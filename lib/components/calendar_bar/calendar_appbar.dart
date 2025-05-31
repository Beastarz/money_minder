import 'package:flutter/material.dart';
import 'package:money_minder/components/calendar_bar/period_bottom_sheet.dart';
import 'package:money_minder/models/date_filter.dart';
import 'package:money_minder/components/calendar_bar/period_tile.dart';

import '../../repositories/date_filter_repositories.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'calendar_selector_helper.dart';

/// an app bar that can show the selected period of time
class CalendarAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TabController tabController;
  final int currentPageIndex;
  final void Function(int) onUpdateCurrentPageIndex;
  final String dateString;
  final int maxIndex;
  final DateFilterType dateFilterType;
  final void Function(DateFilter) onUpdateDateFilter;
  final bool disabled;

  const CalendarAppBar({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.onUpdateDateFilter,
    required this.dateString,
    required this.maxIndex,
    required this.dateFilterType,
    this.disabled = false,
  });

  @override
  State<CalendarAppBar> createState() => _CalendarAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CalendarAppBarState extends State<CalendarAppBar> {
  DateFilterType selectedFilter = DateFilterType.month;

  @override
  void initState() {
    super.initState();
  }

  // Adjust height as needed
  @override
  Widget build(BuildContext context) {
    bool isTappable = widget.dateFilterType != DateFilterType.all;
    DateFilterType selectedFilter = widget.dateFilterType;

    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// go previous
              IconButton(
                onPressed: () {
                  if (!isTappable) {
                    return;
                  }
                  if (widget.currentPageIndex == 0) {
                    return;
                  }
                  widget.onUpdateCurrentPageIndex(widget.currentPageIndex - 1);
                },
                icon: Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                ),
              ),

              /// button to select different period options
              MaterialButton(

                /// show bottom sheet once it is pressed
                onPressed: () {

                  if (widget.disabled) {
                    return;
                  }

                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      backgroundColor: AppColor.secondary,
                      builder: (context) {
                        return SafeArea(
                          child: SingleChildScrollView(
                            child: SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: PeriodBottomSheet(
                                  title: 'Choose period',
                                  children: [

                                    /// set the period between any two date
                                    PeriodTile(
                                        parentContext: context,
                                        label: 'Select range',
                                        icon: Icons.edit_calendar,
                                        onPressed: () {
                                          CalendarSelectorHelper.showCustomDateRangePicker(
                                              context, (startDate, duration) {
                                            () async {
                                              await DateFilterRepositories.instance.updateDateFilter(
                                                  DateFilter.fromSelectedRange(startDate, duration));
                                              widget.onUpdateDateFilter(DateFilter.fromSelectedRange(startDate, duration));
                                            }();
                                            Navigator.pop(context);
                                          });
                                        },
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.84 + 12,
                                        isSelected: selectedFilter ==
                                            DateFilterType.range
                                    ),

                                    /// select any date
                                    PeriodTile(
                                      parentContext: context,
                                      label: 'Select day',
                                      icon: Icons.date_range,
                                      onPressed: () {
                                        CalendarSelectorHelper.selectDate(
                                            context, (date) {
                                          () async {
                                            await DateFilterRepositories.instance.updateDateFilter(
                                                DateFilter.fromSelectedDate(date));

                                            widget.onUpdateDateFilter(DateFilter.fromSelectedDate(date));
                                          }();
                                          Navigator.pop(context);
                                        });
                                      },
                                      isSelected: false,
                                    ),

                                    /// from the first day of using the app until now
                                    PeriodTile(
                                      parentContext: context,
                                      label: 'All time',
                                      icon: Icons.all_inclusive,
                                      onPressed: () {
                                        setState(() {
                                          selectedFilter = DateFilterType.all;
                                        });
                                        () async {
                                          await DateFilterRepositories.instance.updateDateFilter(
                                              DateFilter.fromType(DateFilterType.all));
                                          widget.onUpdateDateFilter(DateFilter.fromType(DateFilterType.all));
                                        }();
                                        Navigator.pop(context);
                                      },
                                      isSelected: selectedFilter ==
                                          DateFilterType.all,

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
                                        () async {
                                          await DateFilterRepositories.instance.updateDateFilter(
                                              DateFilter.fromDuration(DateFilterType.day, Duration(days: 1)));
                                          widget.onUpdateDateFilter(DateFilter.fromDuration(DateFilterType.day, Duration(days: 1)));
                                        }();
                                        Navigator.pop(context);
                                      },
                                      isSelected: selectedFilter ==
                                          DateFilterType.day,
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
                                        () async {
                                          await DateFilterRepositories.instance.updateDateFilter(
                                              DateFilter.fromDuration(DateFilterType.week, Duration(days: 7)));
                                          widget.onUpdateDateFilter(DateFilter.fromDuration(DateFilterType.week, Duration(days: 7)));
                                        }();
                                        Navigator.pop(context);
                                      },

                                      isSelected: selectedFilter ==
                                          DateFilterType.week,
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
                                        () async {
                                          await DateFilterRepositories.instance.updateDateFilter(
                                              DateFilter.fromType(DateFilterType.month));
                                          widget.onUpdateDateFilter(DateFilter.fromType(DateFilterType.month));
                                        }();
                                        Navigator.pop(context);
                                      },
                                      isSelected: selectedFilter ==
                                          DateFilterType.month,
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
                                        () async {
                                          await DateFilterRepositories.instance.updateDateFilter(
                                              DateFilter.fromType(DateFilterType.year));
                                          widget.onUpdateDateFilter( DateFilter.fromType(DateFilterType.year));
                                        }();
                                        Navigator.pop(context);
                                      },
                                      isSelected: selectedFilter ==
                                          DateFilterType.year,
                                    ),
                                  ],
                                )
                            ),
                          ),
                        );
                      }
                  );
                },
                height: 50,
                color: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.borderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColor.darkIcon,
                      size: AppSize.smallIcon,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.dateString,
                      style: TextStyle(
                        color: AppColor.darkText,
                        fontSize: AppSize.heading3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColor.darkIcon,
                      size: 20,
                    ),
                  ],
                ),
              ),

              /// go next
              IconButton(
                onPressed: () {
                  if (!isTappable) {
                    return;
                  }
                  if (widget.currentPageIndex == widget.maxIndex) {
                    return;
                  }
                  widget.onUpdateCurrentPageIndex(widget.currentPageIndex + 1);
                },
                icon: Icon(
                  Icons.keyboard_double_arrow_right_rounded,
                ),
              ),
            ]
        ),
      ),
    );
  }
}