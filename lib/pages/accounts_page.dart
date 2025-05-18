import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/utils/balance_text.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../models/currency.dart';
import '../repositories/currency_repositories.dart';
import '../style/app_size.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  AccountsRepository accountsApi = AccountsRepository();
  CurrencyRepositories currencyApi = CurrencyRepositories();

  List<Account> accounts = [];
  Currency mainCurrency = Currency.of('sgd');

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _getMainCurrency();
  }

  void _getMainCurrency() async {
    try {
      Currency res = await currencyApi.getMainCurrency();
      setState(() {
        mainCurrency = res;
      });
    } catch(e) {
      setState(() {
        mainCurrency = Currency.of('sgd');
      });
    }
  }

  void _loadAccounts() async {
    try {
      List<Account> res = await accountsApi.getAllAccounts();
      setState(() {
        accounts = res;
      });
    } catch (e) {
      setState(() {
        accounts = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Iterable<Account> acc = accounts.where((acc) => acc.type == accountType);
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
                    ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: acc.length,
                      itemBuilder: (BuildContext context, int index) {
                        Account account = acc.elementAt(index);

                        return ListTile(
                          leading: MainIcon(icon: account.icon, color: account.color, rounded: false,),
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

