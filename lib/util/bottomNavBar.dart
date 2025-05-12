import "package:flutter/material.dart";
import "package:google_nav_bar/google_nav_bar.dart";

import "../pages/account.dart";
import "../pages/categories.dart";
import "../pages/overview.dart";
import "../pages/sharedAccount.dart";
import "../pages/transactions.dart";

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {

  int _selectedIndex = 0;
  final List<Widget> pages = [
    const SharedAccount(),
    const Account(),
    const Categories(),
    const Transactions(),
    const Overview(),
  ];

  void _onTabChange (int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: GNav(
          selectedIndex: _selectedIndex,
          onTabChange: _onTabChange,
          color: Colors.grey[400],
          activeColor: Colors.grey.shade700,
          tabBackgroundColor: Colors.grey.shade100,
          tabActiveBorder: Border.all(color: Colors.white),
          mainAxisAlignment: MainAxisAlignment.center,
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
                text: 'Overview'
            ),
          ]

      )
    );
  }
}
