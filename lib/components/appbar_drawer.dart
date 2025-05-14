import 'package:flutter/material.dart';

// TODO: Add drawer functionality
class AppbarDrawer extends StatelessWidget {
  const AppbarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 125,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.amberAccent,
              ),
              child: const Text(
                'MoneyMinder',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
          ),
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
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => LogOutPage()),
              // );
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
  }
}
