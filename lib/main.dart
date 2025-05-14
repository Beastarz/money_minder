import 'package:flutter/material.dart';
import 'package:money_minder/components/appbar.dart';

import 'package:money_minder/pages/accounts_page.dart';
import 'package:money_minder/pages/budget_page.dart';
import 'package:money_minder/pages/categories_page.dart';
import 'package:money_minder/pages/statistics_page.dart';
import 'package:money_minder/pages/transactions_page.dart';
import 'package:money_minder/components/bottom_navbar.dart';

import 'components/appbar_drawer.dart';


void main() {
  runApp(const MoneyMinder());
}

class MoneyMinder extends StatelessWidget {
  const MoneyMinder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
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

