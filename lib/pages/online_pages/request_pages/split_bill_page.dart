import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/models/online/user.dart' as model;
import 'package:money_minder/style/app_size.dart';

import '../../../components/search_users/contact_user_search_page.dart';
import '../../../firestore_repositories/transaction_request_repositories.dart';
import '../../../firestore_repositories/users_repositories.dart';
import '../../../models/currency.dart';
import '../../../models/online/transaction_request.dart';
import '../../../repositories/currency_repositories.dart';
import '../../../utils/app_message.dart';

enum SplitType {
  custom,
  even,
  ratio,
}

class SplitBillPage extends StatefulWidget {
  const SplitBillPage({super.key, required this.myself,});

  final model.User myself;

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
  bool _isIncludeMyself = false;

  Currency _currency = Currency.of('sgd');
  final List<Currency> _currencies = Currency.currencies;
  final List<Color> _borderColors = [Colors.deepPurple, Colors.indigo, Colors.green, Colors.blue, Colors.pink, Colors.orange,];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMainCurrency();
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
        if (mounted) {
          AppMessage.showMessage(context, 'Please select a user.');
          return;
        }
      }
      if (amountController.text.isEmpty || _totalController.text.isEmpty) {
        if (mounted) {
          AppMessage.showMessage(context, 'Please fill in an amount');
          return;
        }
      }
      double amount = double.parse(amountController.text);
      double total = double.parse(_totalController.text);
      if (amount <= 0 && mounted) {
        AppMessage.showMessage(context, 'Amount must be greater than 0');
        return;
      }
      if (amount > 99999999999.99 || total > 99999999999.99) {
        if (mounted) {
          AppMessage.showMessage(context, 'Amount is too large!');
        }
        return;
      }

      final receiverRef = UsersRepositories.instance.getUserReference(
          targetUser!.uid);

      final res = await receiverRef.get();
      if (res.data() == null) {
        if (mounted) {
          AppMessage.showMessage(context, '@${targetUser.username} not found');
        }
        setState(() {
          _isLoading = false;
        });
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

  void _fetchMainCurrency() async {
    final res = await CurrencyRepositories.instance.getMainCurrency();
    setState(() {
      _currency = res;
    });
  }


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
                  leading: Icon(Icons.attach_money, size: AppSize.bigIcon.sp,),
                  // Placeholder icon
                  title: Text('Currency', style: TextStyle(fontSize: 16.sp),),
                  subtitle: Text(_currency.fullName, style: TextStyle(fontSize: 14.sp),),
                  trailing: Icon(Icons.chevron_right, size: AppSize.bigIcon.sp,),
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
                  leading: Icon(Icons.description_outlined, size: AppSize.bigIcon.sp),
                  title: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      label: Text('Group Message', style: TextStyle(fontSize: 16.sp),),
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.splitscreen_rounded, size: AppSize.bigIcon.sp,),
                  // Placeholder icon
                  title: Text('Split Type', style: TextStyle(fontSize: 16.sp),),
                  subtitle: Text(_splitType.name[0].toUpperCase() + _splitType.name.substring(1), style: TextStyle(fontSize: 14.sp),),
                  trailing: Icon(Icons.chevron_right, size: AppSize.bigIcon.sp,),
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
                ListTile(
                  leading: Icon(Icons.person, size: AppSize.bigIcon.sp,),
                  title: Text('Include Myself', style: TextStyle(fontSize: 16.sp),),
                  trailing: Switch(
                    value: _isIncludeMyself,
                    onChanged: (value) {
                      setState(() {
                        _isIncludeMyself = value;
                        if (!_isIncludeMyself) {
                          _users.removeAt(0);
                          _amountControllers.removeAt(0);
                          _ratioControllers.removeAt(0);
                        } else {
                          _users.insert(0, widget.myself);
                          final c = TextEditingController(text: '0.00');
                          final r = TextEditingController(text: '1');
                          r.addListener(calculateSplit);
                          c.addListener(calculateTotal);
                          _amountControllers.insert(0, c);
                          _ratioControllers.insert(0, r);
                        }
                        _splitType == SplitType.custom ? calculateTotal() : calculateSplit();
                      });
                    },
                  )
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recipients', style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w600),),
                ),
                SizedBox(height: 8.h,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 8.h,),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Total: ${_currency.toString()} ', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),),
                            _splitType == SplitType.custom
                                ? Text(_totalController.text.toString(), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),)
                                : SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.3,
                                    child: TextField(
                                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500,color: Colors.black87),
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
                                        } else {
                                          _totalController.text = double.parse(_totalController.text).toStringAsFixed(2);
                                        }
                                        FocusScope.of(context).unfocus();
                                      },

                                    ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8.h,
                          children: _users.indexed.map((item) {
                            final model.User? user = item.$2;
                            final index = item.$1;
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: _borderColors[index % _borderColors.length]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0.r),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      children: [
                                        Center(child: Text(_isIncludeMyself && index == 0 ? 'Myself' : 'Recipient ${index+1}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),)),
                                        _users.length == 1 && index == 0 || _isIncludeMyself && index == 0  || _isIncludeMyself && _users.length == 2 && index == 1 ? Container() :
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(0, 0, 12.w, 0),
                                            child: SizedBox(
                                              width: 30.w,
                                              height: 30.h,
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
                                                icon: Icon(Icons.remove, size: 30.sp,),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.person_outline, size: AppSize.bigIcon.sp,),
                                      title: Text('To: ${user == null ? 'Select a user' : '@${user.username}'}', style: TextStyle(fontSize: 18.sp),),
                                      trailing: _isIncludeMyself && index == 0 ? SizedBox.shrink() : IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context) =>
                                                    ContactUserSearchPage(onUserSelection: (user) => onUsernameSelection(user, index))));
                                          },
                                          icon: Icon(Icons.search, size: AppSize.bigIcon.sp,)
                                      ),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.attach_money_outlined, size: AppSize.bigIcon.sp,),
                                      title: Text('Amount', style: TextStyle(fontSize: 18.sp),),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_currency.toString(), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            child: TextField(
                                              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, color: Colors.black87),
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
                                                } else {
                                                  _amountControllers[index].text = double.parse(_amountControllers[index].text).toStringAsFixed(2);
                                                }
                                                FocusScope.of(context).unfocus();
                                              },

                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _splitType != SplitType.ratio ?  SizedBox.shrink() : ListTile(
                                      leading: Icon(Icons.horizontal_split_outlined, size: AppSize.bigIcon.sp,),
                                      title: Text('Ratio', style: TextStyle(fontSize: 18.sp),),
                                      trailing: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        child: TextField(
                                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, color: Colors.black87),
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
                                              _ratioControllers[index].text = '1';
                                            }
                                            FocusScope.of(context).unfocus();
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
                        SizedBox(height: 8.h,),
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
                              Text('Add Recipient', style: TextStyle(fontSize: 16.sp),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _isLoading ? CircularProgressIndicator() :
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text('Send', style: TextStyle(fontSize: 16.sp),),
                ),
              ]
            ),
          ),
        )
      )
    );
  }
}
