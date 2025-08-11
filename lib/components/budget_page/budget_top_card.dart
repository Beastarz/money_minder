import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

// use this to construct the topContent of the calculator sheet
class BudgetTopCard extends StatelessWidget {

  /// variable
  final double width; // width of the card
  final Widget title; // title of the card
  final Widget content; // content of the card
  final Color backgroundColor; // background color of the card
  final Icon icon; // icon of the card
  final bool topRight; // whether to curve topRight corner
  final bool topLeft; // whether to curve topLeft corner
  final bool isTappable;
  final void Function()? onPressed; // callback function when the button is pressed

  const BudgetTopCard({
    super.key,
    required this.width,
    required this.title,
    required this.content,
    required this.backgroundColor,
    required this.onPressed,
    this.isTappable = true,
    this.icon = const Icon(Icons.add),
    this.topRight = false,
    this.topLeft = false,
  });

  @override
  Widget build(BuildContext context) {

    Widget buttonContent = SizedBox(
        width: 40.w,
        height: 40.h,
        child: icon
    );

    return MaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeft ? AppSize.borderRadius.r : 0),
          topRight: Radius.circular(topRight ? AppSize.borderRadius.r : 0),
        ),
      ),
      color: backgroundColor,
      disabledColor: backgroundColor,
      disabledTextColor: AppColor.lightText,
      child: Stack(
          children: [
            Container(
              width: width,
              decoration: BoxDecoration(
                color : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(topLeft ? AppSize.borderRadius : 0),
                  topRight: Radius.circular(topRight ? AppSize.borderRadius : 0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppSize.smallPadding.sp),
                    child: title,
                  ),
                  content,
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: buttonContent,
            ),
          ]
      ),
    );
  }
}