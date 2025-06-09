import 'package:flutter/material.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/models/transaction_filter.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:money_minder/style/app_color.dart';

import '../../models/account.dart';
import '../../models/category.dart';

class TransactionFilterPage extends StatefulWidget {
  const TransactionFilterPage({super.key, required this.filter, required this.onTransactionFilterChange});

  final void Function(List<int>, List<int>, List<TransactionType>, String) onTransactionFilterChange;
  final TransactionFilter filter;


  @override
  State<TransactionFilterPage> createState() => _TransactionFilterPageState();
}

class _TransactionFilterPageState extends State<TransactionFilterPage> {
  List<Account> accounts = [];
  List<Category> incomes = [];
  List<Category> expenses = [];

  List<int> selectedAccounts = [];
  List<int> selectedCategories = [];
  List<TransactionType> selectedTransactionTypes = [];
  TextEditingController notePrefixController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAccounts();
    selectedAccounts = widget.filter.accountIds;
    selectedCategories = widget.filter.categoryIds;
    selectedTransactionTypes = widget.filter.transactionTypes;
    notePrefixController.text = widget.filter.notePrefix;
  }

  void _fetchAccounts() async {
    List<Account> res = await AccountsRepository.instance.getAllAccounts();
    setState(() {
      accounts = res;
    });
  }

  void _fetchCategories() async {
    List<Category> exp = await CategoriesRepositories.instance
        .getCategoriesByType(true);
    List<Category> inc = await CategoriesRepositories.instance
        .getCategoriesByType(false);
    setState(() {
      incomes = inc;
      expenses = exp;
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                widget.onTransactionFilterChange(
                  selectedAccounts,
                  selectedCategories,
                  selectedTransactionTypes,
                  notePrefixController.text
                );
                Navigator.pop(context);
              },
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    color: AppColor.darkText,
                  ),
                  const SizedBox(width: 5,),
                  Text(
                      'Apply',
                      style: TextStyle(
                        color: AppColor.darkText,
                      )
                  ),
                ]
              ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Transaction Types'),
                    Wrap(
                      spacing: 12,
                      children: TransactionType.values.indexed.map((t) {
                        TransactionType type = t.$2;
                        int index = t.$1;
                        List<Color> typeColors = [Colors.red, Colors.lightGreen, Colors.grey];
                        return ChoiceChip(
                          label: Text(
                            type.name[0].toUpperCase() + type.name.substring(1),
                            style: TextStyle(
                              color: selectedTransactionTypes.contains(type) ? Colors.white : typeColors[index]
                            ),
                          ),
                          side: BorderSide(color: typeColors[index]),
                          checkmarkColor: Colors.white,
                          selectedColor: typeColors[index],
                          selected: selectedTransactionTypes.contains(type),
                          onSelected: (bool selected) {
                            setState(() {
                              selected ? selectedTransactionTypes.add(type) : selectedTransactionTypes.remove(type);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Accounts'),
                    Wrap(
                      spacing: 12,
                      children: accounts.map((account) {
                        return ChoiceChip(
                          label: Text(
                              account.name,
                            style: TextStyle(
                              color: selectedAccounts.contains(account.id) ? Colors.white : account.color,
                            )
                          ),
                          avatar: Icon(account.icon.icon, color: account.color,),
                          side: BorderSide(color: account.color),
                          selectedColor: account.color,
                          checkmarkColor: Colors.white,
                          selected: selectedAccounts.contains(account.id),
                          onSelected: (bool selected) {
                            setState(() {
                              selected ?  selectedAccounts.add(account.id) : selectedAccounts.remove(account.id);

                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Expenses'),
                    Wrap(
                      spacing: 12,
                      children: expenses.map((category) {
                        return ChoiceChip(
                          label: Text(
                              category.label,
                            style: TextStyle(
                              color: selectedCategories.contains(category.id) ? Colors.white : category.color,
                            )
                          ),
                          avatar: Icon(category.icon.icon, color: category.color,),
                          side: BorderSide(color: category.color),
                          checkmarkColor: Colors.white,
                          selectedColor: category.color,
                          selected: selectedCategories.contains(category.id),
                          onSelected: (bool selected) {
                            setState(() {
                              selected ? selectedCategories.add(category.id) : selectedCategories.remove(category.id);
                            });
                          },
                        );
                      }).toList()
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Incomes'),
                    Wrap(
                      spacing: 12,
                      children: incomes.map((category) {
                        return ChoiceChip(
                          label: Text(
                              category.label,
                              style: TextStyle(
                                color: selectedCategories.contains(category.id) ? Colors.white : category.color,
                              )
                          ),
                          avatar: Icon(category.icon.icon, color: category.color,),
                          side: BorderSide(color: category.color),
                          checkmarkColor: Colors.white,
                          selectedColor: category.color,
                          selected: selectedCategories.contains(category.id),
                          onSelected: (bool selected) {
                            setState(() {
                              selected ? selectedCategories.add(category.id) : selectedCategories.remove(category.id);
                            });
                          },
                        );
                      }).toList()
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Text('Notes'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        controller: notePrefixController,
                        decoration: InputDecoration(
                          labelText: 'Notes...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedAccounts.clear();
                      selectedCategories.clear();
                      selectedTransactionTypes.clear();
                      notePrefixController.clear();
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, color: Colors.red,),
                      Text('Clear', style: TextStyle(color: Colors.red),)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
