import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';

import '../../repositories/accounts_repositories.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../app_bar/account_tile.dart';

class AccountSelectionSheet extends StatefulWidget {
  final Function(Account) onSelect;
  final Account? removeAccount;

  const AccountSelectionSheet({super.key, required this.onSelect, this.removeAccount});

  @override
  State<AccountSelectionSheet> createState() => _AccountSelectionSheetState();
}

class _AccountSelectionSheetState extends State<AccountSelectionSheet> {
  List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  _fetchAccounts() async {
    List<Account> res = await AccountsRepositories.instance.getAllAccounts();
    setState(() {
      accounts = res;
      if(widget.removeAccount != null) {
        accounts.removeWhere((account) => account.id == widget.removeAccount!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    List<AccountType> accountTypes = AccountType.values;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppSize.smallPadding),
                        child: Text(
                            'Select Account',
                            style: TextStyle(
                              fontSize: AppSize.heading1,
                            )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ListView(
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
                            onSelect: () {
                              Navigator.pop(context);
                              widget.onSelect(account);
                            },
                            showColor: false,
                          );
                        }).toList(),
                      ),
                    ],
                  )
                      : Container();
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
