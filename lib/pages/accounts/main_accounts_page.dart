import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/utils/balance_text.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../../components/account/account_detail_sheet.dart';
import '../../models/currency.dart';
import '../../style/app_size.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key, required this.accounts, required this.mainCurrency, required this.onReload});

  final List<Account> accounts;
  final Currency mainCurrency;
  final void Function() onReload;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {

  @override
  Widget build(BuildContext context) {
    final List<Account> accounts = widget.accounts;
    final Currency mainCurrency = widget.mainCurrency;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TabBar(
          tabs: <Widget>[
            Tab(text: 'Accounts'),
            Tab(text: 'Savings'),
            Tab(text: 'Debts',)
          ]
        ),
        body: TabBarView(
          children: AccountType.values.map((accountType) {
            List<Account> acc = accounts.where((acc) => acc.type == accountType).toList();
            return Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                decoration:BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.secondary)
                ),
                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Total:',
                                  style: TextStyle(
                                    fontSize: AppSize.heading3,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                BalanceText(
                                  balance: acc.isEmpty ? 0 : acc.map((e) => Currency.convert(e.currency, mainCurrency, e.balance))
                                      .reduce((value, element) => value + element),
                                  currencyName: mainCurrency.toString(),
                                  showColor: true,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.grey[600],
                          thickness: 1,
                          indent: 10,
                          endIndent: 10,
                        ),
                        acc.isEmpty ? Container() :
                        Expanded(
                          child: ReorderableListView.builder(
                            physics: ScrollPhysics(),
                            scrollController: ScrollController(),
                            shrinkWrap: true,
                            itemCount: acc.length,
                            onReorder: (int oldIndex, int newIndex) async {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                setState(() {
                                  final Account item = accounts.removeAt(acc.elementAt(oldIndex).position);
                                  accounts.insert(acc.elementAt(newIndex).position, item);
                                });
                                await AccountsRepository.instance.updateAccountPosition(accounts);
                                widget.onReload();
                            },
                            itemBuilder: (BuildContext context, int index) {
                              Account account = acc.elementAt(index);
                              return ListTile(
                                key: ValueKey(account.id),
                                leading: MainIcon(icon: account.icon, color: account.color, isRound: false,),
                                title: Text(
                                  account.name + (account.isMain ? '★' : ''),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  account.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: AppSize.paragraph,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                trailing: BalanceText(
                                  balance: account.balance,
                                  currencyName: account.currency.toString(),
                                  showColor: true,
                                ),
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  useRootNavigator: true,
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      top: false,
                                      left: false,
                                      right: false,
                                      child: SingleChildScrollView(
                                          child: AccountDetailSheet(account: account, onReload: widget.onReload),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                ),
              ),
            );
          }).toList(),
        ),
      )
    );
  }
}

