import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class PeriodTile extends StatelessWidget {

  final BuildContext parentContext;
  final String label;
  final IconData icon;
  final void Function()? onPressed;
  final double height;
  final double width;

  const PeriodTile({
    super.key,
    required this.parentContext,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.height = 0,
    this.width = 0,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: height == 0 ? MediaQuery.of(parentContext).size.width * 0.30 : height,
      minWidth: width == 0 ? MediaQuery.of(parentContext).size.width * 0.42 : width,
      padding: EdgeInsets.all(AppSize.smallPadding),
      color: AppColor.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.borderRadius),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColor.lightIcon, size: AppSize.bigIcon),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                color: AppColor.lightText,
                fontSize: AppSize.heading2
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );;
  }
}
