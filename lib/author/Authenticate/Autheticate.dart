
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../Screens/HomeScreen.dart';
import 'LoginScree.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}