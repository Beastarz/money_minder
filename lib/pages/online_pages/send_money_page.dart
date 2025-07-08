import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/search_users/contact_user_search_page.dart';
import 'package:money_minder/firestore_repositories/transaction_request_repositories.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/models/online/user.dart' as model;
import 'package:money_minder/style/app_color.dart';

import '../../models/currency.dart';
import '../../repositories/currency_repositories.dart';
import '../../utils/app_message.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  model.User? targetUser;
  List<Currency> currencies = [];
  Currency _currency = Currency.of('sgd');
  final TextEditingController _amountController = TextEditingController(text: '0');
  final TextEditingController _messageController = TextEditingController();


  Future<void> _fetchCurrencies() async {
    List<Currency> res = await CurrencyRepositories.instance.getCurrencies();
    setState(() {
      currencies = res;
    });
  }

  void _handleSubmit() {
    if (targetUser == null) {
      AppMessage.showMessage(context, 'Please select a user.');
      return;
    }
    if (_amountController.text.isEmpty) {
      AppMessage.showMessage(context, 'Please fill in an amount');
    }
    double amount = double.parse(_amountController.text);
    if (amount > 99999999999.99) {
      AppMessage.showMessage(context, 'Amount is too large!');
      return;
    }
    final receiverRef = UsersRepositories.instance.getUserReference(targetUser!.uid);
    final senderRef = UsersRepositories.instance.getUserReference(FirebaseAuth.instance.currentUser!.uid);

    Map<String, dynamic> map = TransactionRequest.submitAsMap(sender: senderRef, receiver: receiverRef, amount: amount, currency: _currency, message: _messageController.text, requestType: TransactionRequestType.send);
    () async {
      await TransactionRequestRepositories.instance.submitTransactionRequest(map);
    }();
    Navigator.pop(context);
  }

  void onUsernameSelection(model.User user) => setState(() => targetUser = user);

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Money'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: AppColor.secondary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: TextField(
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          controller: _amountController,
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            prefixText: _currency.toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('To: ${targetUser == null ? 'Select a user' : '@${targetUser!.username}'}', style: TextStyle(fontSize: 18),),
                trailing: IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUserSearchPage(onUserSelection: onUsernameSelection)));
                    },
                    icon: Icon(Icons.search)
                ),
              ),
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
                        children: currencies.map((currency) => ListTile(
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
                    label: Text('Message'),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
