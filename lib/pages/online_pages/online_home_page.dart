import 'package:flutter/material.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/contacts_page.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/style/app_size.dart';

class OnlineHomePage extends StatelessWidget {
  const OnlineHomePage({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Money Minder Online'),
          centerTitle: true,
        ),
        body: Center(
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
                  color: AppColor.secondary,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
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
              Column(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    color: AppColor.secondary,
                    onPressed: () {
                      // send money
                    },
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
                      // ask money
                    },
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
                      // split money
                    },
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
