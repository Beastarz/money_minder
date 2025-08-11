import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/components/categories_page/category_button.dart';

import '../../../style/app_size.dart';

class CategoryTable extends StatelessWidget {
  const CategoryTable({
    super.key,
    required this.catList,
  });

  final List<CategoryProp> catList;

  @override
  Widget build(BuildContext context) {

    if (catList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(8.0.sp),
        child: Text(
            'No categories yet...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w300,
            ),
          ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSize.smallPadding.sp),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: catList.length <= 6 ? 1 : 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: catList.length <= 6 ? 8 : 4,
      ),
      itemBuilder: (context, index) {
        return Row(
          children: [
            Icon(
              catList[index].icon.icon,
              color: catList[index].color,
              size: 20.sp,
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                catList[index].label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: catList[index].color,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        );
      },
      itemCount: catList.length,
    );
  }
}
