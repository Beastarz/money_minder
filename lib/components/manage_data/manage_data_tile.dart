import 'package:flutter/material.dart';

import 'reset.dart';

class ManageDataTile extends StatelessWidget {
  const ManageDataTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.dataset_outlined),
      title: Text('Manage data'),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text('Import Data'),
                      leading: Icon(Icons.upload_outlined),
                      onTap: () {
                        // TODO: import data
                        print("Import data");
                      }
                    ),
                    ListTile(
                      title: Text('Export Data'),
                      leading: Icon(Icons.download_outlined),
                      onTap: () {
                        // TODO: export data
                        print("Export data");
                      }
                    ),
                    ListTile(
                      title: Text('Backup data'),
                      leading: Icon(Icons.backup_outlined),
                      onTap: () {
                        // TODO: backup data
                        print("Backup data");
                      }
                    ),
                    ListTile(
                      title: Text('Restore data'),
                      leading: Icon(Icons.restore_outlined),
                      onTap: () {
                        // TODO: restore data
                        print("Restore data");
                      }
                    ),
                    Divider(),
                    Reset(),
                  ]
                )
              );
            }
        );
      },
    );
  }
}
