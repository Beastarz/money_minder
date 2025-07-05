import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/lock_screen/lock_screen.dart';
import 'package:money_minder/repositories/passcode_repositories.dart';
import 'package:money_minder/utils/loading_screen.dart';
import 'package:money_minder/pages/setting_pages/create_username_page.dart';
import 'package:money_minder/style/app_themes.dart';

import 'app_body.dart';
import 'components/notification/notification_service.dart';
import 'firebase_options.dart';
import 'firestore_repositories/users_repositories.dart';
import 'models/passcode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
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

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late bool _isLocked = false; // if the user has set a passcode
  late String _salt; // the salt used to encrypt the passcode
  late String _encryptedPasscode; // the encrypted passcode
  DateTime? _inactiveStart; // default datetime for inactiveStart
  // bool _isBioAuth = false; // the app should not be counted as inactive when authenticating
  bool _isAuthenticating = false; // if the user is authenticating, don't load the lock screen again

  /// load the salt and encrypted passcode
  /// isLocked will be true if the passcode exists
  Future<void> getPasscode() async {
    List<Passcode> passcode = await PasscodeRepositories.instance.getPasscode();
    if (passcode.isNotEmpty) {
      setState(() {
        _salt = passcode[0].salt;
        _encryptedPasscode = passcode[0].encryptedPasscode;
        _isLocked = true;
        _isAuthenticating = true;
      });
    }
  }

  /// if the user leave the app, even the app still operating in the background
  /// the system need to validate the user again after certain amount of times
  Future<void> validateUserAgain() async {

    // make sure the app is paused
    if (_inactiveStart == null) {
      return;
    }

    // don't prompt the user to authenticate again before they finished last authentication
    if (_isAuthenticating) {
      return;
    }

    // we want to know how long the user had left the app and decide whether to lock the app
    DateTime inactiveEnd = DateTime.now();
    List<Passcode> passcode = await PasscodeRepositories.instance.getPasscode();
    if (passcode.isEmpty) {
      return;
    }
    int activePeriod = passcode[0].activePeriod;
    String salt = passcode[0].salt;
    String encryptedPasscode = passcode[0].encryptedPasscode;
    if (mounted && inactiveEnd.difference(_inactiveStart!).inSeconds >= activePeriod) {
      setState(() {
        _isAuthenticating = true;
      });
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => LockScreen(
            startAuthenticating: () {
              setState(() {
                _isAuthenticating = true;
              });
            },
            onUnlocked: () {
              setState(() {
                _isLocked = false;
                _isAuthenticating = false;
              });
              _navigatorKey.currentState?.pop(context);
            },
            salt: salt,
            encryptedPasscode: encryptedPasscode,
          ),
        ),
      );
    }
    _inactiveStart = null;
  }

  Widget _buildMainApp() {
    return Scaffold(
      body: StreamBuilder(
          stream: _firebaseAuth.authStateChanges(),
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
                      return AppBody(
                        user: user,
                        username: snapshot.data,
                        setAuthenticating: (bool isAuthenticating){
                          setState(() {
                            _isAuthenticating = isAuthenticating;
                          });
                        },
                      );
                    }
                    else {
                      return CreateUsernamePage(user: user);
                    }
                  }
              );
            } else {
              return AppBody(
                user: null,
                setAuthenticating: (bool isAuthenticating){
                  setState(() {
                    _isAuthenticating = isAuthenticating;
                  });
                },
              );
            }
          }
      ),
    );
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      setState(() {
        _inactiveStart = DateTime.now();
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
      navigatorKey: _navigatorKey,
      home: _isLocked
          ? Scaffold(
        body: LockScreen(
          startAuthenticating: () {
            setState(() {
              _isAuthenticating = true;
            });
          },
          onUnlocked: () {
            setState(() {
              _isLocked = false;
              _isAuthenticating = false;
            });
          },
          salt: _salt,
          encryptedPasscode: _encryptedPasscode,
        ),
      )
          : _buildMainApp(),
    );
  }
}