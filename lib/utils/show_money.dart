import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../style/app_size.dart';

class ShowMoney extends StatelessWidget {

  final Currency mainCurrency;
  final double amount;
  final String text;
  final Color color;
  final double factor;
  final bool isStart;
  final double width;

  const ShowMoney({
    super.key,
    required this.mainCurrency,
    required this.amount,
    required this.text,
    required this.color,
    required this.factor,
    required this.width,
    this.isStart = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: isStart
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          spacing: 0,
          children: [
            Text(
                "$text ${mainCurrency.toString()} ",
                style: TextStyle(
                  fontSize: AppSize.paragraph * factor,
                  color: color,
                ),
              overflow: TextOverflow.ellipsis,
            ),
            Flexible(
              child: Text(
                  amount.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: AppSize.heading3 * factor,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]
      ),
    );
  }
}