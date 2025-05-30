import 'package:flutter/material.dart';

import '../../models/currency.dart';
import '../../style/app_size.dart';

class ShowMoney extends StatelessWidget {

  final Currency mainCurrency;
  final double amount;
  final String text;
  final Color color;
  final double factor;

  const ShowMoney({
    super.key,
    required this.mainCurrency,
    required this.amount,
    required this.text,
    required this.color,
    required this.factor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 0,
        children: [
          Text(
              "$text ${mainCurrency.toString()} ",
              style: TextStyle(
                fontSize: AppSize.paragraph * factor,
                color: color,
                overflow: TextOverflow.ellipsis,
              )
          ),
          Text(
              amount.toStringAsFixed(2),
              style: TextStyle(
                fontSize: AppSize.heading3 * factor,
                fontWeight: FontWeight.bold,
                color: color,
                overflow: TextOverflow.ellipsis,
              )
          )
        ]
    );
  }
}