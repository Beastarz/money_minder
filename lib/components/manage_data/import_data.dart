import 'package:flutter/material.dart';
import 'package:money_minder/components/manage_data/csv_generator.dart';

import '../../style/app_size.dart';

class ImportData extends StatelessWidget {
  const ImportData({super.key});

  List<List<dynamic>> generateSampleData() {
    return [
      ['Transactions'],
      ['Date (DDMMYYYY)', 'Type (expense/income/transfer)', 'From Account',
        'To Account/Category', 'Amount', 'Currency (SGD/MYR)', 'Note'],
      [],
      [],
      ['Accounts', 'First Account will be Main Account'],
      ['Name', 'Type (Account/Savings/Debt)', 'Balance', 'Currency (SGD/MYR)', 'Description'],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text('Import Data'),
        leading: Icon(Icons.upload_outlined),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSize.borderRadius),
              topRight: Radius.circular(AppSize.borderRadius)
          ),
        ),
        onTap: () {
          // TODO: import data
          showDialog(
              context: context,
              builder: (context) => Dialog(
                child: Container(
                  padding: EdgeInsets.all(AppSize.smallPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Import Data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSize.heading1,
                        ),
                      ),
                      SizedBox(height: AppSize.smallPadding),
                      Text(
                        "Please strictly follow the format of sample data",
                        style: TextStyle(
                          fontSize: AppSize.heading3,
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Select File'),
                        leading: Icon(Icons.manage_search_outlined),
                        onTap: () {
                          // TODO: SELECT FILE
                          Navigator.pop(context);
                        }
                      ),
                      ListTile(
                        title: Text("Download Sample Data"),
                        leading: Icon(Icons.download_outlined),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(AppSize.borderRadius),
                                bottomRight: Radius.circular(AppSize.borderRadius)
                            ),
                          ),
                        onTap: () async {
                          await CSVGenerator.generateCSV(
                              data: generateSampleData(),
                              fileName: 'Sample_Data',
                              context: context
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        }
                      )
                    ],
                  )
                )
              )
          );
        }
    );
  }
}
