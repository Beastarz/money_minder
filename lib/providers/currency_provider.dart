import 'package:flutter/material.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/repositories/currency_repositories.dart';

class CurrencyProvider with ChangeNotifier {
  List<Currency> _currencies = [];
  Currency _mainCurrency = Currency.of('sgd');

  List<Currency> get currencies => _currencies;
  Currency get mainCurrency => _mainCurrency;

  CurrencyRepositories currencyRepositories = CurrencyRepositories();

  Future<void> fetchCurrencies() async {
    try {
      _currencies = await currencyRepositories.getCurrencies();
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMainCurrency() async {
    try {
      _mainCurrency = await currencyRepositories.getMainCurrency();
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }
}