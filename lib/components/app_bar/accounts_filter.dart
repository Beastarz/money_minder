import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class AccountsFilter extends StatefulWidget {
  const AccountsFilter({super.key});

  @override
  State<AccountsFilter> createState() => _AccountsFilterState();
}

class _AccountsFilterState extends State<AccountsFilter> {
  AccountsApi accountsApi = AccountsApi();

  List<Account> accounts = [];
  List<int> selectedAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      List<Map<String, dynamic>> res = await accountsApi.getAllAccounts();
      setState(() {
        accounts = res.map((e) => Account(e)).toList();
      });
      print(accounts);
    } catch (e) {
      print(e);
      setState(() {
        accounts = [];
      });
    }
  }

  void _handleSelect(int index, bool isSelected) {
    if (isSelected) {
      if (!selectedAccounts.contains(index)) {
        selectedAccounts.add(index);
      }
    } else {
      selectedAccounts.remove(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0,10,0,0),
          child: Text(
            'Accounts Filter',
            style: TextStyle(
                color: AppColor.lightText,
                fontSize: AppSize.heading1,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: accounts.asMap().entries.map((entry) {
            return AccountTile(
              index: entry.key,
              account: entry.value,
              onSelect: (isSelected) {
                _handleSelect(entry.key, isSelected);
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
  final int index;
  final Function onSelect;

  const AccountTile({super.key,required this.index, required this.account, required this.onSelect});

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
