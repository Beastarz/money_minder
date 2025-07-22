import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_minder/components/account/account_customization_sheet.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/app_message.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key, required this.onAddAccount});

  final void Function() onAddAccount;

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {

  bool _includeInTotalBalance = true;
  int _codePoint = 0xeb94;
  int _colorValue = 0xFF578FCA;
  AccountType _accountType = AccountType.accounts;
  Currency _mainCurrency = Currency.of('sgd');
  final List<Currency> _currencies = Currency.currencies;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _accountBalanceController = TextEditingController(text: '0.00');


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _accountBalanceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_nameController.text.isEmpty) {
      AppMessage.showMessage(context, 'Please fill in a name');
      return;
    }
    if (_accountBalanceController.text.isEmpty) {
      _accountBalanceController.text = '0';
    }
    if (double.parse(_accountBalanceController.text) > 99999999999.99) {
      AppMessage.showMessage(context, 'Amount is too large!');
      return;
    }
    Map<String, dynamic> accountData = Account.insertAsMap(
      name: _nameController.text,
      balance: double.parse(_accountBalanceController.text) * (_accountType == AccountType.debts ? -1 : 1),
      icon: Icon(IconData(_codePoint, fontFamily: "MaterialSymbolsOutlined")),
      color: Color(_colorValue),
      description: _descriptionController.text,
      isIncludesInTotal: _includeInTotalBalance,
      type: _accountType,
      currency: _mainCurrency,
    );
    () async {
      await AccountsRepositories.instance.createAccount(accountData);
      widget.onAddAccount();
    }();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, innerSetState) => SafeArea(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.secondary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(AppSize.borderRadius),
                                    topRight: Radius.circular(AppSize.borderRadius),
                                  ),
                                ),
                                child: AccountCustomizationSheet(
                                    codePoint: _codePoint,
                                    colorValue: _colorValue,
                                    changeCodePoint: (int newCodePoint) {
                                      setState(() {
                                        _codePoint = newCodePoint;
                                      });
                                      innerSetState(() {});
                                    },
                                    changeColorValue: (int newColorValue) {
                                      setState(() {
                                        _colorValue = newColorValue;
                                      });
                                      innerSetState(() {});
                                    },
                                )
                              ),
                            ),
                          );
                        }
                    );
                  },
                  icon: MainIcon(
                    icon: Icon(IconData(_codePoint, fontFamily: "MaterialSymbolsOutlined")),
                    color: Color(_colorValue),
                    isRound: false,),
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
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text('Choose a type'),
                    children: [
                      ListTile(
                        title: Text('Regular'),
                        subtitle: Text('For regular expenses: Cash, Card, Bank Deposits, etc'),
                        onTap: () {
                          setState(() {
                            _accountType = AccountType.accounts;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text('Savings'),
                        subtitle: Text('For saving money: Savings account, Wishes, Future Trip, etc'),
                        onTap: () {
                          setState(() {
                            _accountType = AccountType.savings;
                            _includeInTotalBalance = false;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text('Debts'),
                        subtitle: Text('For owned debts: Credit Cards, Loans, trip, etc'),
                        onTap: () {
                          setState(() {
                            _accountType = AccountType.debts;
                            _includeInTotalBalance = false;
                          });
                          Navigator.pop(context);
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
                    children: _currencies.map((currency) => ListTile(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_accountType == AccountType.debts ? 'Debt balance' :'Account balance'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_mainCurrency.toString() + (_accountType == AccountType.debts ? ' ( - )' : ''), style: TextStyle(fontSize: 18),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3, // Adjust width as needed
                        child: TextField(
                          controller: _accountBalanceController,
                          textAlign: TextAlign.end,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                          ],
                          onTap: () {
                            if (_accountBalanceController.text.isNotEmpty && double.parse(_accountBalanceController.text) == 0) {
                              _accountBalanceController.text = '';
                            }
                          },
                          onEditingComplete: () {
                            if (_accountBalanceController.text.isEmpty || double.parse(_accountBalanceController.text) == 0) {
                              _accountBalanceController.text = '0.00';
                            }
                            FocusScope.of(context).unfocus();
                          },
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
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