import 'package:flutter/material.dart';
import 'package:money_minder/style/app_color.dart';

// For displaying icons for accounts and categories
class MainIcon extends StatelessWidget {
  final Icon icon;
  final Color color;
  final bool isRound;
  final double size;

  const MainIcon({super.key,
    required this.icon,
    required this.color,
    this.isRound = true,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size * 1.5,
      width: size * 1.5,
      decoration: BoxDecoration(
        borderRadius: isRound ? null : BorderRadius.circular(12),
        shape: isRound ? BoxShape.circle : BoxShape.rectangle,
        color: color,
        border: Border.all(
          color: Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          icon.icon,
          color: AppColor.lightIcon,
          size: size,
        ),
      ),
    );
  }
}
