import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'account_tile.dart';

class AccountsFilter extends StatefulWidget {
  final List<int> selectedAccounts;
  final void Function() onReload;

  const AccountsFilter({super.key, required this.selectedAccounts, required this.onReload});

  @override
  State<AccountsFilter> createState() => _AccountsFilterState();
}

class _AccountsFilterState extends State<AccountsFilter> {
  List<Account> accounts = [];

  @override
  void initState() {
    fetchAccounts();
    super.initState();
  }

  Future<void> fetchAccounts() async {
    List<Account> res = await AccountsRepository.instance.getAllAccounts();
    setState(() {
      accounts = res;
    });
  }

  void _handleSelect(int accountId, bool isSelected) {
    if (isSelected) {
      if (!widget.selectedAccounts.contains(accountId)) {
        widget.selectedAccounts.add(accountId);
      }
    } else {
      widget.selectedAccounts.remove(accountId);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<AccountType> accountTypes = AccountType.values;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColor.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                  IconButton(
                      onPressed: () {
                        () async {
                          await AccountsRepository.instance
                              .updateSelectedAccount(widget.selectedAccounts);
                          widget.onReload();
                        }();
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppSize.smallPadding),
                    child: Text(
                      'Accounts Filter',
                      style: TextStyle(
                          color: AppColor.darkText,
                          fontSize: AppSize.heading1,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            children:  accountTypes.map((accountType) {
              return accounts.where((acc) => acc.type == accountType).isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 8, 0),
                    child: Text(
                      accountType.name[0].toUpperCase() + accountType.name.substring(1),
                      style: TextStyle(
                        fontSize: AppSize.heading2,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey[700],
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.5,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    children: accounts.where((acc) => acc.type == accountType).map((account) {
                      return AccountTile(
                        account: account,
                        onSelect: (isSelected) {
                          _handleSelect(account.id, isSelected);
                        },
                      );
                    }).toList(),
                  ),
                ],
              )
                  : Container();
            }).toList(),
          ),
        ),
      ],
    );
  }
}
