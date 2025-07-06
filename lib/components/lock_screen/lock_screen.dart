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
import '../../utils/AppMessage.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.startAuthenticating,
    required this.onUnlocked,
    required this.salt,
    required this.encryptedPasscode,
  });

  final void Function() startAuthenticating;
  final void Function() onUnlocked;
  final String salt;
  final String encryptedPasscode;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {

  bool isFrozen = false; /// is true if the user reenter the app before previous frozen time has ended
  int frozenCount = 0; /// record the number of times the app is frozen, the freeze time will increase gradually
  final List<Duration> frozenTimes = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(days: 1),
  ]; /// the freeze times
  final int maxTry = 5; /// the maximum number of tries before freezing the app
  Duration countdown = Duration.zero; /// if the previous freeze time has not ended, we need to countdown the freeze time
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  bool _isAuthenticating = false;
  bool disabledBioAuth = false; /// is biometric authentication disabled

  /// get the previous freeze time is it has not ended
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
        }
      });
    }
  }

  /// check if biometric is setup
  Future<void> _checkBiometricAvailability() async {
    try {
      bool isAvailable = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
      });

    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  /// authenticate the user with biometric
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
        if (mounted) {
          // defer popping screen to avoid rebuild issues
          Future.microtask(() {
            if (mounted) widget.onUnlocked();
          });
        }
      }
    } on PlatformException catch (_) {
      // has error
    } finally {
      setState(() {
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
          });
        }
      });
    }
  }

  /// check if the freeze time has ended after the timer has started
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

  /// get the lock screen
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
      delayBuilder: (context, delay) {
        if (delay.inSeconds == 0 && disabledBioAuth) {
          // Defer the setState call to after the build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                disabledBioAuth = false;
              });
            }
          });
        }
        return Text('Input locked for ${PasscodeHelper.formattedDuration(delay)}.');
      },
      maxRetries: maxTry,
      onMaxRetries: (_) {
        DateTime frozenUntil = DateTime.now().add(frozenTimes[frozenCount]);
        setState(() {
          disabledBioAuth = true;
          frozenCount = frozenCount == frozenTimes.length - 1
              ? frozenCount
              : frozenCount + 1;
        });
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
        if (disabledBioAuth) {
          return;
        }
        if (_isBiometricAvailable) {
          widget.startAuthenticating();
          await _authenticateWithBiometrics();
        } else {
          AppMessage.showMessage(context, 'Please setup biometric authentication first');
        }
      },
    );
  }

  /// get the frozen screen when the previous screen time has not ended
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
