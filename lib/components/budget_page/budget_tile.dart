import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/category_button.dart';

import '../../models/currency.dart';
import '../../utils/balance_text.dart';
import '../categories_page/category_helper.dart';

class BudgetTile extends StatefulWidget {

  final CategoryProp prop;
  final Currency mainCurrency;
  final bool isCurve;
  final void Function()? onPressed;

  const BudgetTile({
    super.key,
    required this.prop,
    required this.mainCurrency,
    this.isCurve = false,
    this.onPressed,
  });

  @override
  State<BudgetTile> createState() => _BudgetTileState();
}

class _BudgetTileState extends State<BudgetTile> {

  final GlobalKey _myWidgetKey = GlobalKey();
  double? _widgetHeight;
  double? _widgetWidth;

  void _getSizeAndPosition() {
    if (_myWidgetKey.currentContext != null) {
      final RenderBox renderBox = _myWidgetKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _widgetHeight = renderBox.size.height;
        _widgetWidth = renderBox.size.width;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Add a post-frame callback to get the size after the widget is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSizeAndPosition();
    });
  }

  @override
  Widget build(BuildContext context) {

    final double borderRadius = 8;

    double fraction = widget.prop.budget <= 0
        ? 0.02
        : widget.prop.actualAmount / widget.prop.budget;
    fraction = fraction.clamp(0.03, 1.00);
    Color leftColor = CategoryHelper.lightenColor(widget.prop.color, 0.75);
    Color rightColor = CategoryHelper.lightenColor(widget.prop.color, 0.9);
    // double textWidth = MediaQuery.of(context).size.width * 0.4;

    return MaterialButton(
      onPressed: widget.onPressed,
      padding: EdgeInsets.zero,
      child: Container(
        key: _myWidgetKey,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(widget.isCurve ? borderRadius : 0),
            bottom: Radius.circular(widget.isCurve ? borderRadius : 0),
          ),
          color: rightColor,
        ),
        child: Stack(
          children: [

            Container(
              width: _widgetWidth == null ? 0 : _widgetWidth! * fraction,
              height: _widgetHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(borderRadius),
                  bottom: Radius.circular(borderRadius),
                ),
                color: leftColor,
              ),
              child: Text(""),
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 5),
              leading: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape:  BoxShape.circle,
                  color: widget.prop.color,
                ),
                child: widget.prop.icon,
              ),
              title: Text(
                widget.prop.label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Text(
                '${widget.prop.isExpense ? 'Exp.' : 'Rec.'} ${widget.mainCurrency} ${widget.prop.actualAmount.toStringAsFixed(2)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.prop.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BalanceText(
                    balance: widget.prop.budget - widget.prop.actualAmount,
                    currencyName: widget.mainCurrency.toString(),
                    mainAxisAlignment: MainAxisAlignment.end,
                    showColor: true,
                    size: 18,
                    fontColor: widget.prop.isExpense ? Colors.redAccent : Colors.green
                  ),
                  BalanceText(
                    balance: widget.prop.budget,
                    currencyName: "budgeted ${widget.mainCurrency}",
                    mainAxisAlignment: MainAxisAlignment.end,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



