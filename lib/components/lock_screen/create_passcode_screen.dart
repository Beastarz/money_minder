import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:money_minder/components/lock_screen/passcode_helper.dart';

import '../../models/passcode.dart';
import '../../repositories/passcode_repositories.dart';
import 'lock_screen.dart';

class CreatePasscodeScreen extends StatefulWidget {
  const CreatePasscodeScreen({
    super.key,
    required this.setIsPasscodeConfirmed,
    required this.startBioAuth,
  });

  final void Function(bool) setIsPasscodeConfirmed;
  final void Function() startBioAuth;

  @override
  State<CreatePasscodeScreen> createState() => _CreatePasscodeScreenState();
}

class _CreatePasscodeScreenState extends State<CreatePasscodeScreen> {

  void returnToApp() {
    widget.setIsPasscodeConfirmed(false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenLock.create(
      title: Text("Enter New Passcode"),
      confirmTitle: Text("Confirm New Passcode"),
      digits: 6,
      config: LockScreenConfig.screenLockConfig,
      secretsConfig: LockScreenConfig.secretsConfig,
      keyPadConfig: LockScreenConfig.keyPadConfig,
      useBlur: false,
      maxRetries: 3,
      onMaxRetries: (_) {
        returnToApp();
      },
      onConfirmed: (String passcode) async {

        // create the salt and encrypted passcode
        String salt = PasscodeHelper.generateSalt();
        String encryptedPasscode = PasscodeHelper.generateSha256Hash(salt + passcode);

        Navigator.pop(context); // pop the create passcode screen
        Navigator.pop(context); // pop the drawer

        // show message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passcode set successfully! Restarting app...')),
        );

        // ask user to unlock the app
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => LockScreen(
            startBioAuth: widget.startBioAuth,
            onUnlocked: () {
              Navigator.pop(context); // pop the lock screen
            },
            salt: salt,
            encryptedPasscode: encryptedPasscode)
          )
        );

        // save the new passcode to the database
        await PasscodeRepositories.instance.deletePasscode(); // in case of existing passcode
        await PasscodeRepositories.instance.addPasscode(
            Passcode.insertAsMap(salt, encryptedPasscode, 30));
      },
      onCancelled: returnToApp,
      cancelButton: const Text("Cancel"),
      deleteButton: const Text("Delete"),
    );
  }
}
