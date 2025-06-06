import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import 'input_keyboard_button.dart';

class InputFormHelper {

  /// convert the button texts to InputFormButtonProps, every button take 1
  /// space by default
  ///
  /// Parameters:
  ///
  /// List\<String\> buttonTexts: the list of button texts
  ///
  /// Map\<String, IconData\>? iconMap: the map of button texts to icons
  ///
  /// return: List\<InputFormButtonProps\>
  static List<InputFormButtonProps> convertToCalButProps(
      List<String> buttonTexts, Map<String, IconData>? iconMap) {
    iconMap ??= {};
    List<InputFormButtonProps> buttonProps = [];
    for (int i = 0; i < buttonTexts.length; i++) {
      if (iconMap.containsKey(buttonTexts[i])) {
        buttonProps.add(InputFormButtonProps(
          text: buttonTexts[i],
          icon: iconMap[buttonTexts[i]],
          backgroundColor: AppColor.primary,
          textColor: AppColor.darkText,
        ));
        continue;
      }
      buttonProps.add(InputFormButtonProps(
        text: buttonTexts[i],
        backgroundColor: AppColor.primary,
        textColor: AppColor.darkText,
      ));
    }
    return buttonProps;
  }
}