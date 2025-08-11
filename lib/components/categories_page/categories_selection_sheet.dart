import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/repositories/category_repositories.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class CategoriesSelectionSheet extends StatefulWidget {
  const CategoriesSelectionSheet({super.key, required this.onSelect, required this.isExpense});

  final bool isExpense;
  final void Function(Category) onSelect;

  @override
  State<CategoriesSelectionSheet> createState() => _CategoriesSelectionSheetState();
}

class _CategoriesSelectionSheetState extends State<CategoriesSelectionSheet> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  _fetchCategories() async {
    List<Category> res = await CategoryRepositories.instance.getCategoriesByType(widget.isExpense);
    setState(() {
      categories = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(AppSize.smallPadding.sp),
                          child: Text(
                              'Select Category',
                              style: TextStyle(
                                fontSize: AppSize.heading1.sp,
                              )
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ListView(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: [

                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 8, 0),
                    child: Text(
                      widget.isExpense ? 'Expenses' : 'Incomes',
                      style: TextStyle(
                        fontSize: AppSize.heading2.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey[700],
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 4,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    childAspectRatio: 0.8,
                    children: categories.map((expense) => Column(
                      children: [
                        IconButton(
                          icon: MainIcon(icon: expense.icon, color: expense.color),
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onSelect(expense);
                          },
                        ),
                        Text(expense.name, style: TextStyle(fontSize: 12.sp),)
                      ],
                    )).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
