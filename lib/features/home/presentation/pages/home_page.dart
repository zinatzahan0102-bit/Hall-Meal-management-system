import 'package:flutter/material.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/custom_card.dart';
import 'package:meal_management/core/widgets/meal_toggle_switch.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';
import 'package:meal_management/features/complaint/presentation/pages/complaint_page.dart';
import 'package:meal_management/features/review/presentation/pages/daily_review_page.dart';
import 'package:meal_management/features/routine/presentation/pages/meal_routine_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _mealOn = true;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  late Future<Map<String, dynamic>> _userDataFuture;
  late Future<Map<String, dynamic>> _mealStatsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadTodayMealStatus();
  }

  void _loadData() {
    final user = _authService.currentUser;
    if (user != null) {
      _userDataFuture = _firestoreService.getUser(user.uid).then((data) => data ?? {});
      _mealStatsFuture = _firestoreService.getMealStats(user.uid);
    } else {
      _userDataFuture = Future.value({});
      _mealStatsFuture = Future.value({
        'totalMeals': 0,
        'totalBill': 0.0,
        'remaining': 1150.0,
        'mealRate': 75.0,
      });
    }
  }

  Future<void> _loadTodayMealStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final meals = await _firestoreService.getMeals(user.uid).first;
      final today = DateTime.now();
      final todayString = DateTime(today.year, today.month, today.day).toIso8601String();

      // Find today's meal status
      final todayMeal = meals.firstWhere(
        (meal) => meal['date'] == todayString,
        orElse: () => {'status': true}, // Default to true if no record exists
      );

      if (mounted) {
        setState(() {
          _mealOn = todayMeal['status'] ?? true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FutureBuilder<Map<String, dynamic>>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            String userName = 'User';
            String greeting = 'Manage your meals smarter today';
            if (snapshot.connectionState == ConnectionState.waiting) {
              userName = 'Loading...';
            } else if (snapshot.hasError) {
              userName = 'Error';
              greeting = 'Please check your connection';
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              userName = snapshot.data!['name'] ?? 'User';
            } else {
              userName = 'User';
              greeting = 'Please complete your profile';
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $userName', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  greeting,
                  style: const TextStyle(fontSize: 12, color: AppPallate.textSecondary),
                ),
              ],
            );
          },
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFFD6E7D6),
              child: Icon(Icons.person_rounded, color: AppPallate.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          MealToggleSwitch(
            isOn: _mealOn,
            title: 'Today\'s Meal Status',
            onChanged: (value) async {
              setState(() {
                _mealOn = value;
              });
              // Save meal status to Firebase
              final user = _authService.currentUser;
              if (user != null) {
                await _firestoreService.addMeal(user.uid, {
                  'date': DateTime.now().toIso8601String(),
                  'status': value,
                  'timestamp': DateTime.now(),
                });
              }
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>>(
            future: _mealStatsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading data'));
              }
              Map<String, dynamic> stats = snapshot.data ?? {
                'totalMeals': 0,
                'totalBill': 0.0,
                'remaining': 1150.0,
                'mealRate': 75.0,
              };
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _InfoCard(title: 'Total Meals', value: '${stats['totalMeals']}', hint: 'Current month'),
                  _InfoCard(title: 'Current Bill', value: 'BDT ${stats['totalBill'].toStringAsFixed(0)}', hint: 'Till today'),
                  _InfoCard(title: 'Remaining', value: 'BDT ${stats['remaining'].toStringAsFixed(0)}', hint: 'Balance left'),
                  _InfoCard(title: 'Meal Rate', value: 'BDT ${stats['mealRate'].toStringAsFixed(0)}', hint: 'Per meal'),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.repeat_rounded,
            title: 'Meal Routine',
            subtitle: 'Set recurring weekly schedule',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MealRoutinePage()),
              );
            },
          ),
          _ActionTile(
            icon: Icons.report_gmailerrorred_rounded,
            title: 'Complaint Box',
            subtitle: 'Send issue with details and photo',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ComplaintPage()),
              );
            },
          ),
          _ActionTile(
            icon: Icons.reviews_rounded,
            title: 'Review Food',
            subtitle: 'Rate and provide quick feedback',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DailyReviewPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.hint,
  });

  final String title;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: AppPallate.textSecondary)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(fontSize: 12, color: AppPallate.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3E7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppPallate.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppPallate.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
