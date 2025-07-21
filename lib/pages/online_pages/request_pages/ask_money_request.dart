import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_minder/components/search_users/contact_user_search_page.dart';
import 'package:money_minder/firestore_repositories/transaction_request_repositories.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/models/online/user.dart' as model;
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:money_minder/style/app_color.dart';

import '../../../models/currency.dart';
import '../../../utils/app_message.dart';


class AskMoneyPage extends StatefulWidget {
  const AskMoneyPage({super.key, this.defaultUser});

  final model.User? defaultUser;

  @override
  State<AskMoneyPage> createState() => _AskMoneyPageState();
}

class _AskMoneyPageState extends State<AskMoneyPage> {
  model.User? _targetUser;
  final List<Currency> _currencies = Currency.currencies;
  Currency _currency = Currency.of('SGD');
  final TextEditingController _amountController = TextEditingController(text: '0.00');
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;


  void _handleSubmit() async {
    if (_targetUser == null) {
      AppMessage.showMessage(context, 'Please select a user.');
      return;
    }
    if (_amountController.text.isEmpty) {
      AppMessage.showMessage(context, 'Please fill in an amount');
      return;
    }
    double amount = double.parse(_amountController.text);
    if (amount <= 0) {
      AppMessage.showMessage(context, 'Amount must be greater than 0');
      return;
    }
    if (amount > 99999999999.99) {
      AppMessage.showMessage(context, 'Amount is too large!');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final receiverRef = UsersRepositories.instance.getUserReference(_targetUser!.uid);
    final senderRef = UsersRepositories.instance.getUserReference(FirebaseAuth.instance.currentUser!.uid);

    Map<String, dynamic> map = TransactionRequest.submitAsMap(sender: senderRef, receiver: receiverRef, amount: amount, currency: _currency, message: _messageController.text, requestType: TransactionRequestType.ask);

    try {
      await TransactionRequestRepositories.instance.submitTransactionRequest(map);
      if (mounted) {
        Navigator.pop(context);
        AppMessage.showMessage(context, 'Sent successfully');
      }
    } catch (e) {
      if (mounted) {
        AppMessage.showMessage(context, 'error');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchMainCurrency() async {
    final res = await CurrencyRepositories.instance.getMainCurrency();
    setState(() {
      _currency = res;
    });
  }

  void onUsernameSelection(model.User user) => setState(() => _targetUser = user);

  @override
  void initState() {
    super.initState();
    _fetchMainCurrency();
    _targetUser = widget.defaultUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask Money'),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_currency.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: TextField(
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                              controller: _amountController,
                              textAlign: TextAlign.end,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onTap: () {
                                if (_amountController.text.isNotEmpty && double.parse(_amountController.text) == 0) {
                                  _amountController.text = '';
                                }
                              },
                              onEditingComplete: () {
                                if (_amountController.text.isEmpty || double.parse(_amountController.text) == 0) {
                                  _amountController.text = '0.00';
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('To: ${_targetUser == null ? 'Select a user' : '@${_targetUser!.username}'}', style: TextStyle(fontSize: 18),),
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
                    label: Text('Message'),
                  ),
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
              SizedBox(height: 16),
              _isLoading ? CircularProgressIndicator() :
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
