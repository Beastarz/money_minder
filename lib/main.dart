import 'package:flutter/material.dart';
import 'package:money_minder/pages/account.dart';
import 'package:money_minder/pages/categories.dart';
import 'package:money_minder/pages/overview.dart';
import 'package:money_minder/pages/transactions.dart';
import 'package:money_minder/util/bottom_navbar.dart';

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
    const Account(),
    const Categories(),
    const Transactions(),
    const Overview(),
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

