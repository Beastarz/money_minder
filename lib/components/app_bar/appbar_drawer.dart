import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/auth/auth_service.dart';
import 'package:money_minder/style/app_color.dart';

// TODO: Add drawer functionality
class AppbarDrawer extends StatefulWidget {
  const AppbarDrawer({super.key, required this.user, required this.username});

  final User? user;
  final String? username;

  @override
  State<AppbarDrawer> createState() => _AppbarDrawerState();
}

class _AppbarDrawerState extends State<AppbarDrawer> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Widget signInTile = ListTile(
      title: Text(
          'Not Signed In',
          style: TextStyle(fontSize: 18),
      ),
      trailing: isLoading ? CircularProgressIndicator() : TextButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          User? user = await AuthService().signInWithGoogle();
          setState(() {
            isLoading = false;
          });
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
        child: Text(
            "Google Sign In",
          style: TextStyle(
            fontSize: 16
          ),
        ),
      ),
    );

    Widget signOutTile = ListTile(
      title: Text(widget.username ?? '_empty'),
      trailing: TextButton(
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Sign Out"),
                  content: Text("Are you sure you want to sign out?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        AuthService().signOut();
                        Navigator.of(context).pop();
                      },
                      child: Text("Sign Out"),
                    ),
                  ],
                );
              }
          );
          setState(() {
            isLoading = false;
          });
        },
        child: Text("Sign Out"),
      ),
    );

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 125,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: AppColor.secondary,
              ),
              child: const Text(
                'MoneyMinder',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
          ),
          widget.user != null ? signOutTile : signInTile,
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => SettingsPage()),
              // );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AboutPage()),
              // );
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
  }
}
