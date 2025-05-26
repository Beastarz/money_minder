import 'package:flutter/material.dart';

import '../../style/app_size.dart';
import '../categories_page/categories_page_helper.dart';

// use this to construct the topContent of the calculator sheet
class TopCard extends StatelessWidget {

  /// variable
  final double width; // width of the card
  final Widget title; // title of the card
  final Widget content; // content of the card
  final Color backgroundColor; // background color of the card
  final String iconPath; // path of the icon
  final bool topRight; // whether to curve topRight corner
  final bool topLeft; // whether to curve topLeft corner
  final void Function()? onPressed; // callback function when the button is pressed

  const TopCard({
    super.key,
    required this.width,
    required this.title,
    required this.content,
    required this.backgroundColor,
    required this.onPressed,
    this.iconPath = '',
    this.topRight = false,
    this.topLeft = false,
  });

  @override
  Widget build(BuildContext context) {

    Widget buttonIcon = CategoriesPageHelper.generateButtonIcon(iconPath);
    Widget buttonContent = SizedBox(
      width: 40,
      height: 40,
      child: buttonIcon
    );

    return MaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeft ? AppSize.borderRadius : 0),
          topRight: Radius.circular(topRight ? AppSize.borderRadius : 0),
        ),
      ),
      // splashColor: AppColor.tertiary,
      // highlightColor: AppColor.tertiary,
      color: backgroundColor,
      child: Stack(
        children: [
          Container(
            width: width,
            padding: EdgeInsets.all(AppSize.bigPadding),
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
                title,
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
