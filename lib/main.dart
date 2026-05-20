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
      return const MainNavigationPage();
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