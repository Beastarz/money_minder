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
  final String? selected;

  const PeriodTile({
    super.key,
    required this.parentContext,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.selected,
    this.height = 0,
    this.width = 0,
  });

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return MaterialButton(
      onPressed: onPressed,
      height: height == 0 ? MediaQuery.of(parentContext).size.width * 0.25 : height,
      minWidth: width == 0 ? MediaQuery.of(parentContext).size.width * 0.42 : width,
      padding: EdgeInsets.all(AppSize.smallPadding),
      color: AppColor.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.borderRadius),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: isSmallScreen
              ? AppSize.smallIcon
              : AppSize.bigIcon
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: isSmallScreen
                  ? AppSize.heading3
                  : AppSize.heading2
            ),
            textAlign: TextAlign.center,
          ),
          selected == null
          ? const SizedBox.shrink()
          : Text(
            selected ?? '',
            style: TextStyle(
              fontSize: isSmallScreen
              ? AppSize.paragraph
              : AppSize.heading2,
              fontWeight: FontWeight.w200,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
