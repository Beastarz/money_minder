import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../repositories/passcode_repositories.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';

class ActivePeriodSelector extends StatefulWidget {

  const ActivePeriodSelector({
    super.key
  });

  @override
  State<ActivePeriodSelector> createState() => _ActivePeriodSelectorState();
}

class _ActivePeriodSelectorState extends State<ActivePeriodSelector> {

  int _defaultActivePeriod = 0;

  void setActivePeriod(BuildContext context, int period) async {
    Navigator.pop(context);
    await PasscodeRepositories.instance.updateActivePeriod(period);
  }

  @override
  void initState() {
    super.initState();
    PasscodeRepositories.instance.getActivePeriod().then((value) {
      setState(() {
        _defaultActivePeriod = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.secondary,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSize.smallPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.password, size: 30.sp),
                SizedBox(width: AppSize.smallPadding.w),
                Text('Required Passcode', style: TextStyle(fontSize: 20.sp)),
              ],
            ),
            Divider(),
            ListTile(
              title: Text("Immediately"),
              tileColor: _defaultActivePeriod == 0 ? AppColor.primary : AppColor.secondary,
              onTap: () {setActivePeriod(context, 0);},
            ),
            ListTile(
              title: Text("After 30 seconds"),
              tileColor: _defaultActivePeriod == 30 ? AppColor.primary : AppColor.secondary,
              onTap: () {setActivePeriod(context, 30);},
            ),
            ListTile(
              title: Text("After 1 minute"),
              tileColor: _defaultActivePeriod == 60 ? AppColor.primary : AppColor.secondary,
              onTap: () {setActivePeriod(context, 60);},
            ),
            ListTile(
              title: Text("After 5 minute"),
              tileColor: _defaultActivePeriod == 300 ? AppColor.primary : AppColor.secondary,
              onTap: () {setActivePeriod(context, 300);},
            ),
            ListTile(
              title: Text("After 15 minute"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSize.borderRadius.r),
                    bottomRight: Radius.circular(AppSize.borderRadius.r)
                ),
              ),
              tileColor: _defaultActivePeriod == 900 ? AppColor.primary : AppColor.secondary,
              onTap: () {setActivePeriod(context, 900);},
            ),
          ],
        ),
      ),
    );
  }
}
