import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/contacts_page.dart';
import 'package:money_minder/pages/online_pages/request_pages/ask_money_request.dart';
import 'package:money_minder/pages/online_pages/request_pages/manage_requests_page.dart';
import 'package:money_minder/pages/online_pages/request_pages/send_money_page.dart';
import 'package:money_minder/pages/online_pages/request_pages/split_bill_page.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../../components/categories_page/category_helper.dart';
import '../../style/app_size.dart';

class OnlineHomePage extends StatelessWidget {
  const OnlineHomePage({super.key, required this.username, required this.onReload});

  final String username;
  final void Function() onReload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Minder Online'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome! @$username',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          color: CategoryHelper.lightenColor(Colors.blue, 0.9),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactsPage()));
                            },
                            padding: const EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSize.borderRadius),
                            ),
                            child: ListTile(
                              leading: MainIcon(icon: Icon(Icons.contact_page_outlined), color: Colors.blue, size: 32,),
                              title: Text('Contacts'),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          color: CategoryHelper.lightenColor(Colors.brown, 0.9),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageRequestsPage(onReload: onReload)));
                            },
                            padding: const EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSize.borderRadius),
                            ),
                            child: ListTile(
                              leading: MainIcon(icon: Icon(Icons.list_alt), color: Colors.brown, size: 32,),
                              title: Text('Manage Requests'),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          color: CategoryHelper.lightenColor(Colors.green, 0.9),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SendMoneyPage()));
                            },
                            padding: const EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSize.borderRadius),
                            ),
                            child: ListTile(
                              leading: MainIcon(icon: Icon(Icons.upload_outlined), color: Colors.green, size: 32,),
                              title: Text('Send Money'),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          color: CategoryHelper.lightenColor(Colors.red, 0.9),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AskMoneyPage()));
                            },
                            padding: const EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSize.borderRadius),
                            ),
                            child: ListTile(
                              leading: MainIcon(icon: Icon(Icons.download_outlined), color: Colors.red, size: 32,),
                              title: Text('Ask Money'),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          color: CategoryHelper.lightenColor(Colors.deepPurple, 0.9),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SplitBillPage()));
                            },
                            padding: const EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSize.borderRadius),
                            ),
                            child: ListTile(
                              leading: MainIcon(icon: Icon(Icons.call_split), color: Colors.deepPurple, size: 32,),
                              title: Text('Split Bill'),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
