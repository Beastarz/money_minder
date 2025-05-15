import 'package:flutter/material.dart';
import 'package:money_minder/components/calendar_bar/period_bottom_sheet.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool tapable;
  final String selectedDate;
  final VoidCallback onDateTap;

  const CalendarAppBar({
    super.key,
    required this.tapable,
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
              icon: const Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                  color: Colors.black,
                  size: 30,
              ),
            ),
            MaterialButton(
              onPressed: () {
                if (!tapable) {
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  backgroundColor: Color(0xFF1C1C1E),
                    // DraggableScrollableSheet(
                    //   expand: false, // allows it to take only needed height initially
                    //   builder: (context, scrollController) {
                    //     return SingleChildScrollView(
                    //       controller: scrollController, // link the scroll controller
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(16.0),
                    //         child: Column(
                    //           children: List.generate(30, (index) => ListTile(
                    //             title: Text('Item $index', style: const TextStyle(color: Colors.white)),
                    //           )),
                    //         ),
                    //       ),
                    //     );
// Dark background
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
              color: Color(0xFF2C2C2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Thu, 15 May 2025',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 20,
                  ),
                ],
              ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                    Icons.keyboard_double_arrow_right_rounded,
                    color: Colors.black,
                    size: 30,
                ),
              ),
            ]
          ),
      ),
      );
  }
}
