import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/category_button.dart';
import 'package:money_minder/components/categories_page/category_helper.dart';
import 'package:money_minder/repositories/budget_repositories.dart';

import '../../repositories/transactions_repositories.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/app_message.dart';
import 'color_selector.dart';
import 'icon_selector.dart';

class AddCategoryPage extends StatefulWidget {

  final CategoryProp prop;
  final List<CategoryProp> categories;
  final Future<void> Function() onCategoryReload;
  final Future<void> Function() onTransactionReload;
  final Future<void> Function() onBudgetReload;

  const AddCategoryPage({
    super.key,
    required this.prop,
    required this.categories,
    required this.onCategoryReload,
    required this.onTransactionReload,
    required this.onBudgetReload,
  });

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {

  bool showEmptyError = false;
  bool showLengthError = false;
  late bool isEditing = !widget.prop.isAddButton;
  late CategoryProp prop = widget.prop;
  late String name = isEditing ? widget.prop.label : "";
  late int selectedColorValue = isEditing ? widget.prop.color.toARGB32() : 0xFFA2AADB;
  late int selectedCodePoint = isEditing ? widget.prop.icon.icon!.codePoint : 0xe145;
  late bool isExpense = widget.prop.isExpense;
  late TextEditingController categoryNameController;

  Future<void> addCategory() async {

    // check if the name is empty
    if (name == "") {
      setState(() {
        showEmptyError = true;
      });
      AppMessage.showMessage(context, 'The Category Name is Empty!');
      return;
    }

    // error unhandled
    if (showLengthError) {
      AppMessage.showMessage(context, 'The Category Name Exceed Limited Length!');
      return;
    }

    CategoryHelper.addCategory(
        prop.position, name, selectedCodePoint,
        selectedColorValue, isExpense);
    Navigator.pop(context);
    await widget.onCategoryReload();
  }

  Future<void> editCategory() async {
    // check if the name is empty
    if (name == "") {
      setState(() {
        showEmptyError = true;
      });
      AppMessage.showMessage(context, 'The Category Name is Empty!');
      return;
    }

    // error unhandled
    if (showLengthError) {
      AppMessage.showMessage(context, 'The Category Name Exceed Limited Length!');
      return;
    }

    CategoryHelper.updateCategory(
        prop.id, name, selectedCodePoint, selectedColorValue, isExpense);
    Navigator.pop(context);
    Navigator.pop(context);
    await widget.onCategoryReload();
  }

  Future<void> deleteCategory() async {

    Navigator.pop(context); // pop alert dialog
    Navigator.pop(context); // pop add category page
    Navigator.pop(context); // pop category card

    // delete the category
    await CategoryHelper.deleteCategory(prop.id, prop.position, widget.categories);

    // delete relevant transactions
    await TransactionsRepositories.instance.deleteTransactionByCategoryId(prop.id);

    // delete relevant budgets
    await BudgetRepositories.instance.deleteBudgetById(prop.id);

    // fetch new data
    await widget.onCategoryReload();
    await widget.onTransactionReload();
    await widget.onBudgetReload();
  }

  @override
  void initState() {
    super.initState();
    // Initialize the controller ONCE in initState
    categoryNameController = TextEditingController(text: name);
    // Add a listener to update the state variable whenever the text changes
    categoryNameController.addListener(_updateCategoryLabel);
  }

  @override
  void dispose() {
    categoryNameController.removeListener(_updateCategoryLabel); // Remove listener first
    categoryNameController.dispose();
    super.dispose();
  }

  // Helper method to update the state variable from the controller
  void _updateCategoryLabel() {
    setState(() {
      if (categoryNameController.text.length > 30) {
        categoryNameController.text = name;
        showLengthError = true;
        return;
      }
      name = categoryNameController.text;
      showEmptyError = false;
      showLengthError = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
      child: SizedBox(
          height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.8 : 0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(selectedColorValue)
                    ),
                    child: Icon(
                      IconData(selectedCodePoint, fontFamily: "MaterialSymbolsOutlined"),
                      size: 30,
                      color: AppColor.lightIcon,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        errorText: showEmptyError
                            ? "Category Name cannot be empty!"
                            : showLengthError
                            ? "Category Name is too long!"
                            : "",
                        prefix: TextButton(
                          onPressed: () {
                            setState(() {
                              isExpense = !isExpense;
                            });
                          },
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(
                              fontSize: 20,
                              color: AppColor.darkText,
                            )
                          ),
                          child: Text(isExpense ? "Exp. " : "Inc. "),
                        ),
                        hintText: 'Category Name...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSize.borderRadius),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColor.primary,
                        contentPadding: EdgeInsets.all(0),
                      ),
                      style: const TextStyle(fontSize: 20),
                      controller: categoryNameController,
                    ),
                  )
                ]
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.borderRadius),
                    border: Border.all(
                      color: AppColor.darkText,
                      width: 2,
                    ),
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      backgroundColor: AppColor.secondary,
                      appBar: TabBar(
                        tabs: <Widget>[
                          Tab(text: 'Icon'),
                          Tab(text: 'Color'),
                        ]
                      ),
                      body: TabBarView(
                        children: [
                          IconSelector(
                            changeIcon: (int newCodePoint) {
                              setState(() {
                                selectedCodePoint = newCodePoint;
                              });
                            },
                            codePoint: selectedCodePoint,
                          ),
                          ColorSelector(
                            changeColor: (int newColorValue) {
                              setState(() {
                                selectedColorValue = newColorValue;
                              });
                            },
                            colorValue: selectedColorValue,
                          ),
                        ]
                      )
                    )
                  )
                )
              ),
              isEditing ? SizedBox.shrink() : MaterialButton(
                  onPressed: addCategory,
                  color: Color(selectedColorValue),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            name == "" ? "Add Category" : "Add $name",
                            overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: AppSize.smallPadding),
                        Icon(IconData(selectedCodePoint, fontFamily: "MaterialSymbolsOutlined")),
                      ]
                  )
              ),
              !isEditing ? SizedBox.shrink() : MaterialButton(
                  onPressed: editCategory,
                  color: Color(selectedColorValue),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(name == "" ? "Edit Category" : "Change to $name"),
                        SizedBox(width: AppSize.smallPadding),
                        Icon(IconData(selectedCodePoint, fontFamily: "MaterialSymbolsOutlined")),
                      ]
                  )
              ),
              !isEditing ? SizedBox.shrink() : MaterialButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text("Delete Category"),
                              content: Text("Relevant transactions and budget will also be deleted."
                                  "This action is irreversible."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: deleteCategory,
                                  child: Text("Delete"),
                                ),
                              ]
                          );
                        }
                    );
                  },
                  color: Colors.redAccent,
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(name == "" ? "Delete Category" : "Delete $name"),
                        SizedBox(width: AppSize.smallPadding),
                        Icon(Icons.delete),
                      ]
                  )
              ),
            ],
          )
        // child: Center(child: Text("Add Category"))
      ),
    );
  }
}
