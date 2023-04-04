import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/login";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? nrCar;
  String? authCode;
  bool isLoading = false;

  void login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    final result = await FirebaseFunctions.instance
        .httpsCallable("loginDriver")
        .call({
      "nrCar": nrCar!.toLowerCase(),
      "authCode": int.parse(authCode!.toLowerCase())
    });

    bool status = result.data["ok"] as bool;

    if (!status) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result.data['error'] as String,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        isLoading = false;
      });
    } else {
      String token = result.data["token"] as String;

      setState(() {
        isLoading = false;
      });
      FirebaseAuth.instance.signInWithCustomToken(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conectare"),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 5,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onSaved: (newValue) => nrCar = newValue,
                    decoration: const InputDecoration(
                      hintText: 'Numar masina',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce numar masina';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                      onSaved: (newValue) => authCode = newValue,
                      decoration: const InputDecoration(
                        hintText: 'Cod',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduce cod de acces';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ]),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: login, child: const Text("Concectare")),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
