import 'package:flutter/material.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/utils/balance_text.dart';

import '../../models/account.dart';
import '../../repositories/currency_repositories.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'accounts_filter.dart';

class MMAppBar extends StatefulWidget implements PreferredSizeWidget{
  const MMAppBar( {super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<MMAppBar> createState() => _MMAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MMAppBarState extends State<MMAppBar> {
  AccountsRepository accountsApi = AccountsRepository();
  CurrencyRepositories currencyApi = CurrencyRepositories();

  double balance = 0;
  List<int> selectedAccounts = [];
  Currency mainCurrency = Currency.of('sgd');

  @override
  void initState() {
    super.initState();
    _loadSelectedAccountBalance();
    _getMainCurrency();
  }

  @override
  void dispose() {
    super.dispose();
    accountsApi.close();
    currencyApi.close();
  }

  void _getMainCurrency() async {
    try {
      Currency res = await currencyApi.getMainCurrency();
      setState(() {
        mainCurrency = res;
      });
    } catch (e) {
      setState(() {
        mainCurrency = Currency.of('sgd');
      });
    }
  }

  Future<void> _loadSelectedAccountBalance() async {
    try {
      double res = await accountsApi.getSelectedAccountBalance();
      setState(() {
        balance = res;
      });
    } catch (e) {
      print(e);
      setState(() {
        balance = 0;
      });
    }
  }

  Future<void> _handleSelect(List<int> selectedAccount) async {
    try {
      List<Account> res = await accountsApi.getAllAccounts();
      for (Account account in res) {
        if (selectedAccount.contains(account.id)) {
          account = account.copyWith(isIncludesInTotal: true);
        } else {
          account = account.copyWith(isIncludesInTotal: false);
        }
        await accountsApi.updateAccount(account);
      }
      _loadSelectedAccountBalance();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final functionButtons = <IconButton>[
      IconButton(
        icon: Icon(
          Icons.add,
          color: Colors.grey[800],
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/add_account');

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
              balance: balance,
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
            backgroundColor: AppColor.primary,
            context: context,
            builder: (BuildContext context) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.18,
                        ),
                        Center(
                          child: Text(
                            'Accounts Filter',
                            style: TextStyle(
                                color: AppColor.lightText,
                                fontSize: AppSize.heading1,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _handleSelect(selectedAccounts);
                            });
                            selectedAccounts = [];
                            Navigator.pop(context);
                          },
                          color: AppColor.secondary,
                          icon: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: AppColor.lightText,
                                ),
                                const SizedBox(width: 5,),
                                Text(
                                    'Apply',
                                    style: TextStyle(
                                      color: AppColor.lightText,
                                    )
                                ),
                              ]
                          )
                        ),
                      ]
                    ),
                  ),
                  Expanded(
                    child: DraggableScrollableSheet(
                      expand: true,
                      initialChildSize: 1,
                      minChildSize: 0.2,
                      builder: (BuildContext context, ScrollController scrollController) {
                        return AccountsFilter(selectedAccounts: selectedAccounts);
                      }
                    ),
                  ),
                ],
              );
            }
          );
        }
      ),
      centerTitle: true,
      actions: [
        functionButtons[widget.selectedIndex],
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
}
