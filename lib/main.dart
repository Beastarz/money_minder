import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/lock_screen/lock_screen.dart';
import 'package:money_minder/repositories/passcode_repositories.dart';
import 'package:money_minder/utils/loading_screen.dart';
import 'package:money_minder/pages/setting_pages/create_username_page.dart';
import 'package:money_minder/style/app_themes.dart';

import 'app_body.dart';
import 'firebase_options.dart';
import 'firestore_repositories/users_repositories.dart';
import 'models/passcode.dart';

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

class _MoneyMinderState extends State<MoneyMinder> with WidgetsBindingObserver {

  /// TODO: Toggle between dark mode and light mode
  final ThemeMode _themeMode = ThemeMode.light;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool _isLocked = false;
  late String _salt;
  late String _encryptedPasscode;
  DateTime inactiveStart = DateTime.now();

  Future<void> getPasscode() async {
    List<Passcode> passcode = await PasscodeRepositories.instance.getPasscode();
    if (passcode.isNotEmpty) {
      setState(() {
        _salt = passcode[0].salt;
        _encryptedPasscode = passcode[0].encryptedPasscode;
        _isLocked = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getPasscode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> validateUserAgain() async {
    DateTime inactiveEnd = DateTime.now();
    List<Passcode> passcode = await PasscodeRepositories.instance.getPasscode();
    if (passcode.isEmpty) {
      return;
    }
    int activePeriod = passcode[0].activePeriod;
    String salt = passcode[0].salt;
    String encryptedPasscode = passcode[0].encryptedPasscode;
    if (mounted && inactiveEnd.difference(inactiveStart).inSeconds >= activePeriod) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => LockScreen(
            onUnlocked: () {
              setState(() {
                _isLocked = false;
              });
              navigatorKey.currentState?.pop(context);
            },
            salt: salt,
            encryptedPasscode: encryptedPasscode,
          ),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      setState(() {
        inactiveStart = DateTime.now();
      });
    }
    if (state == AppLifecycleState.resumed) {
      validateUserAgain();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      navigatorKey: navigatorKey,
      home: _isLocked
        ? LockScreen(
          onUnlocked: () {
            setState(() {
              _isLocked = false;
            });
          },
          salt: _salt,
          encryptedPasscode: _encryptedPasscode,
        )
        : _buildMainApp(),
    );
  }

  Widget _buildMainApp() {
    return Scaffold(
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
                      return AppBody(user: user, username: snapshot.data);
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
    );
  }
}