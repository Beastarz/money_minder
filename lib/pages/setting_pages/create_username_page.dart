import 'package:flutter/material.dart';

class CreateUsernamePage extends StatefulWidget {
  const CreateUsernamePage({super.key});

  @override
  State<CreateUsernamePage> createState() => _CreateUsernamePageState();
}

class _CreateUsernamePageState extends State<CreateUsernamePage> {
  TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Create a username',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Enter your username eg. awesomeGuy1234',
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
              final RegExp regex = RegExp(r'^[a-zA-Z0-9_]+$');
              if (!regex.hasMatch(value.trim())) {
                return 'Username can only contain letters, numbers, or underscores.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
