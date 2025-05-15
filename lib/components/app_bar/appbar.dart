import 'package:flutter/material.dart';

import 'accounts_filter.dart';

// TODO: Add appbar buttons functionality, account filter functionality
class MMAppBar extends StatelessWidget implements PreferredSizeWidget{
  MMAppBar( {super.key, required this.selectedIndex});

  final int selectedIndex;

  // TODO: Add buttons functionality
  final functionButtons = <IconButton>[
    IconButton(
      icon: Icon(
        Icons.add,
        color: Colors.grey[800],
      ),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(
        Icons.edit,
        color: Colors.grey[800],
      ),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(
        Icons.search,
        color: Colors.grey[800],
      ),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(
        Icons.edit,
        color: Colors.grey[800],
      ),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(
        Icons.location_on_outlined,
        color: Colors.grey[800],
      ),
      onPressed: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.grey[800],
        ),
        onPressed: Scaffold.of(context).openDrawer,
      ),
      title: TextButton(
        child: Column(
          children: [
            Text(
              'All Accounts',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
              )
            ),
            // TODO: Get balance from database
            Text(
              'SGD 5024.90',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 21,
              )
            ),
          ],
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SizedBox.expand(
                child: AccountsFilter(),
              );
            }
          );
        }
      ),
      centerTitle: true,
      actions: [
        functionButtons[selectedIndex],
        IconButton(
          icon: Icon(
            Icons.public,
            color: Colors.grey[800],
          ),
          onPressed: () {
            // TODO: Add online space functionality
          },
        )
      ]
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
