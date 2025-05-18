import 'package:flutter/material.dart';

class BalanceText extends StatelessWidget {
  final double balance;
  final String currencyName;
  final bool showColor;
  final MainAxisAlignment mainAxisAlignment;

  const BalanceText({
    super.key,
    required this.balance,
    required this.currencyName,
    this.showColor = false,
    this.mainAxisAlignment = MainAxisAlignment.start
  });

  @override
  Widget build(BuildContext context) {
    Color? color = showColor
        ? balance >= 0
        ? balance > 0
        ? Colors.green[600]
        : Colors.grey[800]
        : Colors.red
        : Colors.grey[800];
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Text(
          currencyName,
            style: TextStyle(
              color: color,
              fontSize: 18,
            )
          ),
          const SizedBox(width: 4,),
          Text(
              balance.toStringAsFixed(2),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 21,
              )
          ),
        ],
      ),
    );
  }
}
