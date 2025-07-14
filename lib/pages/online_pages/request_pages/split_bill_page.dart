import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_minder/models/online/user.dart' as model;

import '../../../components/search_users/contact_user_search_page.dart';
import '../../../firestore_repositories/transaction_request_repositories.dart';
import '../../../firestore_repositories/users_repositories.dart';
import '../../../models/currency.dart';
import '../../../models/online/transaction_request.dart';
import '../../../repositories/currency_repositories.dart';
import '../../../style/app_color.dart';
import '../../../utils/app_message.dart';

class SplitBillPage extends StatefulWidget {
  const SplitBillPage({super.key});

  @override
  State<SplitBillPage> createState() => _SplitBillPageState();
}

class _SplitBillPageState extends State<SplitBillPage> {
  final List<TextEditingController> _amountControllers = [];
  double _total = 0;
  final List<model.User?> _users = [null];
  final TextEditingController _messageController = TextEditingController();
  Currency _currency = Currency.of('sgd');
  List<Currency> _currencies = [];
  final List<Color> _borderColors = [Colors.deepPurple, Colors.indigo, Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.orange,];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final controller = TextEditingController(text: '0.00');
    controller.addListener(calculateTotal);
    _amountControllers.add(controller);
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    List<Currency> res = await CurrencyRepositories.instance.getCurrencies();
    setState(() {
      _currencies = res;
    });
  }

  void calculateTotal() {
    setState(() {
      _total = 0;
      for (var c in _amountControllers) {
        if (c.text.isNotEmpty) {
          _total += double.parse(c.text);
        }
      }
    });
  }

  void _handleSubmit() async {
    for ((int, model.User?) item in _users.indexed) {
      model.User? targetUser = item.$2;
      TextEditingController amountController = _amountControllers[item.$1];
      if (targetUser == null) {
        AppMessage.showMessage(context, 'Please select a user.');
        return;
      }
      if (amountController.text.isEmpty) {
        AppMessage.showMessage(context, 'Please fill in an amount');
        return;
      }
      double amount = double.parse(amountController.text);
      if (amount <= 0) {
        AppMessage.showMessage(context, 'Amount must be greater than 0');
        return;
      }
      if (amount > 99999999999.99 || _total > 99999999999.99) {
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
                          title: Text('Choose a currency'),
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
                SizedBox(height: 8,),
                Row(
                  children: [
                    Text('Recipients', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),),
                  ],
                ),
                SizedBox(height: 8,),
                Text('Total ${_currency.toString()} ${_total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
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
                            Text('Recipient ${index+1}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                            ListTile(
                              leading: Icon(Icons.person_outline),
                              title: Text('To: ${user == null ? 'Select a user' : '@${user!.username}'}', style: TextStyle(fontSize: 18),),
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
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                      controller: _amountControllers[index],
                                      textAlign: TextAlign.end,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                                      ],
                                      keyboardType: TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
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
                            )
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
                      c.addListener(calculateTotal);
                      _amountControllers.add(c);
                    });
                  },
                  child: Text('Add Recipient'),
                ),
              ]
            ),
          ),
        )
      )
    );
  }
}
