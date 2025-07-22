import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

import '../../components/account/account_customization_sheet.dart';
import '../../models/account.dart';
import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/app_message.dart';
import '../../utils/main_icon.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key, required this.account, required this.onReload});

  final Account account;
  final void Function() onReload;

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {

  late Account _account;
  late int _codePoint;
  late int _colorValue;
  final List<Currency> _currencies = Currency.currencies;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _accountBalanceController = TextEditingController(text: '0');


  @override
  void initState() {
    _account = widget.account;
    _codePoint = _account.icon.icon!.codePoint;
    _colorValue = _account.color.toARGB32();
    _nameController.text = _account.name;
    _descriptionController.text = _account.description;
    _accountBalanceController.text = _account.balance.toString();
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
    Account updatedAccount = _account.copyWith(
      name: _nameController.text,
      icon: Icon(IconData(_codePoint, fontFamily: "MaterialSymbolsOutlined")),
      color: Color(_colorValue),
      description: _descriptionController.text,
      balance: double.parse(_accountBalanceController.text),
    );
    () async {
      await AccountsRepositories.instance.updateAccount(updatedAccount);
      widget.onReload();
    }();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

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
              onPressed: _handleSubmit,
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
                      isRound: false,)
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
                subtitle: Text(_account.type.name[0].toUpperCase() + _account.type.name.substring(1)),
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
                                  _account = _account.copyWith(type: AccountType.accounts);
                                });
                                Navigator.pop(dialogContext);
                              },
                            ),
                            ListTile(
                              title: Text('Savings'),
                              subtitle: Text('for saving money: savings account, wishes, trip, etc'),
                              onTap: () {
                                setState(() {
                                  _account = _account.copyWith(type: AccountType.savings);
                                });
                                Navigator.pop(dialogContext);
                                // Handle savings account selection
                              },
                            ),
                            ListTile(
                              title: Text('Debts'),
                              subtitle: Text('For owned debts: Credit Cards, Loans, trip, etc'),
                              onTap: () {
                                setState(() {
                                  _account = _account.copyWith(type: AccountType.debts);
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
              subtitle: Text(_account.currency.fullName),
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
                              _account = _account.copyWith(currency: currency);
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
                      decoration: InputDecoration(
                        prefixText: _account.currency.toString(),
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
              value: _account.isIncludesInTotal,
              onChanged: (bool value) {
                setState(() {
                  _account = _account.copyWith(isIncludesInTotal: value);
                });
              },
              activeColor: Colors.blueAccent, // Color of the switch when on
            ),
            _account.isMain
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
                      return AlertDialog(
                        title: Text('Delete account?'),
                          content: Text('Related Transactions will also be deleted but other account balance will remain unchanged. This action cannot be undone.'),
                          actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              () async {
                                await AccountsRepositories.instance.deleteAccount(_account.id);
                                widget.onReload();
                              }();
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
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


