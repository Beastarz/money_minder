import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class InputFormButtonProps {
  final String text; // the text to display on the button
  final IconData? icon; // the icon to display on the button
  final Color backgroundColor; // the background color of the button
  final Color textColor; // the text color of the button

  InputFormButtonProps({
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
  });
}

class InputFormButton extends StatelessWidget {

  /// variable
  final InputFormButtonProps props;
  final VoidCallback onPressed;// the function to call when the button is pressed


  const InputFormButton({
    super.key,
    required this.props,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: props.backgroundColor,
      borderRadius: BorderRadius.circular(AppSize.borderRadius.r),
      child: InkWell(
        splashColor: AppColor.tertiary,
        highlightColor: AppColor.tertiary,
        borderRadius: BorderRadius.circular(AppSize.borderRadius.r),
        onTap: onPressed,
        child: Center(
          child: props.icon != null
              ? Icon(
                props.icon,
                size: (AppSize.heading2 * 1.5).sp
          )
              : Text(
            props.text,
            style: TextStyle(
              fontSize: (AppSize.heading2 * 1.5).sp,
              fontWeight: FontWeight.normal, // Adjusted for the screenshot
              // color: AppColor.darkText,
            ),
          ),
        ),
      ),
    );
  }
}
