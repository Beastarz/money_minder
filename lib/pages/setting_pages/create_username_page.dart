import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/utils/restart_widget.dart';

class CreateUsernamePage extends StatefulWidget {
  const CreateUsernamePage({super.key, required this.user});

  final User user;

  @override
  State<CreateUsernamePage> createState() => _CreateUsernamePageState();
}

class _CreateUsernamePageState extends State<CreateUsernamePage> {
  final GlobalKey<FormState> _usernameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _phoneNumberFormKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'SG');

  String errorText = '';
  bool isLoading = false;

  void checkUsername() async {
    bool isExist = await UsersRepositories.instance.checkUsernameExist(_usernameController.text);
    if (isExist) {
      setState(() {
        errorText = 'Username is already exists';
        isLoading = false;
      });
    } else {
      String username = _usernameController.text;
      await UsersRepositories.instance.createUsername(widget.user.uid, _phoneNumber.phoneNumber!, username);
      if (mounted) {
        RestartWidget.restartApp(context, 'Username creation successful. Restarting app');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Set your username and phone number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(child: Text('You cannot change your username afterwards.')),
            SizedBox(height: 16.h),
            Form(
              key: _usernameFormKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    label: Text('Username'),
                    hintText: 'eg. awesome_guy1234',
                    errorMaxLines: 2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.length < 6 || value.length > 20) {
                      return 'Username must be 6 ~ 20 characters long';
                    }
                    final RegExp regex = RegExp(r'^[a-z0-9_]+$');
                    if (!regex.hasMatch(value.trim())) {
                      return 'Username can only contain small letters, numbers, or underscores.';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h,),
            Flexible(
              child: Form(
                key: _phoneNumberFormKey,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      _phoneNumber = number;
                    },
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.DIALOG,
                    ),
                    spaceBetweenSelectorAndTextField: 0,
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    selectorTextStyle: TextStyle(color: Colors.black),
                    initialValue: _phoneNumber,
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
            SizedBox(height: 16.h),
            isLoading ? CircularProgressIndicator() :
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  if (_usernameFormKey.currentState!.validate() && _phoneNumberFormKey.currentState!.validate()) {
                    checkUsername();
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: Text('Create')
            ),
            SizedBox(height: 16.h),
            errorText.isEmpty ? Container() :
                Text(errorText, style: TextStyle(color: Colors.red),),
          ],
        ),
      ),
    );
  }
}
