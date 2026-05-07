import 'package:flutter/material.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/widgets/custom_button.dart';
import 'package:meal_management/core/widgets/input_field.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roomController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roomController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Save user data to Firestore
        try {
          await FirestoreService().addUser(user.uid, {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'room': _roomController.text.trim(),
            'id': _idController.text.trim(),
            'createdAt': DateTime.now(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully')),
            );
            // Navigate back to let AuthWrapper handle navigation
            Navigator.of(context).pop();
          }
        } catch (firestoreError) {
          // If Firestore save fails, delete the auth user and show error
          try {
            await user.delete();
          } catch (deleteError) {
            debugPrint('Failed to delete auth user: $deleteError');
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save user data: ${firestoreError.toString()}')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign up failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InputField(
              hint: 'Full Name',
              controller: _nameController,
              prefixIcon: Icons.person_rounded,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            InputField(
              hint: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              validator: _emailValidator,
            ),
            const SizedBox(height: 12),
            InputField(
              hint: 'Room Number',
              controller: _roomController,
              prefixIcon: Icons.meeting_room_outlined,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            InputField(
              hint: 'Student/Hall ID',
              controller: _idController,
              prefixIcon: Icons.badge_outlined,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            InputField(
              hint: 'Password',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              validator: _passwordValidator,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: _isLoading ? 'Creating...' : 'Create account',
              onPressed: _isLoading ? null : () => _signUp(),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
