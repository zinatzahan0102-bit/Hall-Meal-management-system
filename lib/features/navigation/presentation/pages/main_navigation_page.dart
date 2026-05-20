import 'package:flutter/material.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/data/default_menu.dart';
import 'package:meal_management/features/activity/presentation/pages/activity_page.dart';
import 'package:meal_management/features/home/presentation/pages/home_page.dart';
import 'package:meal_management/features/meals/presentation/pages/meals_page.dart';
import 'package:meal_management/features/menu/presentation/pages/menu_page.dart';
import 'package:meal_management/features/profile/presentation/pages/profile_page.dart';
import 'package:meal_management/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const HomePage(),
    const MealsPage(),
    const MenuPage(),
    const ActivityPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to show dialog after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminRole();
    });
  }

  Future<void> _checkAdminRole() async {
    final user = AuthService().currentUser;
    if (user != null) {
      final userData = await FirestoreService().getUser(user.uid);
      if (userData?['role'] == 'admin') {
        if (mounted) {
          final isPasscodeCorrect = await _showPasscodeDialog();
          if (isPasscodeCorrect == true) {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
            );
          } else {
            // Log out if they fail or cancel
            await AuthService().signOut();
          }
        }
      }
    }
  }

  Future<bool?> _showPasscodeDialog() async {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Must enter passcode or cancel (which logs out)
      builder: (context) => AlertDialog(
        title: const Text('Admin Passcode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This account has admin privileges. Please enter your passcode to continue.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Passcode',
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
            onPressed: () async {
              final passkey = controller.text.trim();
              final correctPasskey = await FirestoreService().getAdminPassKey();
              
              bool isCorrect = false;
              if (correctPasskey != null) {
                isCorrect = passkey == correctPasskey;
              } else {
                isCorrect = passkey == defaultAdminPassKey;
              }

              if (isCorrect) {
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid passcode')),
                  );
                }
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_available_rounded), label: 'Meals'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu_rounded), label: 'Menu'),
          NavigationDestination(icon: Icon(Icons.timeline_rounded), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
