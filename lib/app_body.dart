
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/pages/accounts/main_accounts_page.dart';
import 'package:money_minder/pages/loading_screen.dart';
import 'package:money_minder/pages/main_pages/categories_page.dart';
import 'package:money_minder/pages/main_pages/statistics_page.dart';
import 'package:money_minder/pages/main_pages/transactions_page.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/budget_repositories.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:money_minder/repositories/date_filter_repositories.dart';
import 'package:money_minder/repositories/recurrence_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';

import 'components/app_bar/appbar.dart';
import 'components/app_bar/appbar_drawer.dart';
import 'components/bottom_nav_bar/bottom_navbar.dart';
import 'models/account.dart';
import 'models/budget.dart';
import 'models/category.dart';
import 'models/currency.dart';
import 'models/date_filter.dart';
import 'models/recurrence.dart';
import 'models/transaction.dart';
import 'models/transaction_filter.dart';

class AppBody extends StatefulWidget {
  const AppBody({super.key, required this.user, this.username});

  final User? user;
  final String? username;

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {

  int _tabIndex = 2;

  List<Account> _accounts = [];
  List<Account> _filteredAccounts = [];

  List<List<Recurrence>> _groupedRecurrence = [];
  List<List<Transaction>> _groupedTransactions = [];
  List<List<Category>> _categories = [];

  Currency _mainCurrency = Currency.of('sgd');

  DateFilter _dateFilter = DateFilter.fromType(DateFilterType.month);

  List<List<Budget>> _groupedBudgets = [];

  TransactionFilter _transactionFilter = TransactionFilter.empty();

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
      _tabIndex = index;
    });
  }

  void _showAccountTransactions(int id) {
    setState(() {
      _transactionFilter = TransactionFilter(accountIds: [id], categoryIds: [], transactionTypes: [], notePrefix: '');
      _tabIndex = 2;
    });
  }

  void _showCategoryTransactions(int id) {
    setState(() {
      _transactionFilter = TransactionFilter(accountIds: [], categoryIds: [id], transactionTypes: [], notePrefix: '');
      _tabIndex = 2;
    });
  }

  void _clearTransactionFilter() {
    setState(() {
      _transactionFilter = TransactionFilter.empty();
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
        _transactionFilter = TransactionFilter.empty();
        return;
      }
      _transactionFilter = TransactionFilter(
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
      return LoadingScreen();
    }

    final List<Widget> pages = [
      AccountsPage(
        accounts: _accounts,
        mainCurrency: _mainCurrency,
        onShowAccountTransactions: _showAccountTransactions,
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
          showCategoryTransactions: _showCategoryTransactions,
          categories: _categories,
          groupedBudgets: _groupedBudgets,
          onTransactionReload: () async {
            await _fetchRecurrence();
            await _fetchAccounts();
            await _fetchTransactions();
          },
          onBudgetReload: () async {
            await _fetchBudgets();
          },
          onCategoryReload: () async {
            await _fetchCategories();
          }
      ),
      TransactionsPage(
        filteredAccountBalance: Account.calculateBalance(_filteredAccounts, _mainCurrency),
        mainCurrency: _mainCurrency,
        groupedTransactions: _groupedTransactions.map((t) => _transactionFilter.filterTransactions(t)).toList(),
        groupedRecurrence:  _groupedRecurrence.map((t) => List.castFrom<Transaction, Recurrence>(_transactionFilter.filterTransactions(t))).toList(),
        isInFiltered: !_transactionFilter.isOff,
        dateFilter: _dateFilter,
        onDateFilterUpdate: _onDateFilterChange,
        currentPageIndex: _currentPageIndex,
        onPageChange: _onPageChange,
        clearTransactionFilter: _clearTransactionFilter,
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
          showCategoryTransactions: _showCategoryTransactions,
          currentPageIndex: _currentPageIndex,
          onPageChange: _onPageChange,
          onTransactionReload: () async {
            await _fetchRecurrence();
            _fetchAccounts();
            _fetchTransactions();
          },
          onBudgetReload: () async {
            await _fetchBudgets();
          }
      ),
    ];


    return Scaffold(
        appBar: MMAppBar(
          selectedIndex: _tabIndex,
          filteredAccounts: _filteredAccounts,
          onReload: _fetchAccounts,
          mainCurrency: _mainCurrency,
          transactionFilter: _transactionFilter,
          onTransactionFilterChange: _onTransactionFilterChange,
        ),
        drawer: AppbarDrawer(user: widget.user, username: widget.username,),
        body: pages[_tabIndex],
        bottomNavigationBar: BottomNavbar(
          onTabChange: _onTabChange,
          selectedIndex: _tabIndex,
        )
    );
  }
}
