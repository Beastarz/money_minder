import 'package:flutter/material.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/currency_repositories.dart';

import '../../components/account/account_customization_sheet.dart';
import '../../models/account.dart';
import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/main_icon.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key, required this.account, required this.onReload});

  final Account account;
  final void Function() onReload;

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {

  late Account account;
  late int codePoint;
  late int colorValue;
  List<Currency> currencies = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _accountBalanceController = TextEditingController(text: '0');


  @override
  void initState() {
    account = widget.account;
    codePoint = account.icon.icon!.codePoint;
    colorValue = account.color.toARGB32();
    _nameController.text = account.name;
    _descriptionController.text = account.description;
    _accountBalanceController.text = account.balance.toString();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _accountBalanceController.dispose();
    super.dispose();
  }

  Future<void> fetchCurrencies() async {
    List<Currency> res = await CurrencyRepositories.instance.getCurrencies();
    setState(() {
      currencies = res;
    });
  }

  void _handleSubmit() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Please fill in a name')
          ));
      return;
    }
    if (double.parse(_accountBalanceController.text) > 99999999999.99) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Amount is too large!')
          ));
      return;
    }
    Account updatedAccount = account.copyWith(
      name: _nameController.text,
      icon: Icon(IconData(codePoint, fontFamily: "MaterialSymbolsOutlined")),
      color: Color(colorValue),
      description: _descriptionController.text,
      balance: double.parse(_accountBalanceController.text),
    );
    () async {
      await AccountsRepository.instance.updateAccount(updatedAccount);
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
                                      codePoint: codePoint,
                                      colorValue: colorValue,
                                      changeCodePoint: (int newCodePoint) {
                                        setState(() {
                                          codePoint = newCodePoint;
                                        });
                                        innerSetState(() {});
                                      },
                                      changeColorValue: (int newColorValue) {
                                        setState(() {
                                          colorValue = newColorValue;
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
                      icon: Icon(IconData(codePoint, fontFamily: "MaterialSymbolsOutlined")),
                      color: Color(colorValue),
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
                subtitle: Text(account.type.name[0].toUpperCase() + account.type.name.substring(1)),
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
                                  account = account.copyWith(type: AccountType.accounts);
                                });
                                Navigator.pop(dialogContext);
                              },
                            ),
                            ListTile(
                              title: Text('Savings'),
                              subtitle: Text('for saving money: savings account, wishes, trip, etc'),
                              onTap: () {
                                setState(() {
                                  account = account.copyWith(type: AccountType.savings);
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
                                  account = account.copyWith(type: AccountType.debts);
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
              subtitle: Text(account.currency.fullName),
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
                              account = account.copyWith(currency: currency);
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
                        prefixText: account.currency.toString(),
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
              value: account.isIncludesInTotal,
              onChanged: (bool value) {
                setState(() {
                  account = account.copyWith(isIncludesInTotal: value);
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
                                await AccountsRepository.instance.deleteAccount(account.id);
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


