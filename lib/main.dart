import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/Apptheme.dart';
import 'package:meal_management/features/auth/prasentation/pages/loginpage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hall Meal Management System',
      theme: Apptheme.thememood,
      home: const Loginpage(),
    );
  }
}