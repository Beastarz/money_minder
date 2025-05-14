import 'package:flutter/material.dart';

class AccountsFilter extends StatefulWidget {
  const AccountsFilter({super.key});

  @override
  State<AccountsFilter> createState() => _AccountsFilterState();
}

class _AccountsFilterState extends State<AccountsFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)
              ),
              const Text(
                'Accounts Filter',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // TODO: Add filter options
        ],
      ),
    );
  }
}
