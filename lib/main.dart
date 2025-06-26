import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/utils/loading_screen.dart';
import 'package:money_minder/pages/setting_pages/create_username_page.dart';
import 'package:money_minder/style/app_themes.dart';

import 'app_body.dart';
import 'firebase_options.dart';
import 'firestore_repositories/users_repositories.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MoneyMinder());
}

class MoneyMinder extends StatefulWidget {
  const MoneyMinder({super.key});

  @override
  State<MoneyMinder> createState() => _MoneyMinderState();
}

class _MoneyMinderState extends State<MoneyMinder> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// TODO: Toggle between dark mode and light mode
  final ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,   // Light theme config
      darkTheme: AppThemes.darkTheme, // Dark theme config
      themeMode: _themeMode,         // Current theme mode
      home: Scaffold(
        body: StreamBuilder(
          stream: _auth.authStateChanges(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return LoadingScreen();
            }
            if (asyncSnapshot.hasData) {
              User user = asyncSnapshot.data!;
              return FutureBuilder(
                  future: UsersRepositories.instance.getUsername(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingScreen();
                    }
                    else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return AppBody(user: user, username: snapshot.data,);
                    }
                    else {
                      return CreateUsernamePage(user: user);
                    }
                  }
              );
            } else {
              return AppBody(user: null);
            }
          }
        ),
      ),
    );
  }
}

