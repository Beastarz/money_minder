import 'package:flutter/material.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../../style/app_size.dart';

// use this to construct the topContent of the calculator sheet
class TopCard extends StatelessWidget {

  /// variable
  final String title; // title of the card
  final String header; // content of the card
  final Color backgroundColor; // background color of the card
  final Icon icon; // icon of the card
  final bool topRight; // whether to curve topRight corner
  final bool topLeft; // whether to curve topLeft corner
  final void Function()? onPressed; // callback function when the button is pressed

  const TopCard({
    super.key,
    required this.title,
    required this.header,
    required this.backgroundColor,
    required this.onPressed,
    this.icon = const Icon(Icons.add),
    this.topRight = false,
    this.topLeft = false,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppSize.borderRadius),
        ),
      ),
      // splashColor: AppColor.tertiary,
      // highlightColor: AppColor.tertiary,
      color: backgroundColor,
      child: Container(
        padding: EdgeInsets.all(8.0),
        width: MediaQuery.of(context).size.width * 0.48,
        child: Stack(
          children: [
            Positioned(
              top: 5,
              right: 5,
              child: MainIcon(icon: icon, color: backgroundColor, size: AppSize.smallIcon,)
            ),
            Container(
              padding: EdgeInsets.all(AppSize.bigPadding),
              decoration: BoxDecoration(
                  color : Colors.transparent,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSize.borderRadius),
                    topRight: Radius.circular(AppSize.borderRadius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      header,
                    style: TextStyle(
                      fontSize: AppSize.paragraph,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppSize.heading1 * 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
