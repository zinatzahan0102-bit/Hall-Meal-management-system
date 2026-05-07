import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_management/core/data/app_store.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/widgets/custom_button.dart';
import 'package:meal_management/core/widgets/input_field.dart';
import 'package:meal_management/features/admin/presentation/pages/admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _passKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passKeyController.dispose();
    super.dispose();
  }

  Future<void> _loginAsAdmin() async {
    final passkey = _passKeyController.text.trim();
    if (passkey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter passkey')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // For now, use a simple passkey check, but in production this should be more secure
      if (passkey == AppStore.adminPassKey) {
        // Check if there's a current user
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please login as a regular user first')),
            );
          }
          return;
        }

        // Update user role to admin in Firestore
        await FirestoreService().updateUser(currentUser.uid, {'role': 'admin'});

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid pass key. Try ADMIN1234')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin login failed: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          const Text(
            'Enter admin pass key',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Admin can control users, weekly menu, and food images.',
            style: TextStyle(color: Color(0xFF637064)),
          ),
          const SizedBox(height: 16),
          InputField(
            hint: 'Admin pass key',
            controller: _passKeyController,
            prefixIcon: Icons.vpn_key_rounded,
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: _isLoading ? 'Setting up...' : 'Login as admin',
            onPressed: _isLoading ? null : _loginAsAdmin,
          ),
        ],
      ),
    );
  }
}
