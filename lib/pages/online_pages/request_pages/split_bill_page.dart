import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_minder/models/online/user.dart' as model;

import '../../../components/search_users/contact_user_search_page.dart';
import '../../../firestore_repositories/transaction_request_repositories.dart';
import '../../../firestore_repositories/users_repositories.dart';
import '../../../models/currency.dart';
import '../../../models/online/transaction_request.dart';
import '../../../utils/app_message.dart';

enum SplitType {
  custom,
  even,
  ratio,
}

class SplitBillPage extends StatefulWidget {
  const SplitBillPage({super.key});

  @override
  State<SplitBillPage> createState() => _SplitBillPageState();
}

class _SplitBillPageState extends State<SplitBillPage> {
  final List<TextEditingController> _amountControllers = [];
  final TextEditingController _totalController = TextEditingController(text: '0.00');
  final List<TextEditingController> _ratioControllers = [];
  final List<model.User?> _users = [null];
  final TextEditingController _messageController = TextEditingController();
  SplitType _splitType = SplitType.custom;

  Currency _currency = Currency.of('sgd');
  final List<Currency> _currencies = Currency.currencies;
  final List<Color> _borderColors = [Colors.deepPurple, Colors.indigo, Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.orange,];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final amountController = TextEditingController(text: '0.00');
    amountController.addListener(calculateTotal);
    _amountControllers.add(amountController);
    final ratioC = TextEditingController(text: '1');
    ratioC.addListener(calculateSplit);
    _ratioControllers.add(ratioC);
    _totalController.addListener(calculateSplit);
  }

  void calculateTotal() {
    if (_splitType == SplitType.custom) {
      setState(() {
        double total = 0;
        for (var c in _amountControllers) {
          if (c.text.isNotEmpty) {
            total += double.parse(c.text);
          }
        }
        _totalController.text = total.toStringAsFixed(2);
      });
    }
  }

  void calculateSplit() {
    if (_splitType != SplitType.custom) {
      setState(() {
        double sum = _ratioControllers.map((t) => t.text.isEmpty ? 1.0 : double.parse(t.text))
            .reduce((x, y) => x + y);
        for (int i = 0; i < _ratioControllers.length; i++) {
          double total = _totalController.text.isEmpty ? 0 : double.parse(
              _totalController.text);
          double ratio = _ratioControllers[i].text.isEmpty ? 0.0 : double.parse(_ratioControllers[i].text);
          _amountControllers[i].text =
              (total * ratio / sum).toStringAsFixed(2);
        }
      });
    }
  }

  void _handleSubmit() async {
    for ((int, model.User?) item in _users.indexed) {
      model.User? targetUser = item.$2;
      TextEditingController amountController = _amountControllers[item.$1];
      if (targetUser == null) {
        AppMessage.showMessage(context, 'Please select a user.');
        return;
      }
      if (amountController.text.isEmpty || _totalController.text.isEmpty) {
        AppMessage.showMessage(context, 'Please fill in an amount');
        return;
      }
      double amount = double.parse(amountController.text);
      double total = double.parse(_totalController.text);
      if (amount <= 0) {
        AppMessage.showMessage(context, 'Amount must be greater than 0');
        return;
      }
      if (amount > 99999999999.99 || total > 99999999999.99) {
        AppMessage.showMessage(context, 'Amount is too large!');
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });
    for ((int, model.User?) item in _users.indexed) {
      model.User? targetUser = item.$2;
      TextEditingController amountController = _amountControllers[item.$1];
      double amount = double.parse(amountController.text);

      final receiverRef = UsersRepositories.instance.getUserReference(
          targetUser!.uid);
      final senderRef = UsersRepositories.instance.getUserReference(
          FirebaseAuth.instance.currentUser!.uid);

      Map<String, dynamic> map = TransactionRequest.submitAsMap(
          sender: senderRef,
          receiver: receiverRef,
          amount: amount,
          currency: _currency,
          message: _messageController.text,
          requestType: TransactionRequestType.ask);
      try {
        await TransactionRequestRepositories.instance.submitTransactionRequest(
            map);
      } catch (e) {
        if (mounted) {
          AppMessage.showMessage(context, 'error');
        }
        return;
      }
    }
    setState(() {
      _isLoading = false;
    });
    if (mounted) {
      Navigator.pop(context);
      AppMessage.showMessage(context, 'Sent successfully');
    }
  }

  void onUsernameSelection(model.User user, int index) => setState(() => _users[index] = user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Bill'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.attach_money),
                  // Placeholder icon
                  title: Text('Currency'),
                  subtitle: Text(_currency.fullName),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          title: Text('Select currency'),
                          children: _currencies.map((currency) => ListTile(
                              title: Text(currency.fullName),
                              onTap: () {
                                setState(() {
                                  _currency = currency;
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      label: Text('Group Message'),
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.splitscreen_rounded),
                  // Placeholder icon
                  title: Text('Split Type'),
                  subtitle: Text(_splitType.name[0].toUpperCase() + _splitType.name.substring(1)),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          title: Text('Select split type'),
                          children: SplitType.values.map((splitType) => ListTile(
                              title: Text(splitType.name[0].toUpperCase() + splitType.name.substring(1)),
                              onTap: () {
                                setState(() {
                                  _splitType = splitType;
                                  if (splitType == SplitType.even) {
                                    for (var c in _ratioControllers) {
                                      c.text = '1';
                                    }
                                  }
                                  if (splitType != SplitType.custom) {
                                    calculateSplit();
                                  }
                                });
                                Navigator.pop(context);
                              }
                          )).toList(),
                        );
                      }
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recipients', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),),
                ),
                SizedBox(height: 8,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 8,),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Total: ${_currency.toString()} ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                            _splitType == SplitType.custom
                                ? Text(_totalController.text.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
                                : SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.3,
                                    child: TextField(
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,color: Colors.black87),
                                      controller: _totalController,
                                      textAlign: TextAlign.end,
                                      decoration: InputDecoration(contentPadding: EdgeInsets.all(0)),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                                      ],
                                      keyboardType: TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      enabled: _splitType != SplitType.custom,
                                      onTap: () {
                                        if (_totalController.text.isNotEmpty && double.parse(_totalController.text) == 0) {
                                          _totalController.text = '';
                                        }
                                      },
                                      onEditingComplete: () {
                                        if (_totalController.text.isEmpty || double.parse(_totalController.text) == 0) {
                                          _totalController.text = '0.00';
                                        }
                                      },

                                    ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: _users.indexed.map((item) {
                            final model.User? user = item.$2;
                            final index = item.$1;
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: _borderColors[index % _borderColors.length]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      children: [
                                        Center(child: Text('Recipient ${index+1}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                                        index == 0 ? Container() :
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: IconButton(
                                                color: Colors.red,
                                                padding: EdgeInsets.all(0),
                                                onPressed: () {
                                                  setState(() {
                                                    _users.removeAt(index);
                                                    _amountControllers.removeAt(index);
                                                    _ratioControllers.removeAt(index);
                                                  });
                                                  if (_splitType == SplitType.custom) {
                                                    calculateTotal();
                                                  } else {
                                                    calculateSplit();
                                                  }
                                                },
                                                icon: Icon(Icons.remove),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.person_outline),
                                      title: Text('To: ${user == null ? 'Select a user' : '@${user.username}'}', style: TextStyle(fontSize: 18),),
                                      trailing: IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context) =>
                                                    ContactUserSearchPage(onUserSelection: (user) => onUsernameSelection(user, index))));
                                          },
                                          icon: Icon(Icons.search)
                                      ),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.attach_money_outlined),
                                      title: Text('Amount', style: TextStyle(fontSize: 18),),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_currency.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            child: TextField(
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
                                              controller: _amountControllers[index],
                                              textAlign: TextAlign.end,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                                              ],
                                              keyboardType: TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                              enabled: _splitType == SplitType.custom,
                                              onTap: () {
                                                if (_amountControllers[index].text.isNotEmpty && double.parse(_amountControllers[index].text) == 0) {
                                                  _amountControllers[index].text = '';
                                                }
                                              },
                                              onEditingComplete: () {
                                                if (_amountControllers[index].text.isEmpty || double.parse(_amountControllers[index].text) == 0) {
                                                  _amountControllers[index].text = '0.00';
                                                }
                                              },

                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _splitType != SplitType.ratio ?  SizedBox.shrink() : ListTile(
                                      leading: Icon(Icons.horizontal_split_outlined),
                                      title: Text('Ratio', style: TextStyle(fontSize: 18),),
                                      trailing: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        child: TextField(
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
                                          controller: _ratioControllers[index],
                                          textAlign: TextAlign.end,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                                          ],
                                          keyboardType: TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          enabled: _splitType == SplitType.ratio,
                                          onTap: () {
                                            if (_ratioControllers[index].text.isNotEmpty && double.parse(_ratioControllers[index].text) == 0) {
                                              _ratioControllers[index].text = '';
                                            }
                                          },
                                          onEditingComplete: () {
                                            if (_ratioControllers[index].text.isEmpty || double.parse(_ratioControllers[index].text) == 0) {
                                              _ratioControllers[index].text = '0.00';
                                            }
                                          },

                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8,),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _users.add(null);
                              final c = TextEditingController(text: '0.00');
                              final r = TextEditingController(text: '1');
                              r.addListener(calculateSplit);
                              c.addListener(calculateTotal);
                              _amountControllers.add(c);
                              _ratioControllers.add(r);
                            });
                            if (_splitType != SplitType.custom) {
                              calculateSplit();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add),
                              Text('Add Recipient'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _isLoading ? CircularProgressIndicator() :
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text('Send'),
                ),
              ]
            ),
          ),
        )
      )
    );
  }
}
