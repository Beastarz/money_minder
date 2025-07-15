import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_minder/components/manage_data/backup_data.dart';
import 'package:money_minder/components/manage_data/export_data.dart';
import 'package:money_minder/components/manage_data/import_data.dart';
import 'package:money_minder/components/manage_data/restore_data.dart';

import '../../style/app_size.dart';
import 'reset.dart';

class ManageDataTile extends StatelessWidget {
  const ManageDataTile({
    super.key,
    required this.user,
  });

  final User? user;

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
                child: Container(
                  padding: EdgeInsets.all(AppSize.smallPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      ImportData(),
                      ExportData(),
                      BackupData(user: user),
                      RestoreData(user: user),

                      Divider(),

                      Reset(),
                    ]
                  ),
                )
              );
            }
        );
      },
    );
  }
}
