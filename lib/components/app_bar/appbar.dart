import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/pages/accounts/add_accounts_page.dart';
import 'package:money_minder/utils/balance_text.dart';

import '../../style/app_color.dart';
import 'accounts_filter.dart';

class MMAppBar extends StatelessWidget implements PreferredSizeWidget{
  const MMAppBar( {super.key,
    required this.selectedIndex,
    required this.filteredAccounts,
    required this.mainCurrency,
    required this.onReload,
  });

  final int selectedIndex;
  final List<Account> filteredAccounts;
  final void Function() onReload;
  final Currency mainCurrency;

  @override
  Widget build(BuildContext context) {
    List<int> selectedAccountId = filteredAccounts.map((account) => account.id).toList();

    final functionButtons = <IconButton>[
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
      IconButton(
        icon: Icon(
          Icons.edit,
          color: Colors.grey[800],
        ),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(
          Icons.search,
          color: Colors.grey[800],
        ),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(
          Icons.edit,
          color: Colors.grey[800],
        ),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(
          Icons.location_on_outlined,
          color: Colors.grey[800],
        ),
        onPressed: () {},
      ),
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
                fontSize: 15,
              )
            ),
            BalanceText(
              balance: Account.getBalance(filteredAccounts, mainCurrency),
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
            Icons.public,
            color: Colors.grey[800],
          ),
          onPressed: () {
            // TODO: Add online space functionality
          },
        )
      ]
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
