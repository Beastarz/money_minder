import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/models/currency.dart';

import '../../repositories/currency_repositories.dart';
import '../../style/app_size.dart';

class CurrencySettingDialog extends StatefulWidget {
  const CurrencySettingDialog({super.key, required this.onReload});

  final Function() onReload;

  @override
  State<CurrencySettingDialog> createState() => _CurrencySettingDialogState();
}

class _CurrencySettingDialogState extends State<CurrencySettingDialog> {
  List<MapEntry<String, String>> currencies = Currency.currencyToFullName.entries.toList();
  Currency _selectedCurrency = Currency.of('sgd');

  @override
  void initState() {
    super.initState();
    _fetchMainCurrency();
  }

  Future<void> _fetchMainCurrency() async {
    Currency res = await CurrencyRepositories.instance.getMainCurrency();
    setState(() {
      _selectedCurrency = res;
    });
  }

  Future<void> _setMainCurrency(Currency currency) async {
    await CurrencyRepositories.instance.setMainCurrency(currency);
    widget.onReload();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              Icon(Icons.currency_exchange_outlined),
              Text('Main Currency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp)),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                value: _selectedCurrency.name,
                onChanged: (String? newCurrency) {
                  newCurrency ??= 'sgd';
                  setState(() {
                    _selectedCurrency = Currency.of(newCurrency!);
                  });
                  _setMainCurrency(_selectedCurrency);
                },
                borderRadius: BorderRadius.circular(AppSize.borderRadius),
                menuMaxHeight: MediaQuery.of(context).size.height * 0.6,
                items: List.generate(currencies.length, (index) {
                  return DropdownMenuItem<String>(
                    value: currencies[index].key,
                    child: Text(
                      currencies[index].value,
                    ),
                  );
                }).toList()
            ),
          )
        ],
      )
    );
  }
}
