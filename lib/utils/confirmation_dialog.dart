import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {

  final String message;
  final void Function() onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(message),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
                onPressed: onConfirm,
                child: Text('Delete', style: TextStyle(color: Colors.red),)
            )
          ],
        )
      ],
    );
  }
}
