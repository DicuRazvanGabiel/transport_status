import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:transport_status/firebase_options.dart';
import 'package:transport_status/screens/login_screen.dart';
import 'package:transport_status/screens/order_screen.dart';
import 'package:transport_status/screens/rest_screen.dart';

import 'enums/DriverStatus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(snapshot.data!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  DriverStatus status = DriverStatus.free;
                  if (snapshot.data!.data()!['status'] == 'rest') {
                    status = DriverStatus.rest;
                  } else if (snapshot.data!.data()!['status'] == 'order') {
                    status = DriverStatus.order;
                  }

                  if (status == DriverStatus.rest) {
                    return RestScreen();
                  }

                  return OrderScreen(
                    status: status,
                  );
                });
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
