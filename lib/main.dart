import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'screens/loading_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  FirebaseOptions? firebaseOptions;
  if (kIsWeb) {
    // Web configuration (if needed)
    // firebaseOptions = DefaultFirebaseOptions.web;
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    firebaseOptions = DefaultFirebaseOptions.android;
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    firebaseOptions = DefaultFirebaseOptions.ios;
  }

  if (firebaseOptions != null) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    print('Firebase initialization failed: Unsupported platform.');
    return;
  }

  runApp(const BrillioApp());
}

class BrillioApp extends StatelessWidget {
  const BrillioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brillio',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFF45C4E6, {
          50: Color(0xFFE1F6FB),
          100: Color(0xFFB5E8F5),
          200: Color(0xFF89D9EF),
          300: Color(0xFF5DCAE8),
          400: Color(0xFF45C4E6),
          500: Color(0xFF2DBDE3),
          600: Color(0xFF28B7E0),
          700: Color(0xFF22AEDC),
          800: Color(0xFF1CA6D8),
          900: Color(0xFF1197D0),
        }),
        textTheme: GoogleFonts.quicksandTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF0F7FF),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF45C4E6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}