import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_management/core/theme/app_theme.dart';
import 'package:meal_management/core/data/notification_service.dart';
import 'package:meal_management/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:meal_management/features/auth/prasentation/pages/loginpage.dart';
import 'package:meal_management/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Enable offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    
    // Initialize notifications
    await NotificationService().initialize();
    
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase for development/testing
  }

  runApp(MyApp(firebaseInitialized: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MyApp({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hall Meal Management System',
      theme: AppTheme.thememood,
      home: AuthWrapper(firebaseInitialized: firebaseInitialized),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final bool firebaseInitialized;

  const AuthWrapper({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    // If Firebase is not initialized, show a message
    if (!firebaseInitialized) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Not Available',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Running in offline mode for development.\nSome features may not work.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                      (route) => false,
                    );
                  },
                  child: const Text('Continue Anyway'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in
          return const MainNavigationPage();
        } else {
          // User is not signed in
          return const Loginpage();
        }
      },
    );
  }
}