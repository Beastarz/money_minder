import 'package:flutter/material.dart';

import '../../models/passcode.dart';
import '../../repositories/passcode_repositories.dart';
import 'active_period_selector.dart';
import 'create_passcode_screen.dart';

class PasscodeTile extends StatefulWidget {

  const PasscodeTile({
    super.key,
  });

  @override
  State<PasscodeTile> createState() => _PasscodeTileState();
}

class _PasscodeTileState extends State<PasscodeTile> {

  bool enablePasscode = false;

  Future<void> getPasscode() async {
    List<Passcode> passcode = await PasscodeRepositories.instance.getPasscode();
    setState(() {
      enablePasscode = passcode.isNotEmpty;
    });
  }

  void setEnablePasscode(bool val) {
    setState(() {
      enablePasscode = val;
    });
  }

  @override
  void initState() {
    super.initState();
    getPasscode();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.security),
      trailing: Switch(
        value: enablePasscode,
        onChanged: (bool enable) async {
          if (enable) {
            setEnablePasscode(true);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePasscodeScreen(
                    setIsPasscodeConfirmed: setEnablePasscode),
              ),
            );
          } else {
            setEnablePasscode(false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Passcode is disabled.'),
              ),
            );
            await PasscodeRepositories.instance.deletePasscode();
          }
        }, //
      ),
      title: Text('Passcode'),
      onTap: () {
        if (enablePasscode) {
          showDialog(
              context: context,
              builder: (context) {
                return ActivePeriodSelector();
              }
          );
          return;
        }

        // set the passcode
        setEnablePasscode(true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePasscodeScreen(
                setIsPasscodeConfirmed: setEnablePasscode),
          ),
        );
      },
    );
  }
}
