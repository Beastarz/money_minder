import 'package:flutter/material.dart';

import 'app_message.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({required this.child, super.key});

  static void restartApp(BuildContext oldContext, String message) {
    final state = oldContext.findAncestorStateOfType<RestartWidgetState>();
    if (state != null) {
      // Show snackbar BEFORE restarting the app
      AppMessage.showMessage(oldContext, message);

      // Delay the restart slightly to allow the snackbar to show
      Future.delayed(const Duration(seconds: 3), () {
        state.restartApp();
      });
    }
  }

  @override
  RestartWidgetState createState() => RestartWidgetState();
}

class RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey(); // Rebuild entire app
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
