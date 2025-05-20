import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];
  double _selectedAccountBalance = 0.0;

  List<Account> get accounts => _accounts;
  double get selectedAccountBalance => _selectedAccountBalance;

  final AccountsRepository _accountsRepository = AccountsRepository();

  Future<void> fetchAccounts() async {
    try {
      _accounts = await _accountsRepository.getAllAccounts();
    } catch (e) {
      _accounts = [];
      print('Error fetching accounts: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchSelectedAccountBalance() async {
    try {
      _selectedAccountBalance = await _accountsRepository.getSelectedAccountBalance();
    } catch (e) {
      _selectedAccountBalance = 0.0;
      print('Error fetching selected account balance: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> addAccount(Map<String, dynamic> account) async {
    try {
      await _accountsRepository.createAccount(account);
      fetchAccounts();
    } catch (e) {
      print('Error adding account: $e');
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _accountsRepository.updateAccount(account);
      fetchAccounts();
    } catch (e) {
      print('Error updating account: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateAccountPosition(List<Account> accounts) async {
    try {
      await _accountsRepository.updateAccountPosition(accounts);
      fetchAccounts();
    } catch (e) {
      print('Error updating account position: $e');
    }
  }

  Future<void> updateSelectedAccount(List<int> selectedAccount) async {
    try {
      List<Account> res = await _accountsRepository.getAllAccounts();
      for (Account account in res) {
        if (selectedAccount.contains(account.id)) {
          account = account.copyWith(isIncludesInTotal: true);
        } else {
          account = account.copyWith(isIncludesInTotal: false);
        }
        await _accountsRepository.updateAccount(account);
      }
      fetchSelectedAccountBalance();
      fetchAccounts();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateMainAccount(Account account) async {
    try {
      await _accountsRepository.updateMainAccount(account);
      fetchAccounts();
    } catch (e) {
      print('Error updating main account: $e');
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await _accountsRepository.deleteAccount(id);
    } catch (e) {
      print('Error deleting account: $e');
    } finally {
      fetchAccounts();
    }
  }
}