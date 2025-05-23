import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'calculator.dart';

class CalculatorSheet extends StatelessWidget {

  final Widget topContent; // the widget to display at the top of the sheet
  final Calculator calculator; // the calculator widget

  const CalculatorSheet({
    super.key,
    required this.topContent,
    required this.calculator,
  });

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return Container(
      height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.85 : 0.65),
      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSize.borderRadius)
        ),
      ),
      child: Column(
        children: [
          topContent,
          Container(
            padding: EdgeInsets.all(AppSize.bigPadding),
            child: calculator,
          )
        ],
      ),
    );
  }
}
