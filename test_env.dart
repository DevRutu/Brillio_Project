import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env file loaded successfully!");
    print("🔑 ANDROID_FIREBASE_API_KEY: ${dotenv.env['ANDROID_FIREBASE_API_KEY']}");
  } catch (e) {
    print("❌ ERROR: Could not load .env file! $e");
  }
}
