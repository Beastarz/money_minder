import 'package:flutter/material.dart';
import 'package:money_minder/util/bottomNavBar.dart';

void main() {
  runApp(const moneyMinder());
}

class moneyMinder extends StatelessWidget {
  const moneyMinder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const moneyMinderFrame(),
    );
  }
}

class moneyMinderFrame extends StatefulWidget {
  const moneyMinderFrame({super.key});

  @override
  State<moneyMinderFrame> createState() => _moneyMinderFrameState();
}

class _moneyMinderFrameState extends State<moneyMinderFrame> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MoneyMinder",
        )
      ),
      bottomNavigationBar: SafeArea(child: BottomNavbar()),
    );
  }
}

