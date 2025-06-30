import 'package:flutter/material.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/style/app_color.dart';

import '../../repositories/currency_repositories.dart';

class CurrencySettingPage extends StatefulWidget {
  const CurrencySettingPage({super.key, required this.onReload});

  final Function() onReload;

  @override
  State<CurrencySettingPage> createState() => _CurrencySettingPageState();
}

class _CurrencySettingPageState extends State<CurrencySettingPage> {
  List<Currency> currencies = [];

  @override
  void initState() {
    super.initState();
    _fetchAllCurrency();
  }

  Future<Currency> _fetchMainCurrency() async {
    Currency res = await CurrencyRepositories.instance.getMainCurrency();
    return res;
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
    return FutureBuilder(
      future: _fetchMainCurrency(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Currency'),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Main Currency'),
                    trailing: Text(snapshot.data!.currency().name.toUpperCase(), style: TextStyle(fontSize: 16),),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Text('Select a currency'),
                            children: currencies.map((currency) {
                              return ListTile(
                                onTap: () {
                                  _setMainCurrency(currency);
                                  Navigator.pop(context);
                                },
                                title: Text(currency.currency().name.toUpperCase()),
                                selected: currency == snapshot.data,
                                selectedTileColor: AppColor.secondary,
                              );
                            }).toList(),
                          );
                        }
                      );
                    }
                  )
                ],
              )
            )
          );
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }
}
