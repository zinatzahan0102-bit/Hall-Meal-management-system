import 'package:flutter/material.dart';
import 'package:meal_management/core/data/app_store.dart';
import 'package:meal_management/core/widgets/custom_button.dart';
import 'package:meal_management/core/widgets/input_field.dart';
import 'package:meal_management/features/navigation/presentation/pages/main_navigation_page.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roomController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              validator: _requiredValidator,
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
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Create account',
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  AppStore.instance.registerUser(
                    AppUser(
                      name: _nameController.text.trim(),
                      email: _emailController.text.trim(),
                      room: _roomController.text.trim(),
                      id: _idController.text.trim(),
                    ),
                  );

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                    (route) => false,
                  );
                }
              },
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
}
