import 'package:flutter/material.dart';

class BackupData extends StatelessWidget {
  const BackupData({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text('Backup data'),
        leading: Icon(Icons.backup_outlined),
        onTap: () {
          // TODO: backup data
          // print("Backup data");
        }
    );
  }
}
