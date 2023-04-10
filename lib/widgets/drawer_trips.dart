import 'package:flutter/material.dart';

import '../screens/history_screen.dart';

class DrawerTrips extends StatelessWidget {
  const DrawerTrips({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text(
              'Curse',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Cursa'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          ListTile(
            title: Text('Istoric curse'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(HistoryScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
