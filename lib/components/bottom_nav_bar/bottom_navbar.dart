import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:google_nav_bar/google_nav_bar.dart";

import "../../style/app_color.dart";

/// bottom navigation bar that will appear at every pages
class BottomNavbar extends StatelessWidget {

  /// [onTabChange] is a callback function that will be called when the tab is changed
  final void Function(int)? onTabChange;
  final int selectedIndex;

  const BottomNavbar({
    super.key,
    required this.onTabChange,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.w),
      child: GNav(
          duration: Duration(milliseconds: 100),
          onTabChange: onTabChange,
          selectedIndex: selectedIndex,
          color: Colors.grey[400],
          activeColor: AppColor.darkText,
          tabBackgroundColor: AppColor.secondary,
          tabActiveBorder: Border.all(color: AppColor.primary),
          mainAxisAlignment: MainAxisAlignment.center,
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: 15.h
          ),
          tabBorderRadius: 20,
          tabs: [
            GButton(
              icon: Icons.account_balance_wallet_outlined,
              text: 'Accounts',
              textStyle: TextStyle(fontSize: 16.sp),
              iconSize: 32.sp,
            ),
            GButton(
              icon: Icons.category_outlined,
              text: 'Categories',
              textStyle: TextStyle(fontSize: 16.sp),
              iconSize: 32.sp,
            ),
            GButton(
              icon: Icons.list_alt_outlined,
              text: 'Transactions',
              textStyle: TextStyle(fontSize: 16.sp),
              iconSize: 32.sp,
            ),
            GButton(
              icon: Icons.bar_chart_outlined,
              text: 'Statistics',
              textStyle: TextStyle(fontSize: 16.sp),
              iconSize: 32.sp,
            ),
          ]
      )
    );
  }
}
