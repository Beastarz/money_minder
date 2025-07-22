import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/currency.dart';

void main() {
  group('Currency', () {
    test('constructor should create instance for sgd currency', () {
      final currency = Currency.of('sgd');
      expect(currency, isA<Currency>());
    });

    test('constructor should create instance for myr currency', () {
      final currency = Currency.of('myr');
      expect(currency, isA<Currency>());
    });

    test('constructor should return sgd for unknown currency', () {
      expect(Currency.of('unknown'), Currency.of('SGD'));
    });

    test('convert should correctly convert amount in sgd to myr', () {
      final sgd = Currency.of('sgd');
      final myr = Currency.of('myr');
      final double amount = 100;
      final convertedAmount = Currency.convert(sgd, myr, amount);
      expect(convertedAmount, closeTo(330, 1));
    });

    test('convert should correctly convert amount in myr to sgd', () {
      final sgd = Currency.of('sgd');
      final myr = Currency.of('myr');
      final double amount = 330;
      final convertedAmount = Currency.convert(myr, sgd, amount);
      expect(convertedAmount, closeTo(100, 1));
    });

    test('fullName should return correct name for sgd currency', () {
      final currency = Currency.of('sgd');
      expect(currency.fullName, 'Singapore Dollar -- SGD');
    });
  });
}