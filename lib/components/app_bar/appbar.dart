import 'package:flutter/material.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

import '../../models/account.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'accounts_filter.dart';

// TODO: Add appbar buttons functionality, account filter functionality
class MMAppBar extends StatefulWidget implements PreferredSizeWidget{
  const MMAppBar( {super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<MMAppBar> createState() => _MMAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MMAppBarState extends State<MMAppBar> {
  AccountsApi accountsApi = AccountsApi();

  double balance = 0;
  List<int> selectedAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedAccountBalance();
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
    try{
      List<Account> res = await accountsApi.getAllAccounts();
      for (Account account in res) {
        if (selectedAccount.contains(account.id)) {
          account.isIncludesInTotal = true;
        } else {
          account.isIncludesInTotal = false;
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
              'All Accounts',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
              )
            ),
            Text(
              balance.toStringAsFixed(2),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 21,
              )
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

final functionButtons = <IconButton>[
  IconButton(
    icon: Icon(
      Icons.add,
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