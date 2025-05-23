import 'package:flutter/material.dart';
import 'package:money_minder/components/calendar_bar/period_bottom_sheet.dart';
import 'package:money_minder/models/date_filter.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

/// an app bar that can show the selected period of time
class CalendarAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TabController tabController;
  final int currentPageIndex;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isTappable;
  final String dateString;
  final int maxIndex;
  final DateFilterType dateFilterType;

  const CalendarAppBar({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.dateString,
    required this.maxIndex,
    this.isTappable = true,
    required this.dateFilterType,
  });

  @override
  State<CalendarAppBar> createState() => _CalendarAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CalendarAppBarState extends State<CalendarAppBar> {

 // Adjust height as needed
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
                onPressed: () {
                  if (!widget.isTappable) {
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
                  if (!widget.isTappable) {
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
                                    onUpdateCurrentPageIndex: widget.onUpdateCurrentPageIndex,
                                    dateFilterType: widget.dateFilterType,
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
                  if (!widget.isTappable) {
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