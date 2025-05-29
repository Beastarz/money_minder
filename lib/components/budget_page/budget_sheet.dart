import 'package:flutter/material.dart';

import '../categories_page/categories_button.dart';
import '../categories_page/categories_page_helper.dart';

class BudgetSheet extends StatefulWidget {

  final bool isExpense;

  const BudgetSheet({
    super.key,
    required this.isExpense,
  });

  @override
  State<BudgetSheet> createState() => _BudgetSheetState();
}


class _BudgetSheetState extends State<BudgetSheet> {

  late Future<List<CategoryButtonProps>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the database and then fetch categories
    // _categoriesFuture = CategoriesPageHelper.
    //   getCategoriesListByType(widget.isExpense);
  }

  @override
  void didUpdateWidget(covariant BudgetSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the isExpense property has changed
    if (widget.isExpense != oldWidget.isExpense) {
      // If it has changed, re-fetch the categories and update the future
      setState(() {
        // _categoriesFuture = CategoriesPageHelper.
        //   getCategoriesListByType(widget.isExpense);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //   return FutureBuilder<List<CategoryButtonProps>>(
    //       future: _categoriesFuture,
    //       builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       // Data is still loading, show a progress indicator
    //       return const Center(child: CircularProgressIndicator());
    //     } else if (snapshot.hasError) {
    //       // An error occurred
    //       return Center(child: Text('Error: ${snapshot.error}'));
    //     } else if (snapshot.hasData) {
    //       // Data has been successfully loaded!
    //       final List<CategoryButtonProps> categories = snapshot.data!;
    //
    //       if (categories.isEmpty) {
    //         return const Center(child: Text('No categories found.'));
    //       }
    //       return Center(
    //         child: Column(
    //           children: categories.map((category) {
    //             return Text(category.label);
    //           }).toList()
    //         ),
    //       );
    //     } else {
    //       return const Center(child: Text("No data available"));
    //     }
    //   }
    // );
    return Container();
  }
}