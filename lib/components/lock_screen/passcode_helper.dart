import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

import '../../style/app_color.dart';

class PasscodeHelper {

  /// generate a random salt
  ///
  /// Parameters:
  ///
  /// int length: the length of the salt
  ///
  /// return: String
  static String generateSalt([int length = 32]) {
    final Random random = Random.secure();
    final Uint8List saltBytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      saltBytes[i] = random.nextInt(256);
    }
    return base64Encode(saltBytes);
  }

  /// generate a sha256 hash of the input
  ///
  /// Parameters:
  ///
  /// String input: the input to be hashed
  ///
  /// return: String
  static String generateSha256Hash(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// verify the input passcode
  ///
  /// Parameters:
  ///
  /// String input: the input passcode
  ///
  /// String encryptedPasscode: the encrypted passcode
  ///
  /// return: bool
  static bool verifyPasscode(String input, String encryptedPasscode) {
    String hash = generateSha256Hash(input);
    return hash == encryptedPasscode;
  }

  /// format the duration to a string
  ///
  /// Parameters:
  ///
  /// Duration time: the duration to be formatted
  ///
  /// return: String
  static String formattedDuration(Duration time) {
    return '${time.inHours.toString().padLeft(2, '0')}:'
        '${(time.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(time.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

class LockScreenConfig {
  static final ScreenLockConfig screenLockConfig = ScreenLockConfig(
    backgroundColor: AppColor.primary,
    titleTextStyle: TextStyle(
      color: AppColor.darkText,
    ),
  );

  static final SecretsConfig secretsConfig = SecretsConfig(
    secretConfig: SecretConfig(
      borderSize: 2,
      borderColor: AppColor.darkText,
      enabledColor: AppColor.tertiary,
    )
  );

  static final KeyPadConfig keyPadConfig = KeyPadConfig(
      clearOnLongPressed: true,
      actionButtonConfig: KeyPadButtonConfig(
          foregroundColor: AppColor.darkText,
          fontSize: 16,
          buttonStyle: ButtonStyle(
            side: WidgetStateProperty.all(BorderSide.none),
            padding: WidgetStateProperty.all(EdgeInsets.all(0)),
          )
      ),
      buttonConfig: KeyPadButtonConfig(
          backgroundColor: AppColor.tertiary,
          foregroundColor: AppColor.lightText,
          buttonStyle: ButtonStyle(
              side: WidgetStateProperty.all(BorderSide.none)
          )
      )
  );
}