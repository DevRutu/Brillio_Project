import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'firebase_options.dart';
import 'screens/loading_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  // Configure logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final log = Logger('MainApp');

  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load environment variables
    await dotenv.load(fileName: ".env");
    log.info("Environment variables loaded successfully");

    // Check if all required variables are present
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    final apiKey = dotenv.env[isAndroid ? 'ANDROID_FIREBASE_API_KEY' : 'IOS_FIREBASE_API_KEY'];
    final appId = dotenv.env[isAndroid ? 'ANDROID_FIREBASE_APP_ID' : 'IOS_FIREBASE_APP_ID'];
    final messagingSenderId = dotenv.env[isAndroid ? 'ANDROID_FIREBASE_MESSAGING_SENDER_ID' : 'IOS_FIREBASE_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env[isAndroid ? 'ANDROID_FIREBASE_PROJECT_ID' : 'IOS_FIREBASE_PROJECT_ID'];
    final storageBucket = dotenv.env[isAndroid ? 'ANDROID_FIREBASE_STORAGE_BUCKET' : 'IOS_FIREBASE_STORAGE_BUCKET'];

    if (apiKey == null || appId == null || messagingSenderId == null || 
        projectId == null || storageBucket == null) {
      throw Exception('Missing Firebase configuration in .env file');
    }

    FirebaseOptions firebaseOptions = isAndroid
        ? DefaultFirebaseOptions.android
        : DefaultFirebaseOptions.ios;

    log.info("Attempting Firebase initialization");
    await Firebase.initializeApp(options: firebaseOptions);
    log.info("Firebase initialization successful");

    runApp(const BrillioApp());
  } catch (e, stackTrace) {
    print('Initialization error: $e');
    print('Stack trace: $stackTrace');
    
    // Fallback app in case of initialization failure
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'App Initialization Failed:\n$error', 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
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
