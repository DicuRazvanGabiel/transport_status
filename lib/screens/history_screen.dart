import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:transport_status/widgets/drawer_trips.dart';

class HistoryScreen extends StatelessWidget {
  static final String routeName = '/history';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerTrips(),
      appBar: AppBar(
        title: const Text('Istoric curse'),
      ),
      body: const Placeholder(),
    );
  }
}
