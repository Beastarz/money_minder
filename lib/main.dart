import 'package:flutter/material.dart';
import 'package:money_minder/components/app_bar/appbar.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/date_filter.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/models/transaction_filter.dart';

import 'package:money_minder/pages/accounts/main_accounts_page.dart';
import 'package:money_minder/pages/main_pages/categories_page.dart';
import 'package:money_minder/pages/main_pages/statistics_page.dart';
import 'package:money_minder/pages/main_pages/transactions_page.dart';
import 'package:money_minder/components/bottom_nav_bar/bottom_navbar.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/budget_repositories.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:money_minder/repositories/date_filter_repositories.dart';
import 'package:money_minder/repositories/recurrence_repositories.dart';
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
  List<Account> _filteredAccounts = [];

  List<List<Recurrence>> _groupedRecurrence = [];
  List<List<Transaction>> _groupedTransactions = [];
  List<List<Category>> _categories = [];

  Currency _mainCurrency = Currency.of('sgd');

  DateFilter _dateFilter = DateFilter.fromType(DateFilterType.month);

  List<List<Budget>> _groupedBudgets = [];

  TransactionFilter transactionFilter = TransactionFilter.empty();

  int _currentPageIndex = 50;

  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadAllInitialData();
  }

  Future<void> _loadAllInitialData() async {
    // Set loading to true
    setState(() {
      _isLoadingData = true;
    });

    // Await all fetch operations
    await _fetchDateFilter(); // Date filter is often needed first for transactions/budgets
    await _fetchAccounts();
    await _fetchMainCurrency();
    await _fetchRecurrence();
    await _fetchTransactions(); // Depends on _filteredAccounts and _dateFilter
    await _fetchCategories();
    await _fetchBudgets(); // Depends on _dateFilter

    // After all fetches complete, set loading to false
    setState(() {
      _isLoadingData = false;
    });
  }

  Future<void> _fetchAccounts() async {
    List<Account> res = await AccountsRepository.instance.getAllAccounts();
    setState(() {
      _accounts = res;
      _filteredAccounts = _accounts.where((account) => account.isIncludesInTotal).toList();
    });
  }

  Future<void> _fetchMainCurrency() async {
    Currency res = await CurrencyRepositories.instance.getMainCurrency();
    setState(() {
      _mainCurrency = res;
    });
  }

  Future<void> _fetchRecurrence() async {
    List<Recurrence> res = await RecurrenceRepositories.instance.getAndCheckRecurrences();
    setState(() {
      List<int> filteredAccountIds = _filteredAccounts.map((e) => e.id).toList();
      List<Recurrence> filteredRecurrences = res.where((r) => filteredAccountIds.contains(r.fromAccount.id)).toList();
      List<List<Transaction>> tmp  = Transaction.groupTransactionsByDate(filteredRecurrences, _dateFilter.startDates);
      _groupedRecurrence = tmp.map((ts) => List.castFrom<Transaction, Recurrence>(ts)).toList();
    });
  }

  Future<void> _fetchTransactions() async {
    List<Transaction> res = await TransactionsRepositories.instance.getTransactions();
    setState(() {
      List<int> filteredAccountIds = _filteredAccounts.map((e) => e.id).toList();
      List<Transaction> filteredTransactions = res.where((t) => filteredAccountIds.contains(t.fromAccount.id)
          || filteredAccountIds.contains(t.toAccount?.id)).toList();
      List<List<Transaction>> tmp  = Transaction.groupTransactionsByDate(filteredTransactions, _dateFilter.startDates);
      _groupedTransactions = tmp;
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
      _groupedBudgets = Budget.groupBudgetsByDate(res, _dateFilter);
    });
  }

  void _onTabChange (int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDateFilterChange(DateFilter dateFilter) async {
    setState(() {
      _dateFilter = dateFilter;
      _currentPageIndex = dateFilter.initialPageIndex;
    });
    await _fetchRecurrence();
    _fetchTransactions();
    _fetchBudgets();

  }

  void _onTransactionFilterChange(
      List<int> selectedAccountIds,
      List<int> selectedCategoryIds,
      List<TransactionType> selectedTransactionTypes,
      String notePrefix) {
    setState(() {
      if (selectedAccountIds.isEmpty && selectedCategoryIds.isEmpty && selectedTransactionTypes.isEmpty && notePrefix.isEmpty) {
        transactionFilter = TransactionFilter.empty();
        return;
      }
      transactionFilter = TransactionFilter(
        accountIds: selectedAccountIds,
        categoryIds: selectedCategoryIds,
        transactionTypes: selectedTransactionTypes,
        notePrefix: notePrefix,
      );
    });
  }

  void _onPageChange(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {


    // Show a loading indicator while data is being fetched
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> pages = [
      AccountsPage(
          accounts: _accounts,
          mainCurrency: _mainCurrency,
          onReload: () async {
            await _fetchRecurrence();
            _fetchAccounts();
            _fetchTransactions();
          },
      ),
      CategoriesPage(
        groupedTransactions: _groupedTransactions,
        mainCurrency: _mainCurrency,
        dateFilter: _dateFilter,
        onDateFilterUpdate: _onDateFilterChange,
        currentPageIndex: _currentPageIndex,
        onPageChange: _onPageChange,
        categories: _categories,
        groupedBudgets: _groupedBudgets,
        onAddTransactionReload: () async {
          await _fetchRecurrence();
          _fetchAccounts();
          _fetchTransactions();
        },
        onBudgetReload: () {
          _fetchBudgets();
        },
        onCategoryReload: () {
          _fetchCategories();
          _fetchTransactions();
        }
      ),
      TransactionsPage(
        filteredAccountBalance: Account.calculateBalance(_filteredAccounts, _mainCurrency),
        mainCurrency: _mainCurrency,
        groupedTransactions: _groupedTransactions.map((t) => transactionFilter.filterTransactions(t)).toList(),
        groupedRecurrence:  _groupedRecurrence.map((t) => List.castFrom<Transaction, Recurrence>(transactionFilter.filterTransactions(t))).toList(),
        isInFiltered: !transactionFilter.isOff,
        dateFilter: _dateFilter,
        onDateFilterUpdate: _onDateFilterChange,
        currentPageIndex: _currentPageIndex,
        onPageChange: _onPageChange,
        onTransactionReload: () async {
          await _fetchRecurrence();
          _fetchAccounts();
          _fetchTransactions();
        },
      ),
      StatisticsPage(
        mainCurrency: _mainCurrency,
        groupedTransactions: _groupedTransactions,
        categories: _categories,
        groupedBudgets: _groupedBudgets,
        dateFilter: _dateFilter,
        onDateFilterUpdate: _onDateFilterChange,
        currentPageIndex: _currentPageIndex,
        onPageChange: _onPageChange,
        onAddTransactionReload: () {
          _fetchAccounts();
          _fetchTransactions();
        },
        onBudgetReload: () {
          _fetchBudgets();
        }
      ),
    ];


    return Scaffold(
      appBar: MMAppBar(
        selectedIndex: _selectedIndex,
        filteredAccounts: _filteredAccounts,
        onReload: _fetchAccounts,
        mainCurrency: _mainCurrency,
        transactionFilter: transactionFilter,
        onTransactionFilterChange: _onTransactionFilterChange,
      ),
      drawer: AppbarDrawer(),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavbar(
        onTabChange: _onTabChange,
        selectedIndex: _selectedIndex,
      )
    );
  }
}

