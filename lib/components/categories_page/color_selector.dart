import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../style/app_size.dart';

class ColorSelector extends StatefulWidget {
  const ColorSelector({
    super.key,
    required this.changeColor,
    required this.colorValue,
  });

  final void Function(int) changeColor;
  final int colorValue;

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {

  late Color pickerColor = Color(widget.colorValue);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
    widget.changeColor(color.toARGB32());
  }

  @override
  Widget build(BuildContext context) {
    return  LayoutBuilder(
      builder: (context, constraints) {
        final double ratio = 0.7 * constraints.maxHeight / constraints.maxWidth;
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 8.0.h),
            child: ColorPicker(
              pickerAreaHeightPercent: ratio,
              pickerAreaBorderRadius: BorderRadius.circular(AppSize.borderRadius),
              hexInputBar: true,
              pickerColor: pickerColor,
              enableAlpha: false,
              onColorChanged: changeColor,
            ),
          ),
        );
      }
    );
  }
}
