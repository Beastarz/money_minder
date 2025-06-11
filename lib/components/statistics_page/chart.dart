import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  const Chart({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.shrinkChart,
  });

  final String title;
  final bool isExpanded;
  final void Function()? shrinkChart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Stack(
        children: <Widget>[
          Center(child: Text(title)),

          isExpanded
          ? Positioned(
            bottom: 5,
            right: 5,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
                shrinkChart!();
              },
              icon: const Icon(Icons.fullscreen_exit_outlined,
                size: 30
              ),
            ),
          )
          : SizedBox.shrink(),
        ],
      ),
    );
  }
}
