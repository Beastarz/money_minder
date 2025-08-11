import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

/// the button that will appear in the period bottom sheet
class PeriodTile extends StatelessWidget {

  /// variables
  final BuildContext parentContext;
  final String label;
  final IconData icon;
  final void Function()? onPressed;
  final double height;
  final double width;
  final bool isSelected;
  final String? selected;

  const PeriodTile({
    super.key,
    required this.parentContext,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.height = 0,
    this.width = 0,
    this.isSelected = false,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {


    return MaterialButton(
      onPressed: onPressed,
      height: height == 0 ? MediaQuery.of(parentContext).size.width * 0.25 : height,
      minWidth: width == 0 ? MediaQuery.of(parentContext).size.width * 0.42 : width,
      padding: EdgeInsets.all(AppSize.smallPadding),
      color: isSelected ? AppColor.tertiary : AppColor.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.borderRadius.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: AppSize.bigIcon.sp
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSize.heading2.sp
            ),
            textAlign: TextAlign.center,
          ),
          selected == null
          ? const SizedBox.shrink()
          : Text(
            selected ?? '',
            style: TextStyle(
              fontSize: AppSize.heading2.sp,
              fontWeight: FontWeight.w200,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
