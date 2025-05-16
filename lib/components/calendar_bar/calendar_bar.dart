import 'package:flutter/material.dart';
import 'package:money_minder/components/calendar_bar/period_bottom_sheet.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

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
  Size get preferredSize => const Size.fromHeight(120); // Adjust height as needed

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                  color: AppColor.darkIcon,
                  size: AppSize.bigIcon,
              ),
            ),
            MaterialButton(
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
                      builder: (context, ScrollController scrollController) =>
                          SingleChildScrollView(
                            controller: scrollController,
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: const PeriodBottomSheet()
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
                      color: AppColor.lightIcon,
                      size: AppSize.smallIcon,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Thu, 15 May 2025',
                    style: TextStyle(
                        color: AppColor.lightText,
                        fontSize: AppSize.heading3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColor.lightIcon,
                      size: 20,
                  ),
                ],
              ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                    Icons.keyboard_double_arrow_right_rounded,
                    color: AppColor.darkIcon,
                    size: AppSize.bigIcon,
                ),
              ),
            ]
          ),
      ),
      );
  }
}
