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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: accounts.map((account) {
            return AccountTile(
              account: account,
              onSelect: (isSelected) {
                _handleSelect(account.id, isSelected);
              },
            );
          }).toList(),
        )
      ],
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
    return InkWell(
      onTap: _handleTap,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.borderRadius),
      ),

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
          children: [
            Icon(
              widget.account.icon.icon,
              color: _isSelected ? AppColor.lightText : widget.account.color,
              size: AppSize.heading1,
            ),
            const SizedBox(width: 8,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    ' ${widget.account.balance.toStringAsFixed(2)}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _isSelected ? AppColor.lightText : widget.account.color,
                        fontSize: AppSize.heading3
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
