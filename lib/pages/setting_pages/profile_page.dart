import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/models/online/user.dart';
import 'package:money_minder/utils/app_message.dart';
import 'package:money_minder/utils/loading_screen.dart';

import '../../auth/auth_service.dart';
import '../../style/app_color.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userData});

  final User userData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  late User myData;

  @override
  void initState() {
    super.initState();
    myData = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: _isLoading ? LoadingScreen() : Column(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Username'),
            subtitle: Text(widget.userData.username),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone'),
            subtitle: Text(widget.userData.phoneNumber),
            trailing: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    final GlobalKey<FormState> phoneNumberFormKey = GlobalKey<FormState>();
                    PhoneNumber phoneNumber = PhoneNumber(isoCode: 'SG');
                    return SafeArea(
                      child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColor.secondary
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 16,
                          children: [
                            Text('Edit Phone Number', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                            Text('Please enter your new phone number', style: TextStyle(fontSize: 14),),
                            Text('Old Number: ${widget.userData.phoneNumber}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Flexible(
                              child: Form(
                                key: phoneNumberFormKey,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  child: InternationalPhoneNumberInput(
                                    onInputChanged: (PhoneNumber number) {
                                      phoneNumber = number;
                                    },
                                    selectorConfig: SelectorConfig(
                                      selectorType: PhoneInputSelectorType.DIALOG,
                                    ),
                                    spaceBetweenSelectorAndTextField: 0,
                                    ignoreBlank: false,
                                    autoValidateMode: AutovalidateMode.onUserInteraction,
                                    selectorTextStyle: TextStyle(color: Colors.black),
                                    initialValue: phoneNumber,
                                    textFieldController: TextEditingController(),
                                    inputDecoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      border: OutlineInputBorder(),
                                    ),
                                    formatInput: true,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () async {
                                  if (phoneNumberFormKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await UsersRepositories.instance.updateMyPhoneNumber(
                                          widget.userData.uid, phoneNumber.phoneNumber!);
                                      setState(() {
                                        myData.updatePhoneNumber(phoneNumber.phoneNumber!);
                                      });
                                    } catch (e) {
                                      if (context.mounted) {
                                        AppMessage.showMessage(context,
                                            'Phone number update failed');
                                      }
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                        Navigator.pop(context);
                                      });
                                    }
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
                                ),
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    child: Center(child: Text('Save', style: TextStyle(color: Colors.white),))
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  );
                  }
                );
              },
              icon: Icon(Icons.edit_outlined)
            ),
          ),
          SizedBox(height: 16,),
          MaterialButton(
            color: Colors.red,
            minWidth: MediaQuery.of(context).size.width * 0.9,
            onPressed: () {
              setState(() {
                _isLoading = true;
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
                          onPressed: () async {
                            await AuthService().signOut();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text("Sign Out"),
                        ),
                      ],
                    );
                  }
              );
              setState(() {
                _isLoading = false;
              });
            },
            child: Text('Sign Out'),
          ),
          MaterialButton(
            color: Colors.red,
            minWidth: MediaQuery.of(context).size.width * 0.9,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Warning: Delete Account"),
                      content: Text("Are you sure you want to delete and disable your account? This action cannot be undone."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {

                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await AuthService().deleteAccount();
                              await UsersRepositories.instance.deleteMyAccount(
                                  widget.userData.uid);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppMessage.showMessage(context,
                                    'Account deletion failed');
                              }
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          child: Text("Delete Account"),
                        ),
                      ],
                    );
                  }
              );
              setState(() {
                _isLoading = false;
              });
            },
            child: Text('Delete Account'),
          )
        ],
      ),
    );
  }
}
