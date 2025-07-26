import 'package:flutter/material.dart';

import '../../style/app_color.dart';

class TutorialImage extends StatelessWidget {
  const TutorialImage({super.key, required this.imagePath, required this.title});

  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 18),),
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: AppColor.tertiary),
            ),
            child: ClipRRect(
              child: Image(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
