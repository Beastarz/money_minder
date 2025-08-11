import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../style/app_size.dart';

/// bottom sheet that will appear when the user taps on the calendar icon
class PeriodBottomSheet extends StatefulWidget {
  final List<Widget> children;
  final String title;

  const PeriodBottomSheet({super.key, required this.children, required this.title});

  @override
  State<PeriodBottomSheet> createState() => _PeriodBottomSheetState();
}

class _PeriodBottomSheetState extends State<PeriodBottomSheet> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSize.bigPadding.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: TextStyle(
                fontSize: AppSize.heading1.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.r,
            runSpacing: 12.r,
            children: widget.children,
          ),
        ],
      ),
    );
  }
}
