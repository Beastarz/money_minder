import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/main.dart';

class CreateUsernamePage extends StatefulWidget {
  const CreateUsernamePage({super.key, required this.user});

  final User user;

  @override
  State<CreateUsernamePage> createState() => _CreateUsernamePageState();
}

class _CreateUsernamePageState extends State<CreateUsernamePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  String errorText = '';
  bool isLoading = false;

  void checkUsername() async {
    bool isExist = await UsersRepositories.instance.checkUsernameExist(_usernameController.text);
    print(isExist);
    if (isExist) {
      setState(() {
        errorText = 'Username is already exists';
        isLoading = false;
      });
    } else {
      String username = _usernameController.text;
      await UsersRepositories.instance.createUsername(widget.user.uid, username);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MoneyMinder()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create your username',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
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
                        if (value.length < 6) {
                          return 'Username must be at least 6 characters long';
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
                isLoading ? CircularProgressIndicator() :
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      checkUsername();
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text('Create')
                ),
              ],
            ),
            SizedBox(height: 16),
            errorText.isEmpty ? Container() :
                Text(errorText, style: TextStyle(color: Colors.red),),
          ],
        ),
      ),
    );
  }
}
