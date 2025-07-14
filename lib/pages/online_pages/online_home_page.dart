import 'package:flutter/material.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/contacts_page.dart';
import 'package:money_minder/pages/online_pages/request_pages/ask_money_request.dart';
import 'package:money_minder/pages/online_pages/request_pages/manage_requests_page.dart';
import 'package:money_minder/pages/online_pages/request_pages/send_money_page.dart';
import 'package:money_minder/pages/online_pages/request_pages/split_bill_page.dart';
import 'package:money_minder/style/app_color.dart';

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
        child: Center(
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome! @$username',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              MaterialButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContactsPage())
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: AppColor.secondary,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 50,
                    child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.contact_page_outlined),
                          Text("Contacts"),
                        ]
                    ),
                  )
              ),
              MaterialButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ManageRequestsPage(onReload: onReload,)));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: AppColor.secondary,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 50,
                    child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt, color: Colors.brown,),
                          Text("Manage Requests"),
                        ]
                    ),
                  )
              ),
              Column(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    color: AppColor.secondary,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SendMoneyPage()));
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 60,
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_outlined, color: Colors.green[800], size: 35,),
                          Text("Send Money"),
                        ],
                      ),
                    ),
                  ),
                  MaterialButton(
                    color: AppColor.secondary,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AskMoneyPage()));
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 60,
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_outlined, color: Colors.red[800], size: 35,),
                          Text("Ask Money"),
                        ],
                      ),
                    ),
                  ),
                  MaterialButton(
                    color: AppColor.secondary,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SplitBillPage()));
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 60,
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_split_outlined, color: Colors.deepPurple, size: 35,),
                          Text("Split Bill"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
