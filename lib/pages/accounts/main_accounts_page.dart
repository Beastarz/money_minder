import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/providers/account_provider.dart';
import 'package:money_minder/providers/currency_provider.dart';
import 'package:money_minder/utils/balance_text.dart';
import 'package:money_minder/utils/main_icon.dart';
import 'package:provider/provider.dart';

import '../../components/account/account_detail_sheet.dart';
import '../../models/currency.dart';
import '../../style/app_size.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {

  @override
  void initState() {
    super.initState();
    context.read<AccountProvider>().fetchAccounts();
    context.read<CurrencyProvider>().fetchMainCurrency();
  }

  @override
  Widget build(BuildContext context) {
    final List<Account> accounts = context.watch<AccountProvider>().accounts;
    final Currency mainCurrency = context.watch<CurrencyProvider>().mainCurrency;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          tabs: <Widget>[
            Tab(text: 'Accounts'),
            Tab(text: 'Savings'),
          ]
        ),
        body: TabBarView(
          children: AccountType.values.map((accountType) {
            List<Account> acc = accounts.where((acc) => acc.type == accountType).toList();
            return acc.isNotEmpty
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
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
                            balance: acc.map((e) => Currency.convert(e.currency, mainCurrency, e.balance))
                                .reduce((value, element) => value + element),
                            currencyName: mainCurrency.toString(),
                            showColor: true,
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.grey[700],
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    ReorderableListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: acc.length,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final Account item = accounts.removeAt(acc.elementAt(oldIndex).position);
                          accounts.insert(acc.elementAt(newIndex).position, item);
                          context.read<AccountProvider>().updateAccountPosition(accounts);
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        Account account = acc.elementAt(index);
                        return ListTile(
                          key: ValueKey(account.id),
                          leading: MainIcon(icon: account.icon, color: account.color, isRound: false,),
                          title: Text(
                            account.name + (account.isMain ? '★' : ''),
                            style: TextStyle(
                              fontSize: AppSize.heading2,
                            ),
                          ),
                          subtitle: BalanceText(
                            balance: account.balance,
                            currencyName: account.currency.toString(),
                            showColor: true,
                          ),
                          onTap: () => showModalBottomSheet(
                            context: context,
                            useSafeArea: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return SingleChildScrollView(
                                  child: AccountDetailSheet(account: account),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
            )
                : Container();
          }).toList(),
        ),
      )
    );
  }
}

