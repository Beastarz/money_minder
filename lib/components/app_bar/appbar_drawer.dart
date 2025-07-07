import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/auth/auth_service.dart';
import 'package:money_minder/components/lock_screen/passcode_tile.dart';
import 'package:money_minder/pages/setting_pages/profile_page.dart';
import 'package:money_minder/style/app_color.dart';

import '../../pages/setting_pages/currency_setting_dialog.dart';
import '../manage_data/manage_data_tile.dart';
import '../notification/notification_tile.dart';
import 'package:money_minder/models/online/user.dart' as app_user;

// TODO: Add drawer functionality
class AppbarDrawer extends StatefulWidget {
  const AppbarDrawer({
    super.key,
    required this.user,
    required this.userData,
    required this.onCurrencyReload,
  });

  final User? user;
  final app_user.User? userData;
  final void Function() onCurrencyReload;

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
          if (user == null && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Sign in failed'),
              ),
            );
          }
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
      leading: Icon(Icons.person_outlined),
      title: Text(
        widget.userData == null ? '_empty' : '@${widget.userData!.username}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        if (widget.userData != null) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ProfilePage(userData: widget.userData!,)));
        }
      },
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              child: Text('Settings'),
            ),
            ListTile(
              leading: Icon(Icons.color_lens_outlined),
              title: Text('Theme'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on_outlined),
              title: Text('Currency'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                        child: CurrencySettingDialog(
                            onReload: widget.onCurrencyReload
                        )
                    );
                  }
                );
              },
            ),

            NotificationTile(),

            PasscodeTile(),

            ManageDataTile(),
          ],
        )
    );
  }
}
