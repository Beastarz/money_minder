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
  AccountsRepository accountsApi = AccountsRepository();

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
    List<AccountType> accountTypes = AccountType.values;
    return ListView(
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
                        color: AppColor.lightText,
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                widget.account.icon.icon,
                color: _isSelected ? AppColor.lightText : widget.account.color,
                size: AppSize.bigIcon,
              ),
              SizedBox(width: 8,),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.account.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: _isSelected ? AppColor.lightText : widget.account.color,
                          fontSize: AppSize.heading3
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.account.currency.toString() + widget.account.balance.toStringAsFixed(2),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: _isSelected ? AppColor.lightText : widget.account.color,
                          fontSize: AppSize.heading3 * 1.05
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
