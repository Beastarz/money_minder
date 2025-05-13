import 'package:flutter/material.dart';
import 'package:money_minder/pages/accountsPage.dart';
import 'package:money_minder/pages/budgetPage.dart';
import 'package:money_minder/pages/categoriesPage.dart';
import 'package:money_minder/pages/statisticsPage.dart';
import 'package:money_minder/pages/transactionsPage.dart';
import 'package:money_minder/components/bottomNavBar.dart';

void main() {
  runApp(const moneyMinder());
}

class moneyMinder extends StatelessWidget {
  const moneyMinder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: moneyMinderFrame(),
    );
  }
}

class moneyMinderFrame extends StatefulWidget {
  const moneyMinderFrame({super.key});

  @override
  State<moneyMinderFrame> createState() => _moneyMinderFrameState();
}

class _moneyMinderFrameState extends State<moneyMinderFrame> {


  final List<Widget> _pages = [
    const AccountsPage(),
    const CategoriesPage(),
    const TransactionsPage(),
    const BudgetPage(),
    const statisticsPage(),
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
      appBar: AppBar(
        title: Text(
          "MoneyMinder",
        )
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavbar(
        onTabChange: _onTabChange,
      )
    );
  }
}

