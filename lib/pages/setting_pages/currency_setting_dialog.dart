import 'package:flutter/material.dart';
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
  List<Currency> currencies = [];
  Currency _selectedCurrency = Currency.of('sgd');

  @override
  void initState() {
    super.initState();
    _fetchAllCurrency();
    _fetchMainCurrency();
  }

  Future<void> _fetchMainCurrency() async {
    Currency res = await CurrencyRepositories.instance.getMainCurrency();
    setState(() {
      _selectedCurrency = res;
    });
  }

  Future<void> _fetchAllCurrency() async {
    final res = await CurrencyRepositories.instance.getCurrencies();
    setState(() {
      currencies = res;
    });
  }

  Future<void> _setMainCurrency(Currency currency) async {
    await CurrencyRepositories.instance.setMainCurrency(currency);
    await _fetchAllCurrency();
    widget.onReload();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Main Currency'),
          DropdownButtonHideUnderline(
            child: DropdownButton<Currency>(
                value: _selectedCurrency,
                onChanged: (Currency? newCurrency) {
                  newCurrency = newCurrency ?? _selectedCurrency;
                  setState(() {
                    _selectedCurrency = newCurrency!;
                  });
                  _setMainCurrency(newCurrency);
                },
                borderRadius: BorderRadius.circular(AppSize.borderRadius),
                menuMaxHeight: 200.0, // Adjust as needed
                items: List.generate(currencies.length, (index) {
                  Currency currency = currencies[index];
                  return DropdownMenuItem<Currency>(
                    value: currency,
                    child: Text(
                      currency.currency().name.toUpperCase(),
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
