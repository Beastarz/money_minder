import 'package:flutter/material.dart';

// For displaying text with currency and balance
class BalanceText extends StatelessWidget {
  final double balance;
  final String currencyName;
  final bool showColor;
  final MainAxisAlignment mainAxisAlignment;
  final bool isLight;
  final double size;

  const BalanceText({
    super.key,
    required this.balance,
    required this.currencyName,
    this.showColor = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.isLight = false,
    this.size = 21,
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
    if (isLight) {
      color = Colors.white;
    }
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
        currencyName,
          style: TextStyle(
            color: color,
            fontSize: size - 4,
          )
        ),
        const SizedBox(width: 4,),
        Text(
            balance.toStringAsFixed(2),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: size,
            )
        ),
      ],
    );
  }
}
