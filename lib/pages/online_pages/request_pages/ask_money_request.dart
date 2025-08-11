import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/components/search_users/contact_user_search_page.dart';
import 'package:money_minder/firestore_repositories/transaction_request_repositories.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/models/online/user.dart' as model;
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/style/app_size.dart';
import 'package:money_minder/utils/loading_screen.dart';

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

  bool _isSubmitting = false;
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
      _isSubmitting = true;
    });
    final receiverRef = UsersRepositories.instance.getUserReference(_targetUser!.uid);
    final senderRef = UsersRepositories.instance.getUserReference(FirebaseAuth.instance.currentUser!.uid);

    final res = await receiverRef.get();
    if (res.data() == null) {
      if (mounted) {
        AppMessage.showMessage(context, 'User not found');
      }
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

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
        _isSubmitting = false;
      });
    }
  }

  void _fetchMainCurrency() async {
    setState(() {
      _isLoading = true;
    });
    final res = await CurrencyRepositories.instance.getMainCurrency();
    setState(() {
      _currency = res;
      _isLoading = false;
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
          child: _isLoading ? LoadingScreen() : Column(
            children: [
              Card(
                color: AppColor.secondary,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.0.h, vertical: 16.0.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Amount', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_currency.toString(), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: TextField(
                              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
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
                                } else {
                                  _amountController.text = double.parse(_amountController.text).toStringAsFixed(2);
                                }
                                FocusScope.of(context).unfocus();
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
                leading: Icon(Icons.person_outline, size: AppSize.bigIcon.sp,),
                title: Text('To: ${_targetUser == null ? 'Select a user' : '@${_targetUser!.username}'}', style: TextStyle(fontSize: 18.sp),),
                trailing: IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUserSearchPage(onUserSelection: onUsernameSelection)));
                    },
                    iconSize: AppSize.bigIcon.sp,
                    icon: Icon(Icons.search)
                ),
              ),
              ListTile(
                leading: Icon(Icons.attach_money, size: AppSize.bigIcon.sp,),
                // Placeholder icon
                title: Text('Currency', style: TextStyle(fontSize: 16.sp),),
                subtitle: Text(_currency.fullName, style: TextStyle(fontSize: 14.sp),),
                trailing: Icon(Icons.chevron_right, size: AppSize.bigIcon.sp,),
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
                leading: Icon(Icons.description_outlined, size: AppSize.bigIcon.sp,), // Placeholder icon
                title: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    label: Text('Message', style: TextStyle(fontSize: 16.sp),),
                  ),
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
              SizedBox(height: 16.h),
              _isSubmitting ? CircularProgressIndicator() :
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text('Send', style: TextStyle(fontSize: 16.sp),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
