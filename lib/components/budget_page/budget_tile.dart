// import 'package:flutter/material.dart';
// import 'package:money_minder/utils/show_money.dart';
//
// import '../../models/currency.dart';
// import '../../style/app_color.dart';
// import '../../style/app_size.dart';
// import '../../utils/balance_text.dart';
// import 'budget_helper.dart';
//
// class BudgetTileProp {
//   final String label;
//   final Color color;
//   final double actualAmount;
//   final double budget;
//   final String type;
//   final bool isCircleBorder;
//   final Currency mainCurrency;
//   final IconData? iconData;
//
//   const BudgetTileProp({
//     required this.label,
//     required this.color,
//     required this.actualAmount,
//     required this.budget,
//     required this.type,
//     required this.isCircleBorder,
//     required this.mainCurrency,
//     this.iconData,
//   });
// }
//
// class BudgetTile extends StatefulWidget {
//
//   final BudgetTileProp prop;
//   final bool topCurve;
//   final bool bottomCurve;
//   final double textWidth;
//   final void Function(BudgetTileProp)? budgetOnPressed;
//
//   const BudgetTile({
//     super.key,
//     required this.prop,
//     required this.budgetOnPressed,
//     required this.textWidth,
//     this.topCurve = false,
//     this.bottomCurve = false,
//   });
//
//   @override
//   State<BudgetTile> createState() => _BudgetTileState();
// }
//
// class _BudgetTileState extends State<BudgetTile> {
//
//   final GlobalKey _myWidgetKey = GlobalKey();
//   double? _widgetHeight;
//   double? _widgetWidth;
//
//   void _getSizeAndPosition() {
//     if (_myWidgetKey.currentContext != null) {
//       final RenderBox renderBox = _myWidgetKey.currentContext!.findRenderObject() as RenderBox;
//       setState(() {
//         _widgetHeight = renderBox.size.height;
//         _widgetWidth = renderBox.size.width;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     // Add a post-frame callback to get the size after the widget is rendered
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _getSizeAndPosition();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final bool isSmallScreen  = MediaQuery.of(context).size.width <= 360;
//     final double topFactor = isSmallScreen ? 1.0 : 1.5;
//     final double bottomFactor = isSmallScreen ? 0.8 : 1.0;
//     final double borderRadius = 8;
//
//     double fraction = widget.prop.budget <= 0
//         ? 0.02
//         : widget.prop.actualAmount / widget.prop.budget;
//     fraction = fraction.clamp(0.03, 1.00);
//     Color leftColor = BudgetHelper.lightenColor(widget.prop.color, 0.75);
//     Color rightColor = BudgetHelper.lightenColor(widget.prop.color, 0.9);
//     // double textWidth = MediaQuery.of(context).size.width * 0.4;
//
//     return Container(
//       key: _myWidgetKey,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(widget.topCurve ? borderRadius : 0),
//           bottom: Radius.circular(widget.bottomCurve ? borderRadius : 0),
//         ),
//         color: rightColor,
//       ),
//       child: Stack(
//         children: [
//
//           Container(
//             width: _widgetWidth == null ? 0 : _widgetWidth! * fraction,
//             height: _widgetHeight,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(widget.topCurve ? borderRadius : 0),
//                 bottom: Radius.circular(widget.bottomCurve ? borderRadius : 0),
//               ),
//               color: leftColor,
//             ),
//             child: Text(""),
//           ),
//
//           MaterialButton(
//             onPressed: widget.budgetOnPressed == null
//               ? null
//               : () {
//                 widget.budgetOnPressed!(widget.prop);
//               },
//             padding: const EdgeInsets.all(0),
//             disabledColor: Colors.transparent,
//             disabledTextColor: AppColor.darkText,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(widget.topCurve ? borderRadius : 0),
//                   bottom: Radius.circular(widget.bottomCurve ? borderRadius : 0),
//                 )
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(AppSize.smallPadding),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 spacing: AppSize.smallPadding,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     spacing: 5,
//                     children: [
//                       widget.prop.iconData == null
//                       ? SizedBox.shrink()
//                       : Container(
//                         padding: const EdgeInsets.all(5),
//                         decoration: BoxDecoration(
//                           shape: widget.prop.isCircleBorder
//                             ? BoxShape.circle
//                             : BoxShape.rectangle,
//                           borderRadius: widget.prop.isCircleBorder
//                             ? null
//                             : BorderRadius.circular(borderRadius),
//                           color: widget.prop.color,
//                         ),
//                         child: Icon(
//                             widget.prop.iconData,
//                             color: AppColor.primary,
//                         ),
//                       ),
//                       Column(
//                         spacing: 5,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.prop.label,
//                             style: TextStyle(
//                               fontSize: AppSize.heading3 * topFactor,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           ShowMoney(
//                             mainCurrency: widget.prop.mainCurrency,
//                             amount: widget.prop.actualAmount,
//                             text: BudgetHelper.textMap[widget.prop.type]!,
//                             color: widget.prop.color,
//                             factor: bottomFactor,
//                             width: widget.textWidth * 0.75
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                   Column(
//                     spacing: 5,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       ShowMoney(
//                         mainCurrency: widget.prop.mainCurrency,
//                         amount: widget.prop.budget - widget.prop.actualAmount,
//                         text: "",
//                         color: widget.prop.color,
//                         factor: topFactor,
//                         isStart: false,
//                         width: widget.textWidth,
//                       ),
//                       ShowMoney(
//                         mainCurrency: widget.prop.mainCurrency,
//                         amount: widget.prop.budget,
//                         text: "budgeted",
//                         color: widget.prop.color,
//                         factor: bottomFactor,
//                         isStart: false,
//                         width: widget.textWidth,
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../utils/balance_text.dart';
import 'budget_helper.dart';

class BudgetTileProp {
  final String label;
  final Color color;
  final double actualAmount;
  final double budget;
  final String type;
  final bool isCircleBorder;
  final Currency mainCurrency;
  final IconData? iconData;

  const BudgetTileProp({
    required this.label,
    required this.color,
    required this.actualAmount,
    required this.budget,
    required this.type,
    required this.isCircleBorder,
    required this.mainCurrency,
    this.iconData,
  });
}

class BudgetTile extends StatefulWidget {

  final BudgetTileProp prop;
  final bool topCurve;
  final bool bottomCurve;
  final double textWidth;
  final void Function(BudgetTileProp)? budgetOnPressed;

  const BudgetTile({
    super.key,
    required this.prop,
    required this.budgetOnPressed,
    required this.textWidth,
    this.topCurve = false,
    this.bottomCurve = false,
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
    Color leftColor = BudgetHelper.lightenColor(widget.prop.color, 0.75);
    Color rightColor = BudgetHelper.lightenColor(widget.prop.color, 0.9);
    // double textWidth = MediaQuery.of(context).size.width * 0.4;

    return Container(
      key: _myWidgetKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.topCurve ? borderRadius : 0),
          bottom: Radius.circular(widget.bottomCurve ? borderRadius : 0),
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
                top: Radius.circular(widget.topCurve ? borderRadius : 0),
                bottom: Radius.circular(widget.bottomCurve ? borderRadius : 0),
              ),
              color: leftColor,
            ),
            child: Text(""),
          ),

          MaterialButton(
            onPressed: widget.budgetOnPressed == null
                ? null
                : () {
              widget.budgetOnPressed!(widget.prop);
            },
            padding: const EdgeInsets.all(0),
            disabledColor: Colors.transparent,
            disabledTextColor: AppColor.darkText,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(widget.topCurve ? borderRadius : 0),
                  bottom: Radius.circular(widget.bottomCurve ? borderRadius : 0),
                )
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 5),
              leading: widget.prop.iconData == null
                  ? null
                  : Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: widget.prop.isCircleBorder
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: widget.prop.isCircleBorder
                      ? null
                      : BorderRadius.circular(borderRadius),
                  color: widget.prop.color,
                ),
                child: Icon(
                  widget.prop.iconData,
                  color: AppColor.primary,
                ),
              ),
              title: Text(
                widget.prop.label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Text(
                '${BudgetHelper.textMap[widget.prop.type]} ${widget.prop.mainCurrency} ${widget.prop.actualAmount.toStringAsFixed(2)}',
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
                    currencyName: widget.prop.mainCurrency.toString(),
                    mainAxisAlignment: MainAxisAlignment.end,
                    showColor: true,
                    size: 18,
                    fontColor: BudgetHelper.colorMap[widget.prop.type]
                  ),
                  BalanceText(
                    balance: widget.prop.budget,
                    currencyName: "budgeted ${widget.prop.mainCurrency}",
                    mainAxisAlignment: MainAxisAlignment.end,
                    size: 16,
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}



