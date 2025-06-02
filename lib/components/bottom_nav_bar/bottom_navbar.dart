import "package:flutter/material.dart";
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: GNav(
          onTabChange: onTabChange,
          selectedIndex: selectedIndex,
          color: Colors.grey[400],
          activeColor: AppColor.darkText,
          tabBackgroundColor: AppColor.secondary,
          tabActiveBorder: Border.all(color: AppColor.primary),
          mainAxisAlignment: MainAxisAlignment.center,
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: 15
          ),
          tabBorderRadius: 20,
          tabs: const [
            GButton(
                icon: Icons.account_balance_wallet_outlined,
                text: 'Accounts'
            ),
            GButton(
                icon: Icons.category_outlined,
                text: 'Categories'
            ),
            GButton(
                icon: Icons.list_alt_outlined,
                text: 'Transactions'
            ),
            GButton(
                icon: Icons.bar_chart_outlined,
                text: 'Statistics'
            ),
          ]
      )
    );
  }
}
