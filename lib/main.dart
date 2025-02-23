import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'firebase_options.dart';
import 'screens/loading_screen.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final log = Logger('MainApp');

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    log.info("Environment variables loaded successfully");

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
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'App Initialization Failed:\n$error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFA873E8)),
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
        primaryColor: const Color(0xFFA873E8),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.quicksandTextTheme().copyWith(
          displayLarge: TextStyle(
            color: const Color(0xFFA873E8),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: const Color(0xFF56D1DC),
            fontSize: 16,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA873E8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}