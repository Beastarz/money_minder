import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'input_keyboard.dart';

class InputFormSheet extends StatelessWidget {

  final Widget topContent; // the widget to display at the top of the sheet
  final InputKeyboard inputForm; // the input form widget
  final bool showNotes; // show notes input

  const InputFormSheet({
    super.key,
    required this.topContent,
    required this.inputForm,
    this.showNotes = true,
  });

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.secondary,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSize.borderRadius)
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            topContent,
            Container(
              padding: EdgeInsets.all(isSmallScreen
                  ? AppSize.smallPadding
                  : AppSize.bigPadding
              ),
              child: inputForm,
            )
          ],
        ),
      ),
    );
  }
}
