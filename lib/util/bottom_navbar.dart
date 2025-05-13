import "package:flutter/material.dart";
import "package:google_nav_bar/google_nav_bar.dart";

class BottomNavbar extends StatelessWidget {
  final void Function(int)? onTabChange;
  const BottomNavbar({
    super.key,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: GNav(
          onTabChange: onTabChange,
          color: Colors.grey[400],
          activeColor: Colors.grey.shade700,
          tabBackgroundColor: Colors.grey.shade100,
          tabActiveBorder: Border.all(color: Colors.white),
          mainAxisAlignment: MainAxisAlignment.center,
          tabBorderRadius: 20,
          tabs: const [
            GButton(
                icon: Icons.account_balance_wallet_outlined,
                text: 'Account'
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
                text: 'Overview'
            ),
          ]

      )
    );
  }
}
