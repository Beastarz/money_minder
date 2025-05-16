import 'package:flutter/material.dart';
import 'package:money_minder/components/app_bar/appbar.dart';

import 'package:money_minder/pages/accounts_page.dart';
import 'package:money_minder/pages/budget_page.dart';
import 'package:money_minder/pages/categories_page.dart';
import 'package:money_minder/pages/statistics_page.dart';
import 'package:money_minder/pages/transactions_page.dart';
import 'package:money_minder/components/bottom_nav_bar/bottom_navbar.dart';
import 'package:money_minder/style/app_themes.dart';

import 'components/app_bar/appbar_drawer.dart';


void main() {
  runApp(const MoneyMinder());
}

class MoneyMinder extends StatelessWidget {
  const MoneyMinder({super.key});

  /// TODO: Toggle between dark mode and light mode
  final ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,   // Light theme config
      darkTheme: AppThemes.darkTheme, // Dark theme config
      themeMode: _themeMode,         // Current theme mode
      home: MoneyMinderFrame(),
    );
  }
}

class MoneyMinderFrame extends StatefulWidget {
  const MoneyMinderFrame({super.key});

  @override
  State<MoneyMinderFrame> createState() => _MoneyMinderFrameState();
}

class _MoneyMinderFrameState extends State<MoneyMinderFrame> {


  final List<Widget> _pages = [
    const AccountsPage(),
    const CategoriesPage(),
    const TransactionsPage(),
    const BudgetPage(),
    const StatisticsPage(),
  ];
  int _selectedIndex = 0;

  void _onTabChange (int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MMAppBar(selectedIndex: _selectedIndex,),
      drawer: AppbarDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavbar(
        onTabChange: _onTabChange,
      )
    );
  }
}

