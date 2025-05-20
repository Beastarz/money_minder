import 'package:flutter/material.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/providers/account_provider.dart';
import 'package:money_minder/utils/balance_text.dart';
import 'package:provider/provider.dart';

import '../../providers/currency_provider.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<AccountProvider>().fetchSelectedAccountBalance();
    context.read<AccountProvider>().fetchAccounts();
    context.read<CurrencyProvider>().fetchMainCurrency();
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.select<AccountProvider, double>((provider) => provider.selectedAccountBalance);
    final mainCurrency = context.select<CurrencyProvider, Currency>((provider) => provider.mainCurrency);

    List<int> selectedAccounts = context.select<AccountProvider, List<int>>((provider) {
      return provider.accounts.where((account) => account.isIncludesInTotal).map((account) => account.id).toList();
    });

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
            backgroundColor: AppColor.secondary,
            context: context,
            builder: (BuildContext context) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.secondary,
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
                                color: AppColor.darkText,
                                fontSize: AppSize.heading1,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<AccountProvider>().updateSelectedAccount(selectedAccounts);
                            selectedAccounts = [];
                            Navigator.pop(context);
                          },
                          color: AppColor.secondary,
                          icon: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: AppColor.darkText,
                                ),
                                const SizedBox(width: 5,),
                                Text(
                                    'Apply',
                                    style: TextStyle(
                                      color: AppColor.darkText,
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
