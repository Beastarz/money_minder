import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/main_icon.dart';
import '../categories_page/color_selector.dart';
import '../categories_page/icon_selector.dart';

class AccountCustomizationSheet extends StatelessWidget {
  const AccountCustomizationSheet({
    super.key,
    required this.codePoint,
    required this.colorValue,
    required this.changeCodePoint,
    required this.changeColorValue,
  });

  final int codePoint;
  final int colorValue;
  final void Function(int) changeCodePoint;
  final void Function(int) changeColorValue;

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.8 : 0.6),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MainIcon(
                icon: Icon(IconData(codePoint, fontFamily: "MaterialSymbolsOutlined")),
                color: Color(colorValue),
                isRound: false,),
              SizedBox(height: 10.h),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.all(8.0.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.borderRadius),
                        border: Border.all(
                          color: AppColor.darkText,
                          width: 2,
                        ),
                      ),
                      child: DefaultTabController(
                          length: 2,
                          child: Scaffold(
                              resizeToAvoidBottomInset: false,
                              backgroundColor: AppColor.secondary,
                              appBar: TabBar(
                                  tabs: <Widget>[
                                    Tab(text: 'Icon'),
                                    Tab(text: 'Color'),
                                  ]
                              ),
                              body: TabBarView(
                                  children: [
                                    IconSelector(
                                      changeIcon: changeCodePoint,
                                      codePoint: codePoint,
                                    ),
                                    ColorSelector(
                                      changeColor: changeColorValue,
                                      colorValue: colorValue,
                                    ),
                                  ]
                              )
                          )
                      )
                  )
              ),
              MaterialButton(
                  onPressed: () {Navigator.pop(context);},
                  color: Color(colorValue),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Select"),
                        SizedBox(width: AppSize.smallPadding.w),
                        Icon(IconData(codePoint, fontFamily: "MaterialSymbolsOutlined")),
                      ]
                  )
              ),
            ]
        ),
      ),
    );
  }
}
