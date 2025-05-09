import 'package:flutter/material.dart';
import 'pages/accounts.dart';
import 'pages/categories.dart';
import 'pages/transactions.dart';
import 'pages/overview.dart';

void main() {
  runApp(const moneyMinder());
}

class moneyMinder extends StatelessWidget {
  const moneyMinder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const moneyMinderFrame(),
    );
  }
}

class moneyMinderFrame extends StatefulWidget {
  const moneyMinderFrame({super.key});

  @override
  State<moneyMinderFrame> createState() => _moneyMinderFrameState();
}

class _moneyMinderFrameState extends State<moneyMinderFrame> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyMinder'),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        indicatorColor: Colors.blue.shade100,
        selectedIndex: selectedIndex,
        destinations: <Widget>[
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Accounts'
          ),
          NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category),
              label: 'Categories'
          ),
          NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Transactions'
          ),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Overview'
          ),
        ]
      ),
      body: [Accounts(), Categories(), Transactions(), Overview()][selectedIndex]
    );
  }
}

