import 'package:flutter/material.dart';

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

  const PeriodTile({
    super.key,
    required this.parentContext,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.height = 0,
    this.width = 0,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: height == 0 ? MediaQuery.of(parentContext).size.width * 0.30 : height,
      minWidth: width == 0 ? MediaQuery.of(parentContext).size.width * 0.42 : width,
      padding: EdgeInsets.all(AppSize.smallPadding),
      color: isSelected ? AppColor.tertiary : AppColor.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.borderRadius),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: AppSize.heading2
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
