import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import 'calculator_button.dart';

class CalculatorHelper {

  // convert the button texts to CalculatorButtonProps, every button take 1
  // space by default
  // buttonTexts: the list of button texts
  // return: the list of CalculatorButtonProps
  static List<CalculatorButtonProps> convertToCalButProps(
      List<String> buttonTexts, Map<String, IconData>? iconMap) {
    iconMap ??= {};
    List<CalculatorButtonProps> buttonProps = [];
    for (int i = 0; i < buttonTexts.length; i++) {
      if (iconMap.containsKey(buttonTexts[i])) {
        buttonProps.add(CalculatorButtonProps(
          text: buttonTexts[i],
          icon: iconMap[buttonTexts[i]],
          backgroundColor: AppColor.primary,
          textColor: AppColor.darkText,
        ));
        continue;
      }
      buttonProps.add(CalculatorButtonProps(
        text: buttonTexts[i],
        backgroundColor: AppColor.primary,
        textColor: AppColor.darkText,
      ));
    }
    return buttonProps;
  }
}