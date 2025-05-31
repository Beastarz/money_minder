import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'input_form.dart';

class InputFormSheet extends StatelessWidget {

  final Widget topContent; // the widget to display at the top of the sheet
  final InputForm inputForm; // the input form widget
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

    return Container(
      height: MediaQuery.of(context).size.height * (isSmallScreen
          ? !showNotes ? 0.75 : 0.80
          : !showNotes ? 0.60 : 0.65),
      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSize.borderRadius)
        ),
      ),
      child: Column(
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
    );
  }
}
