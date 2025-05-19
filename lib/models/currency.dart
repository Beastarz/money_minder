enum Currencies {
  sgd,
  myr,
}

abstract class Currency {
  static Currency of(String currency) {
    switch (currency.toLowerCase()) {
      case 'sgd':
        return _SGD();
      case 'myr':
        return _MYR();
      default:
        throw Exception('Unsupported currency: $currency');
    }
  }

  static double convert(Currency from, Currency to, double amount) {
    return from.convertTo(to, amount);
  }

  double convertTo(Currency currency, double amount) {
    return amount * rates[currency.currency().index];
  }

  List<double> get rates;
  Currencies currency();
  String get fullName;

  @override
  String toString() {
    return currency().name.toUpperCase();
  }
}

class _SGD extends Currency {
  @override
  List<double> rates = [1, 3.3];

  @override
  Currencies currency() {
    return Currencies.sgd;
  }

  @override
  String get fullName => 'Singapore Dollar --SGD';

}

class _MYR extends Currency {
  @override
  List<double> rates = [1/3.3, 1];

  @override
  Currencies currency() {
    return Currencies.myr;
  }

  @override
  String get fullName => 'Malaysia Ringgit --MYR';
}