import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/components/account/account_selection_sheet.dart';

import '../models/account.dart';
import '../style/app_color.dart';
import '../style/app_size.dart';

// use this to construct the topContent of the calculator sheet
class AccountTopCard extends StatelessWidget {

  /// variable
  final double width; // width of the card
  final Account initialAccount; // initial category
  final bool topRight; // whether to curve topRight corner
  final bool topLeft; // whether to curve topLeft corner
  final bool isTappable;
  final void Function(Account) onPressed; // callback function when the button is pressed

  const AccountTopCard({
    super.key,
    required this.width,
    required this.initialAccount,
    required this.onPressed,
    this.isTappable = true,
    this.topRight = false,
    this.topLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    Account account = initialAccount;

    Widget buttonContent = SizedBox(
        width: 40.w,
        height: 40.h,
        child: Icon(account.icon.icon, size: AppSize.bigIcon.sp,)
    );

    return MaterialButton(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeft ? AppSize.borderRadius : 0),
          topRight: Radius.circular(topRight ? AppSize.borderRadius : 0),
        ),
      ),
      color: account.color,
      disabledColor: account.color,
      disabledTextColor: AppColor.lightText,
      onPressed: !isTappable ? null : () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColor.secondary,
          builder: (context) {
            return AccountSelectionSheet(
                onSelect: onPressed
            );
          }
      ),
      child: Stack(
          children: [
            Container(
              width: width,
              decoration: BoxDecoration(
                color : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(topLeft ? AppSize.borderRadius.r : 0),
                  topRight: Radius.circular(topRight ? AppSize.borderRadius.r : 0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppSize.smallPadding.r),
                    child: Text(
                        '${topLeft ? "From" : "To"} Account',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: AppSize.heading3.sp,
                        )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSize.smallPadding.w,
                      right: AppSize.smallPadding.w,
                      bottom: AppSize.smallPadding.h,
                    ),
                    child: Text(
                        account.name,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: (AppSize.heading1 * 1.15).sp,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        )
                    ),
                  ),
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
