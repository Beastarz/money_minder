import 'package:flutter/material.dart';
import 'package:money_minder/components/app_bar/appbar.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';

import 'package:money_minder/pages/accounts/main_accounts_page.dart';
import 'package:money_minder/pages/main_pages/budget_page.dart';
import 'package:money_minder/pages/main_pages/categories_page.dart';
import 'package:money_minder/pages/main_pages/statistics_page.dart';
import 'package:money_minder/pages/main_pages/transactions_page.dart';
import 'package:money_minder/components/bottom_nav_bar/bottom_navbar.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';
import 'package:money_minder/style/app_themes.dart';

import 'components/app_bar/appbar_drawer.dart';
import 'models/transaction.dart';


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
      home: SafeArea(
        top: false,
        left: false,
        right: false,
        child: MoneyMinderFrame()
      ),
    );
  }
}

class MoneyMinderFrame extends StatefulWidget {
  const MoneyMinderFrame({super.key});

  @override
  State<MoneyMinderFrame> createState() => _MoneyMinderFrameState();
}

class _MoneyMinderFrameState extends State<MoneyMinderFrame> {
  int _selectedIndex = 2;
  List<Account> _accounts = [];
  List<Transaction> _transactions = [];
  Currency _mainCurrency = Currency.of('sgd');

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
    _fetchMainCurrency();
    _fetchTransactions();
  }

  Future<void> _fetchAccounts() async {
    List<Account> res = await AccountsRepository.instance.getAllAccounts();
    setState(() {
      _accounts = res;
    });
  }

  Future<void> _fetchMainCurrency() async {
    Currency res = await CurrencyRepositories.instance.getMainCurrency();
    setState(() {
      _mainCurrency = res;
    });
  }

  Future<void> _fetchTransactions() async {
    List<Transaction> res = await TransactionsRepositories.instance.getTransactions();
    setState(() {
      _transactions = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Account> filteredAccounts = _accounts.where((account) => account.isIncludesInTotal).toList();

    final List<Widget> pages = [
      AccountsPage(
          accounts: _accounts,
          mainCurrency: _mainCurrency,
          onReload: _fetchAccounts,
      ),
      const CategoriesPage(),
      TransactionsPage(
        filteredAccountIds: filteredAccounts.map((e) => e.id).toList(),
        filteredAccountBalance: Account.getBalance(filteredAccounts, _mainCurrency),
        mainCurrency: _mainCurrency,
        transactions: _transactions,
      ),
      const BudgetPage(),
      const StatisticsPage(),
    ];

    return Scaffold(
      appBar: MMAppBar(
        selectedIndex: _selectedIndex,
        filteredAccounts: filteredAccounts,
        onReload: _fetchAccounts,
        mainCurrency: _mainCurrency,
      ),
      drawer: AppbarDrawer(),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavbar(
        onTabChange: _onTabChange,
        selectedIndex: _selectedIndex,
      )
    );
  }

  void _onTabChange (int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

