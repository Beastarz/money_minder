import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class AccountsFilter extends StatefulWidget {
  final List<int> selectedAccounts;

  const AccountsFilter({super.key, required this.selectedAccounts});

  @override
  State<AccountsFilter> createState() => _AccountsFilterState();
}

class _AccountsFilterState extends State<AccountsFilter> {
  AccountsApi accountsApi = AccountsApi();

  List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    widget.selectedAccounts.clear();
    _loadAccounts();

  }

  Future<void> _loadAccounts() async {
    try {
      List<Account> res = await accountsApi.getAllAccounts();
      setState(() {
        accounts = res;
      });
      for (Account account in accounts) {
        if (account.isIncludesInTotal) {
          widget.selectedAccounts.add(account.id);
        }
      }
    } catch (e) {
      print(e);
      setState(() {
        accounts = [];
      });
    }
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
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2,
      padding: const EdgeInsets.all(10),
      children: accounts.map((account) {
              return AccountTile(
                account: account,
                onSelect: (isSelected) {
                  _handleSelect(account.id, isSelected);
                },
              );
            }).toList(),
    );
  }
}

class AccountTile extends StatefulWidget {
  final Account account;
  final Function onSelect;

  const AccountTile({super.key, required this.account, required this.onSelect});

  @override
  State<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile> {

  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.account.isIncludesInTotal;
  }

  void _handleTap() {
      setState(() {
        _isSelected = !_isSelected;
        widget.onSelect(_isSelected);
      });
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: InkWell(
        onTap: _handleTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.borderRadius),
        ),
        splashColor: Colors.transparent,
        child: Container(
          height: 65,
          width: MediaQuery.of(context).size.width * 0.42 ,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isSelected ? widget.account.color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSize.borderRadius),
            border: Border.all(
              color: _isSelected ? Colors.transparent : widget.account.color,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 1,
                child: Icon(
                  widget.account.icon.icon,
                  color: _isSelected ? AppColor.lightText : widget.account.color,
                  size: AppSize.bigIcon,
                ),
              ),
              Flexible(
                flex: 3,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.account.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _isSelected ? AppColor.lightText : widget.account.color,
                            fontSize: AppSize.heading3
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        widget.account.balance.toStringAsFixed(2),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _isSelected ? AppColor.lightText : widget.account.color,
                            fontSize: AppSize.heading2
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
