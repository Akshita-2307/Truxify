import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/supabase_config.dart';

Future<void> main() async {
  // Ensure Flutter engine is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'REDACTED_FIREBASE_API_KEY',
          appId: 'REDACTED_DRIVER_APP_ID',
          messagingSenderId: 'REDACTED_SENDER_ID',
          projectId: 'truxify-auth-prod',
          storageBucket: 'REDACTED_STORAGE_BUCKET',
          authDomain: 'REDACTED_AUTH_DOMAIN',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    rethrow;
  }

  // Initialize Supabase if keys are provided.
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  } else {
    debugPrint('Supabase URL/AnonKey not provided. Skipping initialization.');
  }

  runApp(const TruxifyApp());
}
