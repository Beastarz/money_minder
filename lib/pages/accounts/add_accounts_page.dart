import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:money_minder/utils/main_icon.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage(BuildContext context, {super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  CurrencyRepositories currencyRepositories = CurrencyRepositories();
  AccountsRepository accountsRepository = AccountsRepository();

  bool _includeInTotalBalance = true;
  Icon icon = Icon(Icons.abc_rounded);
  Color color = Colors.blueGrey;
  AccountType accountType = AccountType.accounts;
  List<Currency> currencies = [];
  Currency mainCurrency = Currency.of('sgd');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _accountBalanceController = TextEditingController(text: '0');


  @override
  void initState() {
    _getMainCurrency();
    _getCurrencies();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _accountBalanceController.dispose();
    currencyRepositories.close();
    accountsRepository.close();
    super.dispose();
  }

  void _getCurrencies() async {
    try {
      List<Currency> res = await currencyRepositories.getCurrencies();
      setState(() {
        currencies = res;
      });
    } catch (e) {
      setState(() {
        currencies = [];
      });
    }
  }

  void _getMainCurrency() async {
    try {
      Currency res = await currencyRepositories.getMainCurrency();
      setState(() {
        mainCurrency = res;
      });
    } catch(e) {
      setState(() {
        mainCurrency = Currency.of('sgd');
      });
    }
  }

  void _handleSubmit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    try {
      Map<String, dynamic> accountData = Account.insertAsMap(
        name: _nameController.text,
        balance: double.parse(_accountBalanceController.text),
        icon: icon,
        color: color,
        description: _descriptionController.text,
        isIncludesInTotal: _includeInTotalBalance,
        type: accountType,
        currency: mainCurrency,
      );
      await accountsRepository.createAccount(accountData);
      print('success');
      Navigator.pop(context);
    } catch(e) {
      print(e);
      print('failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            // Handle close action
            Navigator.pop(context);
          },
        ),
        title: Text('New account'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: _handleSubmit,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                // Or your desired button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Create',
                style: TextStyle(
                  color: Colors.white, // Or your desired color
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.7,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.03,),
                IconButton(
                  onPressed: () {},
                  icon: MainIcon(icon: icon, color: color, isRound: false,)
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme
                    .of(context)
                    .primaryColor, // Matches the section header color
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined),
              // Placeholder icon
              title: Text('Type'),
              subtitle: Text(accountType.name[0].toUpperCase() + accountType.name.substring(1)),
              trailing: Icon(Icons.chevron_right),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text('Choose a type'),
                    children: [
                      ListTile(
                        title: Text('Regular'),
                        subtitle: Text('for regular expenses: cash, card, bank card, etc'),
                        onTap: () {
                          setState(() {
                            accountType = AccountType.accounts;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text('Savings'),
                        subtitle: Text('for saving money: savings account, wishes, trip, etc'),
                        onTap: () {
                          setState(() {
                            accountType = AccountType.savings;
                          });
                          Navigator.pop(context);
                          // Handle savings account selection
                        },
                      ),
                    ]
                  );
                }
              )

            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              // Placeholder icon
              title: Text('Account currency'),
              subtitle: Text(mainCurrency.fullName),
              trailing: Icon(Icons.chevron_right),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text('Choose a currency'),
                    children: currencies.map((currency) => ListTile(
                      title: Text(currency.fullName),
                      onTap: () {
                        setState(() {
                          mainCurrency = currency;
                        });
                        Navigator.pop(context);
                      }
                    )).toList(),
                  );
                }
              ),
            ),
            ListTile(
              leading: Icon(Icons.description_outlined), // Placeholder icon
              title: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description',
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme
                    .of(context)
                    .primaryColor, // Matches the section header color
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(child: Text('Account balance')),
                  SizedBox(
                    width: 100, // Adjust width as needed
                    child: TextField(
                      controller: _accountBalanceController,
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        prefixText: mainCurrency.toString(),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
            SwitchListTile(
              title: Text('Include in total balance'),
              value: _includeInTotalBalance,
              onChanged: (bool value) {
                setState(() {
                  _includeInTotalBalance = value;
                });
              },
              activeColor: Colors.blueAccent, // Color of the switch when on
            ),
          ],
        ),
      ),
    );
  }
}