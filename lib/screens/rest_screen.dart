import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class RestScreen extends StatelessWidget {
  RestScreen({super.key});
  final uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odihna'),
      ),
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.doc('drivers/$uid').update({
                  'status': 'order',
                });
              },
              child: const Text('Reia activitatea'))),
    );
  }
}
