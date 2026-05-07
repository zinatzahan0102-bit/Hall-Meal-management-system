import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationOn = true;
  bool _darkMode = false;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserPreferences();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      _userData = await _firestoreService.getUser(user.uid);
      if (_userData == null || _userData!.isEmpty) {
        // If no user data exists, create default data or prompt to complete profile
        _userData = {
          'name': 'Please complete your profile',
          'room': 'Not set',
          'id': 'Not set',
          'email': user.email ?? 'Not set',
        };
      }
      setState(() {});
    }
  }

  Future<void> _loadUserPreferences() async {
    final user = _authService.currentUser;
    if (user != null) {
      final preferences = await _firestoreService.getUserPreferences(user.uid);
      if (preferences != null) {
        setState(() {
          _notificationOn = preferences['notifications'] ?? true;
          _darkMode = preferences['darkMode'] ?? false;
        });
      }
    }
  }

  Future<void> _saveUserPreferences() async {
    final user = _authService.currentUser;
    if (user != null) {
      final preferences = await _firestoreService.getUserPreferences(user.uid) ?? {};
      preferences['notifications'] = _notificationOn;
      preferences['darkMode'] = _darkMode;
      await _firestoreService.saveUserPreferences(user.uid, preferences);
    }
  }

  Future<void> _updateProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: _userData?['name'] == 'Please complete your profile' ? '' : _userData?['name']);
    final roomController = TextEditingController(text: _userData?['room'] == 'Not set' ? '' : _userData?['room']);
    final idController = TextEditingController(text: _userData?['id'] == 'Not set' ? '' : _userData?['id']);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: roomController,
              decoration: const InputDecoration(labelText: 'Room'),
            ),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final updatedData = {
        'name': nameController.text.trim(),
        'room': roomController.text.trim(),
        'id': idController.text.trim(),
        'email': user.email ?? '',
        'updatedAt': DateTime.now(),
      };

      await _firestoreService.updateUser(user.uid, updatedData);
      await _loadUserData(); // Reload data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    // AuthWrapper will handle navigation to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userData?['name'] ?? 'Loading...', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text('Room: ${_userData?['room'] ?? ''}'),
                          const SizedBox(height: 4),
                          Text('ID: ${_userData?['id'] ?? ''}'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _updateProfile,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Profile',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset_rounded),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showChangePasswordDialog,
                ),
                SwitchListTile.adaptive(
                  value: _notificationOn,
                  activeThumbColor: AppPallate.primary,
                  title: const Text('Notifications'),
                  onChanged: (value) async {
                    setState(() {
                      _notificationOn = value;
                    });
                    await _saveUserPreferences();
                  },
                ),
                SwitchListTile.adaptive(
                  value: _darkMode,
                  activeThumbColor: AppPallate.primary,
                  title: const Text('Dark mode'),
                  onChanged: (value) async {
                    setState(() {
                      _darkMode = value;
                    });
                    await _saveUserPreferences();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppPallate.danger),
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ChangePasswordDialog(
        currentPasswordController: currentPasswordController,
        newPasswordController: newPasswordController,
        confirmPasswordController: confirmPasswordController,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    }
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Current Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm New Password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (!mounted) return;

                  if (widget.newPasswordController.text != widget.confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')),
                    );
                    return;
                  }

                  if (widget.newPasswordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password must be at least 6 characters')),
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    final authService = AuthService();
                    final user = authService.currentUser;
                    if (user != null && user.email != null) {
                      // Re-authenticate user with current password
                      final credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: widget.currentPasswordController.text,
                      );
                      await user.reauthenticateWithCredential(credential);

                      // Update password
                      await user.updatePassword(widget.newPasswordController.text);

                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(true);
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => isLoading = false);
                    }
                  }
                },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change'),
        ),
      ],
    );
  }
}
