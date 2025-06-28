import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/auth/auth_service.dart';
import 'package:money_minder/components/lock_screen/active_period_selector.dart';
import 'package:money_minder/style/app_color.dart';

import '../../models/passcode.dart';
import '../../repositories/passcode_repositories.dart';
import '../lock_screen/create_passcode_screen.dart';

// TODO: Add drawer functionality
class AppbarDrawer extends StatefulWidget {
  const AppbarDrawer({
    super.key,
    required this.user,
    required this.username,
    required this.startBioAuth,
  });

  final User? user;
  final String? username;
  final void Function() startBioAuth;

  @override
  State<AppbarDrawer> createState() => _AppbarDrawerState();
}

class _AppbarDrawerState extends State<AppbarDrawer> {
  bool isLoading = false;
  bool enablePasscode = false;
  bool hasPasscode = false;

  Future<void> getPasscode() async {
    List<Passcode> passcode = await PasscodeRepositories.instance.getPasscode();
    setState(() {
      enablePasscode = passcode.isNotEmpty;
      hasPasscode = passcode.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    getPasscode();
  }

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
      title: Text(
        widget.username == null ? '_empty' : '@${widget.username!}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
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
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.security),
            trailing: Switch(
              value: enablePasscode,
              onChanged: (bool enable) async {
                if (enable) {
                  setState(() {
                    enablePasscode = true;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePasscodeScreen(
                          startBioAuth: widget.startBioAuth,
                          setIsPasscodeConfirmed: (bool isPasscodeConfirmed) {
                            setState(() {
                              enablePasscode = isPasscodeConfirmed;
                            });
                          }),
                    ),
                  );
                } else {
                  setState(() {
                    enablePasscode = false;
                  });
                  await PasscodeRepositories.instance.deletePasscode();
                }
              }, //
            ),
            title: Text('Passcode'),
            onTap: () {
              if (enablePasscode) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return ActivePeriodSelector();
                    }
                );
                return;
              }

              // set the passcode
              setState(() {
                enablePasscode = true;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePasscodeScreen(
                      startBioAuth: widget.startBioAuth,
                      setIsPasscodeConfirmed: (bool isPasscodeConfirmed) {
                        setState(() {
                          enablePasscode = isPasscodeConfirmed;
                        });
                      }),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.dataset_outlined),
            title: Text('Manage data'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
  }
}
