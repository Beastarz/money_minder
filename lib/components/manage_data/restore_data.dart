import 'package:flutter/material.dart';

class RestoreData extends StatelessWidget {
  const RestoreData({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text('Restore data'),
        leading: Icon(Icons.restore_outlined),
        onTap: () {
          // TODO: restore data
          // print("Restore data");
        }
    );
  }
}
