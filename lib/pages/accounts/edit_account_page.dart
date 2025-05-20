import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/account.dart';
import '../../models/currency.dart';
import '../../providers/account_provider.dart';
import '../../providers/currency_provider.dart';
import '../../utils/main_icon.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {

  late Account account;
  bool _includeInTotalBalance = true;
  Icon _icon = Icon(Icons.abc_rounded);
  Color _color = Colors.blueGrey;
  AccountType _accountType = AccountType.accounts;
  Currency _mainCurrency = Currency.of('sgd');
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _accountBalanceController = TextEditingController(text: '0');

  bool _initialLoad = true;


  @override
  void initState() {
    context.read<CurrencyProvider>().fetchCurrencies();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _accountBalanceController.dispose();
    super.dispose();
  }

  void _handleSubmit(Account updatedAccount) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in a name')));
      return;
    }
    try {
      await context.read<AccountProvider>()
          .updateAccount(updatedAccount
          .copyWith(
        name: _nameController.text,
        icon: _icon,
        color: _color,
        description: _descriptionController.text,
        isIncludesInTotal: _includeInTotalBalance,
        type: _accountType,
        currency: _mainCurrency,
      ));
    } catch(e) {
      print(e);
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoad) {
      Map<String, dynamic> args = ModalRoute
          .of(context)!
          .settings
          .arguments as Map<String, dynamic>;
      Account accountFromArgs = args['account'];
      setState(() {
        account = accountFromArgs;
        _nameController.text = account.name;
        _descriptionController.text = account.description;
        _accountBalanceController.text = account.balance.toString();
        _icon = account.icon;
        _color = account.color;
      });
      _initialLoad = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Currency> currencies = context.read<CurrencyProvider>().currencies;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit account'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: () {
                _handleSubmit(account);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Edit',
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
                    icon: MainIcon(icon: _icon, color: _color, isRound: false,)
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
                    .primaryColorDark, // Matches the section header color
              ),
            ),
            SizedBox(height: 8),
            ListTile(
                leading: Icon(Icons.account_balance_wallet_outlined),
                // Placeholder icon
                title: Text('Type'),
                subtitle: Text(_accountType.name[0].toUpperCase() + _accountType.name.substring(1)),
                trailing: Icon(Icons.chevron_right),
                onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return SimpleDialog(
                          title: Text('Choose a type'),
                          children: [
                            ListTile(
                              title: Text('Regular'),
                              subtitle: Text('for regular expenses: cash, card, bank card, etc'),
                              onTap: () {
                                setState(() {
                                  _accountType = AccountType.accounts;
                                });
                                Navigator.pop(dialogContext);
                              },
                            ),
                            ListTile(
                              title: Text('Savings'),
                              subtitle: Text('for saving money: savings account, wishes, trip, etc'),
                              onTap: () {
                                setState(() {
                                  _accountType = AccountType.savings;
                                });
                                Navigator.pop(dialogContext);
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
              subtitle: Text(_mainCurrency.fullName),
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
                              _mainCurrency = currency;
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
                    .primaryColorDark, // Matches the section header color
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
                        prefixText: _mainCurrency.toString(),
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
            account.isMain
              ? Container()
              : ListTile(
                leading: Icon(Icons.delete, color: Colors.red,),
                title: Text(
                  'Delete account',
                  style: TextStyle(
                    color: Colors.red, // Set the text color to red
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: Text('Delete account?'),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<AccountProvider>().deleteAccount(account.id);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text('Delete'),
                              )
                            ],
                          )
                        ]
                      );
                    }
                  );
                },
              )
          ],
        ),
      ),
    );
  }
}


