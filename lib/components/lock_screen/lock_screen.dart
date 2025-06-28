import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:money_minder/components/lock_screen/passcode_helper.dart';

import '../../models/freeze_time.dart';
import '../../repositories/freeze_time_repositories.dart';
import '../../style/app_size.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.onUnlocked,
    required this.salt,
    required this.encryptedPasscode,
  });

  final void Function() onUnlocked;
  final String salt;
  final String encryptedPasscode;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {

  bool isFrozen = false;
  int frozenCount = 0;
  final List<Duration> frozenTimes = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(days: 1),
  ];
  final int maxTry = 5;
  Duration countdown = Duration.zero;
  final inputController = InputController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  bool _isAuthenticating = false;

  Future<void> _getFreezeTime() async {
    List<FreezeTime> time = await FreezeTimeRepositories.instance.getFreezeTime();
    if (time.isNotEmpty) {

      if (time.last.frozenUntil.isBefore(DateTime.now())) {
        // delete the freeze time if it has passed
        setState(() {
          frozenCount = time.last.frozenCount;
        });
        return;
      }

      setState(() {
        isFrozen = true;
        countdown = time.last.frozenUntil.difference(DateTime.now());
        frozenCount = time.last.frozenCount;
      });

      // Set up a timer to update the frozen screen countdown
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (isFrozen && mounted) {
          countdown = time.last.frozenUntil.difference(DateTime.now());
          _checkFreezeStatus();
          setState(() {}); // Trigger rebuild to update countdown
        }
        if (!isFrozen) {
          timer.cancel();
          if (_isBiometricAvailable) {
            _checkBiometricAvailability();
          }
        }
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      bool isAvailable = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
      });

      // Auto-trigger biometric authentication if available
      if (_isBiometricAvailable && !isFrozen) {
        _authenticateWithBiometrics();
      }
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock the app',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        // Reset freeze time on successful biometric authentication
        await FreezeTimeRepositories.instance.deleteFreezeTime();
        widget.onUnlocked();
      }
    } on PlatformException catch (_) {
      // has error
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  // void _showSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       duration: Duration(seconds: 3),
  //     ),
  //   );
  // }

  void _checkFreezeStatus() {
    if (isFrozen && countdown.inSeconds <= 0) {
      setState(() {
        isFrozen = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getFreezeTime();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getScreenLock() {
    return ScreenLock(
      correctString: '______', // just to indicate how many digits
      onUnlocked: widget.onUnlocked,
      onValidate: (passcode) async {
        String guess = PasscodeHelper.generateSha256Hash(widget.salt + passcode);

        // reset the freeze time
        await FreezeTimeRepositories.instance.deleteFreezeTime();
        return guess == widget.encryptedPasscode;
      },
      retryDelay: frozenTimes[frozenCount],
      delayBuilder: (context, delay) =>
          Text('Input locked for ${PasscodeHelper.formattedDuration(delay)}.'),
      maxRetries: maxTry,
      onMaxRetries: (_) {
        DateTime frozenUntil = DateTime.now().add(frozenTimes[frozenCount]);
        frozenCount = frozenCount == frozenTimes.length - 1
            ? frozenCount
            : frozenCount + 1;
        FreezeTimeRepositories.instance.addFreezeTime(FreezeTime.insertAsMap(frozenCount, frozenUntil));
      },
      title: Text('Enter Passcode'),
      config: LockScreenConfig.screenLockConfig,
      secretsConfig: LockScreenConfig.secretsConfig,
      keyPadConfig: LockScreenConfig.keyPadConfig,
      useBlur: false,
      deleteButton: Text("Delete"),

      // for biometric authentication
      customizedButtonChild: Icon(
          Icons.fingerprint,
          size: 30,
      ),
      customizedButtonTap: () async {
        if (_isBiometricAvailable) {
          await _authenticateWithBiometrics();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please setup biometric authentication first.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  Widget getFrozenScreen() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: Colors.black.withAlpha((255 * 0.3).round()),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(AppSize.bigPadding),
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((255 * 0.5).round()),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withAlpha((255 * 0.5).round()),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.security,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Screen Locked',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Access temporarily restricted',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha((255 * 0.8).round()),
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  SizedBox(height: 20),
                  Text(
                    PasscodeHelper.formattedDuration(countdown),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // return Text("FuCK YOU");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        getScreenLock(),
        if (isFrozen)
          getFrozenScreen()
      ]
    );
  }
}
