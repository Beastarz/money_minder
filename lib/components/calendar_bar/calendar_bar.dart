import 'package:flutter/material.dart';
import 'package:money_minder/components/calendar_bar/period_bottom_sheet.dart';
import 'package:money_minder/components/calendar_bar/period_tile.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'calendar_selector_helper.dart';

/// an app bar that can show the selected period of time
class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool tappable;
  final String selectedDate;
  final VoidCallback onDateTap;

  const CalendarAppBar({
    super.key,
    required this.tappable,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70); // Adjust height as needed

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// go previous
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.keyboard_double_arrow_left_rounded,
              ),
            ),

            /// button to select different period options
            MaterialButton(

              /// show bottom sheet once it is pressed
              onPressed: () {
                if (!tappable) {
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  backgroundColor: AppColor.secondary,
                  builder: (context) {
                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.80,
                      builder: (context, ScrollController scrollController) =>
                        SingleChildScrollView(
                          controller: scrollController,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: PeriodBottomSheet(
                              title: 'Period',
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
                                    label: 'Today',
                                    selected: '23 May',
                                    icon: Icons.today,
                                    onPressed: () {}
                                ),

                                /// set current week
                                PeriodTile(
                                    parentContext: context,
                                    label: 'Week',
                                    selected: '23 May - 29 May',
                                    icon: Icons.calendar_view_week,
                                    onPressed: () {}
                                ),

                                /// set current month
                                PeriodTile(
                                    parentContext: context,
                                    label: 'Month',
                                    selected: 'May 2025',
                                    icon: Icons.calendar_month,
                                    onPressed: () {}
                                ),

                                /// set current year
                                PeriodTile(
                                    parentContext: context,
                                    label: 'Year',
                                    selected: '2025',
                                    icon: Icons.calendar_today,
                                    onPressed: () {}
                                ),
                              ],
                            )
                          ),
                        ),
                    );
                  },
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
                    'Thu, 15 May 2025',
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
              onPressed: () {},
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