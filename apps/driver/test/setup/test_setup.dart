import 'dart:developer' as developer;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

/// Setup test environment with all required initializations
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase for tests
  try {
    Supabase.initialize(
      url: 'https://mock-project.supabase.co',
      anonKey: 'mock-anon-key',
    );
    developer.log('✅ Supabase initialized for tests');
  } catch (e) {
    developer.log('⚠️ Supabase already initialized: $e');
  }
  
  // Initialize Firebase for tests
  try {
    Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'mock-api-key',
        appId: 'mock-app-id',
        messagingSenderId: 'mock-sender-id',
        projectId: 'mock-project-id',
      ),
    );
    developer.log('✅ Firebase initialized for tests');
  } catch (e) {
    developer.log('⚠️ Firebase already initialized: $e');
  }
}