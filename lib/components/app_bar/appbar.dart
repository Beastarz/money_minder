import 'package:flutter/material.dart';
import 'package:money_minder/components/transaction/transaction_filter_page.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/online/user.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/pages/accounts/add_accounts_page.dart';
import 'package:money_minder/pages/online_pages/online_home_page.dart';
import 'package:money_minder/utils/balance_text.dart';

import '../../models/transaction_filter.dart';
import '../../style/app_color.dart';
import '../../utils/app_message.dart';
import 'accounts_filter.dart';

class MMAppBar extends StatelessWidget implements PreferredSizeWidget{
  const MMAppBar( {
    super.key,
    required this.userData,
    required this.selectedIndex,
    required this.filteredAccounts,
    required this.mainCurrency,
    required this.onReload,
    required this.transactionFilter,
    required this.onTransactionFilterChange,
    required this.accounts,
    required this.categories,
  });

  final User? userData;
  final int selectedIndex;
  final List<Account> filteredAccounts;
  final List<Account> accounts;
  final List<List<Category>> categories;
  final void Function() onReload;
  final Currency mainCurrency;
  final TransactionFilter transactionFilter;
  final void Function(List<int>, List<int>, List<TransactionType>, String) onTransactionFilterChange;

  @override
  Widget build(BuildContext context) {
    List<int> selectedAccountId = filteredAccounts.map((account) => account.id).toList();

    final functionButtons = <Widget>[
      IconButton(
        icon: Icon(
          Icons.add,
          color: Colors.grey[800],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAccountPage(onAddAccount: onReload)),
          );
        },
      ),
      Container(),
      IconButton(
        icon: Badge(
          isLabelVisible: !transactionFilter.isOff,
          label: Text(transactionFilter.count().toString()),
          child: Icon(
            Icons.filter_alt_outlined,
            color: Colors.grey[800],
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionFilterPage(
                onTransactionFilterChange: onTransactionFilterChange, filter: transactionFilter, accounts: accounts, categories: categories)),
          );
        },
      ),
      Container(),
    ];

    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.grey[800],
        ),
        onPressed: Scaffold.of(context).openDrawer,
      ),
      title: TextButton(
        child: Column(
          children: [
            Text(
              'My Accounts',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              )
            ),
            BalanceText(
              balance: Account.calculateBalance(filteredAccounts, mainCurrency),
              currencyName: mainCurrency.toString(),
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
        ),
        onPressed: () {
          showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: AppColor.secondary,
            context: context,
            builder: (BuildContext context) {
              return AccountsFilter(selectedAccounts: selectedAccountId, onReload: onReload,);
            }
          );
        }
      ),
      centerTitle: true,
      actions: [
        functionButtons[selectedIndex],
        IconButton(
          icon: Icon(
            Icons.people_alt_outlined,
            color: Colors.grey[800],
          ),
          onPressed: () {
            if (userData == null) {
              AppMessage.showMessage(context, 'Please Sign in');
              return;
            }
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OnlineHomePage(userdata: userData!, onReload: onReload,))
            );
          },
        )
      ]
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
