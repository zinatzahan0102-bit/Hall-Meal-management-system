import 'package:flutter/material.dart';
import 'package:meal_management/core/data/app_store.dart';
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

  @override
  void dispose() {
    _passKeyController.dispose();
    super.dispose();
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
            label: 'Login as admin',
            onPressed: () {
              final passkey = _passKeyController.text.trim();
              if (passkey == AppStore.adminPassKey) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid pass key. Try ADMIN1234')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
