import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class BudgetHelper {

  static final Map<String, Color> colorMap = {
    "Expenses": Colors.redAccent,
    "Savings": Colors.orangeAccent,
    "Income": Colors.greenAccent,
  };

  // Function to lighten a color by mixing it with white
  static Color _lightenColor(Color color, double factor) {
    // factor: 0.0 means no white, 1.0 means pure white
    return Color.lerp(color, Colors.white, factor)!;
  }

  static Widget buildCatButton(
      void Function()? onPressed,
      String type,
      String currentType,
      double leftCurve,
      double rightCurve) {
    return Expanded(
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(AppSize.smallPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(AppSize.borderRadius * leftCurve),
                right: Radius.circular(AppSize.borderRadius * rightCurve),
              ),
            ),
            backgroundColor: currentType == type
                ? colorMap[type]
                : _lightenColor(colorMap[type]!, 0.9),
          ),
          child: Column(
              spacing: 5,
              children:[
                Text(
                  type,
                  style: TextStyle(
                      fontSize: AppSize.heading3,
                      color: currentType == type
                          ? AppColor.lightText
                          : AppColor.darkText
                  ),
                ),
                Text(
                  "\$100",
                  style: TextStyle(
                      fontSize: AppSize.heading2,
                      color: currentType == type
                          ? AppColor.lightText
                          : colorMap[type]
                  ),
                )
              ]
          )
      ),
    );
  }
}