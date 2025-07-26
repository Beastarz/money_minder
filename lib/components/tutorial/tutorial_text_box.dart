import 'package:flutter/material.dart';

class TutorialTextBox extends StatelessWidget {
  const TutorialTextBox({super.key, required this.prefix, required this.body});

  final String prefix;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(prefix,),
        Expanded(child: Text(body,)),
      ],
    );
  }
}
