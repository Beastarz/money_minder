import 'package:flutter/material.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/contacts_page.dart';
import 'package:money_minder/style/app_color.dart';

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
                    // manage request page
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
                      // send money
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
                      // ask money
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
                      // split money
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
