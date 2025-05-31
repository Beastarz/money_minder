import 'package:flutter/material.dart';
import 'package:money_minder/components/app_bar/appbar.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/date_filter.dart';

import 'package:money_minder/pages/accounts/main_accounts_page.dart';
import 'package:money_minder/pages/main_pages/budget_page.dart';
import 'package:money_minder/pages/main_pages/categories_page.dart';
import 'package:money_minder/pages/main_pages/statistics_page.dart';
import 'package:money_minder/pages/main_pages/transactions_page.dart';
import 'package:money_minder/components/bottom_nav_bar/bottom_navbar.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/budget_repositories.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:money_minder/repositories/date_filter_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';
import 'package:money_minder/style/app_themes.dart';

import 'components/app_bar/appbar_drawer.dart';
import 'models/budget.dart';
import 'models/category.dart';
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
  List<List<Category>> _categories = [];
  Currency _mainCurrency = Currency.of('sgd');
  DateFilter _dateFilter = DateFilter.fromType(DateFilterType.month);
  int _currentPageIndex = 50;
  final DateFilter _budgetDateFilter = DateFilter.fromType(DateFilterType.month);
  int _budgetCurrentPageIndex = 50;
  List<Budget> _budgets = [];

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
    _fetchMainCurrency();
    _fetchTransactions();
    _fetchDateFilter();
    _fetchCategories();
    _fetchBudgets();
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

  Future<void> _fetchCategories() async {
    List<Category> expenseCat =
      await CategoriesRepositories.instance.getCategoriesByType(true);
    List<Category> incomeCat =
      await CategoriesRepositories.instance.getCategoriesByType(false);
    setState(() {
      _categories = [expenseCat, incomeCat];
    });
  }

  Future<void> _fetchDateFilter() async {
    DateFilter res = await DateFilterRepositories.instance.getDateFilter();
    setState(() {
      _dateFilter = res;
      _currentPageIndex = res.initialPageIndex;
    });
  }

  Future<void> _fetchBudgets() async {
    List<Budget> res = await BudgetRepositories.instance.getBudgets();
    setState(() {
      _budgets = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Account> filteredAccounts = _accounts.where((account) => account.isIncludesInTotal).toList();
    List<int> filteredAccountIds = filteredAccounts.map((e) => e.id).toList();
    List<Transaction> filteredTransactions = _transactions.where((t) => filteredAccountIds.contains(t.fromAccount.id)
        || filteredAccountIds.contains(t.toAccount?.id)).toList();

    final List<Widget> pages = [
      AccountsPage(
          accounts: _accounts,
          mainCurrency: _mainCurrency,
          onReload: _fetchAccounts,
      ),
      CategoriesPage(
        filteredTransactions: filteredTransactions,
        mainCurrency: _mainCurrency,
        dateFilter: _dateFilter,
        onDateFilterUpdate: _onDateFilterChange,
        currentPageIndex: _currentPageIndex,
        onPageChange: _onPageChange,
        categories: _categories,
        budgets: _budgets,
      ),
      TransactionsPage(
        filteredAccountBalance: Account.getBalance(filteredAccounts, _mainCurrency),
        mainCurrency: _mainCurrency,
        filteredTransactions: filteredTransactions,
        dateFilter: _dateFilter,
        onDateFilterUpdate: _onDateFilterChange,
        currentPageIndex: _currentPageIndex,
        onPageChange: _onPageChange,
      ),
      BudgetPage(
        mainCurrency: _mainCurrency,
        filteredTransactions: filteredTransactions,
        dateFilter: _budgetDateFilter,
        onDateFilterUpdate: _onDateFilterChange,
        currentPageIndex: _budgetCurrentPageIndex,
        onPageChange: _onBudgetPageChange,
        categories: _categories,
        accounts: _accounts,
        budgets: _budgets,
      ),
      StatisticsPage(
        mainCurrency: _mainCurrency,
        filteredTransactions: filteredTransactions,
        budgets: _budgets,
        dateFilter: _dateFilter,
        onDateFilterUpdate: _onDateFilterChange,
        currentPageIndex: _currentPageIndex,
        onPageChange: _onPageChange,
      ),
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

  void _onDateFilterChange(DateFilter dateFilter) {
    setState(() {
      _dateFilter = dateFilter;
      _currentPageIndex = dateFilter.initialPageIndex;
    });
  }

  void _onPageChange(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _onBudgetPageChange(int index) {
    setState(() {
      _budgetCurrentPageIndex = index;
    });
  }
}

