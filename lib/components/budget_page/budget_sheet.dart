import 'package:flutter/material.dart';

import '../../models/currency.dart';
import '../../style/app_size.dart';
import '../input_form_sheet/input_form.dart';
import '../input_form_sheet/input_form_helper.dart';
import '../input_form_sheet/input_form_sheet.dart';
import '../input_form_sheet/top_card.dart';
import 'budget_button.dart';
import 'budget_helper.dart';
import 'budget_tile.dart';
import 'main_budget_tile.dart';

class BudgetSheet extends StatefulWidget {

  final String type;
  final List<List<List<BudgetTileProp>>> props;
  final List<double> totalAmounts;
  final Currency mainCurrency;
  final DateTime startDate;

  const BudgetSheet({
    super.key,
    required this.type,
    required this.props,
    required this.totalAmounts,
    required this.mainCurrency,
    required this.startDate,
  });

  @override
  State<BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends State<BudgetSheet> {
  double getTotalBudget(int index) {
    double total = 0;
    for (BudgetTileProp prop in widget.props[index][1]) {
      total += prop.budget;
    }
    return total;
  }

  void budgetOnPressed(BudgetTileProp prop) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    final double titleSize = (isSmallScreen ? AppSize.heading3 : AppSize.heading1) * 1.5;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          return InputFormSheet(
            // Define the button layout as seen in the image
            inputForm: InputForm(
              buttonProps: InputFormHelper.convertToCalButProps([
                '÷', '7', '8', '9', 'C',
                'x', '4', '5', '6', '<',
                '-', '1', '2', '3', 'budget',
                '+', '\$', '0', '.',
              ], {
                '<': Icons.backspace_outlined,
                'budget': Icons.scale_outlined,
                '✓': Icons.check,
              }
              ),
              showNotes: false,
              defaultValue: prop.budget,
              mainCurrency: prop.mainCurrency,
            ),
            topContent: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSize.borderRadius)
                ),
              ),
              child: Row(
                  children: [
                    TopCard(
                      width: MediaQuery.of(context).size.width,
                      topRight: true,
                      topLeft: true,
                      title: Text(
                        prop.label,
                        style: TextStyle(
                          fontSize: titleSize,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      content: MainBudgetTile(
                        prop: BudgetTileProp(
                          label: BudgetHelper.generateMonthYearText(widget.startDate),
                          color: prop.color,
                          actualAmount: prop.actualAmount,
                          budget: prop.budget,
                          type: prop.type,
                          isCircleBorder: prop.isCircleBorder,
                          mainCurrency: prop.mainCurrency,
                        ),
                        isCurve: false,
                        textWidth: MediaQuery.of(context).size.width * 0.45,
                      ),
                      backgroundColor: prop.color,
                      icon: Icon(
                        prop.iconData,
                        size: AppSize.bigIcon,
                      ),
                      isTappable: false,
                      // cannot be pressed
                      onPressed: null,
                    )
                  ]
              ),
            ),
            showNotes: false,
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    final int index = widget.type == "Expenses" ? 0 : widget.type == "Savings" ? 1 : 2;
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    BudgetTileProp mainBudgetTileProp = BudgetTileProp(
        label: widget.type,
        color: BudgetHelper.colorMap[widget.type]!,
        actualAmount: widget.totalAmounts[index],
        budget: getTotalBudget(index),
        type: widget.type,
        isCircleBorder: widget.type != "Savings",
        mainCurrency: widget.mainCurrency,
    );

    return Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children :[
          Padding(
          padding: EdgeInsets.only(top: AppSize.bigPadding),
          child: Column(
            children: [

              // main budget tile
              MainBudgetTile(
                prop: mainBudgetTileProp,
                textWidth: MediaQuery.of(context).size.width * 0.4,
              ),

              SizedBox(height: AppSize.smallPadding),

              // cat / acc with budget specified
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.props[index][1].length,
                itemBuilder: (context, i) {
                  return BudgetTile(
                      prop: widget.props[index][1][i],
                      topCurve: i == 0,
                      bottomCurve: i == widget.props[index][1].length - 1,
                      budgetOnPressed: budgetOnPressed,
                  );
                }
              ),

              widget.props[index][1].isEmpty
              ? SizedBox.shrink()
              : SizedBox(height: AppSize.bigPadding),

              // cat / acc without budget specified
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.8,
                    crossAxisCount: isSmallScreen ? 3 : 4,
                    crossAxisSpacing: 4.0,
                  ),
                  itemCount: widget.props[index][0].length,
                  itemBuilder: (context, i) {
                    return BudgetButton(
                        prop: widget.props[index][0][i],
                        budgetOnPressed: budgetOnPressed,
                        mainCurrency: widget.mainCurrency
                    );
                  },
              )
            ],
          ),
        ),
      ]
    );
  }
}