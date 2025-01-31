import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signin_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user != null) {
            return const HomeScreen();
          } else {
            return const SignInScreen();
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF45C4E6),
            ),
          ),
        );
      },
    );
  }
}