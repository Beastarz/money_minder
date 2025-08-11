import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/components/categories_page/category_button.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
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
        _widgetHeight = (renderBox.size.height).h;
        _widgetWidth = (renderBox.size.width).w;
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
    _getSizeAndPosition();

    double fraction = widget.prop.budget <= 0
        ? 0.02
        : widget.prop.actualAmount / widget.prop.budget;
    fraction = fraction.clamp(0.03, 1.00);
    Color leftColor = CategoryHelper.lightenColor(widget.prop.color, 0.75);
    Color rightColor = CategoryHelper.lightenColor(widget.prop.color, 0.9);
    final double balance = widget.prop.isExpense
        ? widget.prop.budget - widget.prop.actualAmount
        : widget.prop.actualAmount - widget.prop.budget;
    final bool exceed = balance < 0 && widget.prop.budget != 0;

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
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 5.w),
              leading: Container(
                padding: EdgeInsets.all(5.w),
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
              subtitle: widget.prop.budget <= 0 ? null : BalanceText(
                balance: balance,
                currencyName: widget.mainCurrency.toString(),
                mainAxisAlignment: MainAxisAlignment.start,
                showColor: true,
                size: 14,
                fontColor: widget.prop.color,
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BalanceText(
                    balance: widget.prop.actualAmount,
                    currencyName: "${widget.prop.isExpense ? 'Exp.' : 'Rec.'} ${widget.mainCurrency}",
                    mainAxisAlignment: MainAxisAlignment.end,
                    size: 18,
                    fontColor: exceed
                        ? AppColor.darkText
                        : widget.prop.color,
                    fillColor: exceed
                        ? widget.prop.color
                        : Colors.transparent,
                  ),
                  widget.prop.budget > 0
                  ? BalanceText(
                    balance: widget.prop.budget,
                    currencyName: "budgeted ${widget.mainCurrency}",
                    mainAxisAlignment: MainAxisAlignment.end,
                    size: 16,
                  )
                  : SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



