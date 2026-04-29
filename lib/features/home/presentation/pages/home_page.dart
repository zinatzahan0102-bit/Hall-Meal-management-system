import 'package:flutter/material.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/custom_card.dart';
import 'package:meal_management/core/widgets/meal_toggle_switch.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';
import 'package:meal_management/features/complaint/presentation/pages/complaint_page.dart';
import 'package:meal_management/features/review/presentation/pages/daily_review_page.dart';
import 'package:meal_management/features/chat/presentation/pages/chat_page.dart';
import 'package:meal_management/features/routine/presentation/pages/meal_routine_page.dart';
import 'package:meal_management/features/profile/presentation/pages/profile_page.dart';
import 'dart:async';

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
  Stream<Map<String, dynamic>>? _mealStatsStream;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadTomorrowMealStatus();
  }

  void _loadData() {
    final user = _authService.currentUser;
    if (user != null) {
      _userDataFuture = _firestoreService
          .getUser(user.uid)
          .then((data) => data ?? {});
      _mealStatsStream = _firestoreService.getMealStatsStream(user.uid);
    } else {
      _userDataFuture = Future.value({});
      _mealStatsStream = Stream.value({
        'totalMeals': 0,
        'totalBill': 0.0,
        'remaining': 1150.0,
        'mealRate': 75.0,
      });
    }
  }

  Future<void> _loadTomorrowMealStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final meals = await _firestoreService.getMeals(user.uid).first;
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowString = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
      ).toIso8601String();

      // Load routine
      final preferences = await _firestoreService.getUserPreferences(user.uid);
      bool routineFallback = true;
      if (preferences != null && preferences.containsKey('routine')) {
        final routine = preferences['routine'] as Map<String, dynamic>;
        final days = routine['days'] as Map<String, dynamic>?;
        if (days != null) {
          final weekdayStr = _getWeekdayStr(tomorrow);
          routineFallback = days[weekdayStr] ?? true;
        }
      }

      // Find tomorrow's meal status
      final tomorrowMeal = meals.firstWhere(
        (meal) => meal['date'] == tomorrowString,
        orElse: () => {'status': routineFallback},
      );

      if (mounted) {
        setState(() {
          _mealOn = tomorrowMeal['status'] ?? routineFallback;
        });
      }
    }
  }

  String _getWeekdayStr(DateTime day) {
    switch (day.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
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
            return GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName 👋',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPallate.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
              child: const CircleAvatar(
                backgroundColor: Color(0xFFD6E7D6),
                child: Text('👤', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          MealToggleSwitch(
            isOn: _mealOn,
            title: 'Next Day\'s Meal Status',
            onChanged: (value) async {
              final settings = await _firestoreService.getMealSettingsStream().first;
              final cutoffHour = settings['breakfastCutoff'] ?? 22;
              final now = DateTime.now();
              DateTime cutoffTime = DateTime(now.year, now.month, now.day, cutoffHour);
              
              if (now.isAfter(cutoffTime)) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cut-off time has passed. You cannot update the next day\'s meal.')),
                  );
                }
                return;
              }

              setState(() {
                _mealOn = value;
              });
              // Save meal status to Firebase
              final user = _authService.currentUser;
              if (user != null) {
                final tomorrow = DateTime.now().add(const Duration(days: 1));
                final normalizedTomorrow = DateTime(
                  tomorrow.year,
                  tomorrow.month,
                  tomorrow.day,
                );
                await _firestoreService.addMeal(user.uid, {
                  'date': normalizedTomorrow.toIso8601String(),
                  'status': value,
                  'timestamp': DateTime.now(),
                });
              }
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder<Map<String, dynamic>>(
            stream: _mealStatsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading data'));
              }
              Map<String, dynamic> stats =
                  snapshot.data ??
                  {
                    'totalMeals': 0,
                    'totalBill': 0.0,
                    'remaining': 1150.0,
                    'mealRate': 75.0,
                  };
              return Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _InfoCard(
                        title: 'Total Meals',
                        value: '${stats['totalMeals']}',
                        hint: 'Current month',
                        onTap: () async {
                           final user = _authService.currentUser;
                           if (user == null) return;
                           final meals = await _firestoreService.getMeals(user.uid).first;
                           final today = DateTime.now();
                           final todayDate = DateTime(today.year, today.month, today.day);
                           
                           final activeMeals = meals.where((m) {
                             if (m['date'] == null) return false;
                             final mealDate = DateTime.tryParse(m['date']);
                             if (mealDate == null) return false;
                             
                             // Only include past or today's meals
                             if (mealDate.isAfter(todayDate)) return false;
                             
                             // Check if any sub-meal is active
                             bool isActive = false;
                             if (m['status'] == true) isActive = true;
                             if (m['meals'] != null) {
                               final sub = m['meals'] as Map<String, dynamic>;
                               if (sub['breakfast'] == true || sub['lunch'] == true || sub['dinner'] == true) {
                                 isActive = true;
                               }
                             }
                             return isActive;
                           }).toList();
                           
                           // Sort descending (newest first)
                           activeMeals.sort((a, b) => b['date'].compareTo(a['date']));
                           
                           if (context.mounted) {
                             showDialog(
                               context: context,
                               builder: (context) => AlertDialog(
                                 title: const Text('Activated Meals (History)'),
                                 content: SizedBox(
                                   width: double.maxFinite,
                                   height: 300,
                                   child: activeMeals.isEmpty 
                                     ? const Center(child: Text('No active meals found.'))
                                     : ListView.builder(
                                         shrinkWrap: true,
                                         itemCount: activeMeals.length,
                                         itemBuilder: (context, index) {
                                           final m = activeMeals[index];
                                           final d = DateTime.parse(m['date']);
                                           String details = 'Meal Active';
                                           if (m['meals'] != null) {
                                              final sub = m['meals'] as Map<String, dynamic>;
                                              List<String> parts = [];
                                              if (sub['breakfast'] == true) parts.add('B');
                                              if (sub['lunch'] == true) parts.add('L');
                                              if (sub['dinner'] == true) parts.add('D');
                                              if (parts.isNotEmpty) {
                                                details = parts.join(', ');
                                              }
                                           }
                                           return ListTile(
                                             leading: const Icon(Icons.check_circle, color: Colors.green),
                                             title: Text('${d.day}/${d.month}/${d.year}'),
                                             trailing: Text(details, style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallate.primary)),
                                           );
                                         }
                                       ),
                                 ),
                                 actions: [
                                   TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                                 ],
                               ),
                             );
                           }
                        },
                      ),
                      _InfoCard(
                        title: 'Current Bill',
                        value: 'BDT ${stats['totalBill'].toStringAsFixed(0)}',
                        hint: 'Till today',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Bill Calculation Overview'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Meals Active: ${stats['totalMeals']}', style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Text('Cost Per Meal: BDT ${stats['mealRate']}', style: const TextStyle(fontSize: 16)),
                                  const Divider(height: 24),
                                  Text('Total Calculation:', style: const TextStyle(fontSize: 14, color: AppPallate.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text('${stats['totalMeals']} x BDT ${stats['mealRate']} = BDT ${stats['totalBill']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _DateTimeAndCutoffCard(),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.list_alt_rounded,
            title: 'Activated Meal List',
            subtitle: 'View and manage your active meals',
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
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ComplaintPage()));
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
          _ActionTile(
            icon: Icons.chat_rounded,
            title: 'Chat with Admin',
            subtitle: 'Direct message to management',
            onTap: () {
              final user = _authService.currentUser;
              if (user != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      chatRoomId: user.uid,
                      chatRoomName: 'Admin',
                      currentUserId: user.uid,
                    ),
                  ),
                );
              }
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
    this.onTap,
  });

  final String title;
  final String value;
  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
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
            style: const TextStyle(
              fontSize: 12,
              color: AppPallate.textSecondary,
            ),
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
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppPallate.textSecondary,
                  ),
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

class _DateTimeAndCutoffCard extends StatefulWidget {
  const _DateTimeAndCutoffCard();

  @override
  State<_DateTimeAndCutoffCard> createState() => _DateTimeAndCutoffCardState();
}

class _DateTimeAndCutoffCardState extends State<_DateTimeAndCutoffCard> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted)
        setState(() {
          _now = DateTime.now();
        });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirestoreService().getMealSettingsStream(),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? {'breakfastCutoff': 22};
        final cutoffHour = settings['breakfastCutoff'] ?? 22;

        DateTime cutoffTime = DateTime(
          _now.year,
          _now.month,
          _now.day,
          cutoffHour,
        );
        if (_now.isAfter(cutoffTime)) {
          cutoffTime = cutoffTime.add(const Duration(days: 1));
        }

        final diff = cutoffTime.difference(_now);
        final hours = diff.inHours.toString().padLeft(2, '0');
        final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

        final user = AuthService().currentUser;
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: user != null ? FirestoreService().getMeals(user.uid) : Stream.value([]),
          builder: (context, mealsSnapshot) {
            final meals = mealsSnapshot.data ?? [];
            final todayString = DateTime(_now.year, _now.month, _now.day).toIso8601String();
            final todayMeal = meals.firstWhere((m) => m['date'] == todayString, orElse: () => {});
            
            String activeMealsText = 'No meal';
            bool hasMeal = false;
            if (todayMeal.isNotEmpty) {
              if (todayMeal['meals'] != null) {
                 final sub = todayMeal['meals'] as Map<String, dynamic>;
                 List<String> active = [];
                 if (sub['breakfast'] == true) active.add('Breakfast');
                 if (sub['lunch'] == true) active.add('Lunch');
                 if (sub['dinner'] == true) active.add('Dinner');
                 if (active.isNotEmpty) {
                   activeMealsText = active.join(', ');
                   hasMeal = true;
                 }
              } else if (todayMeal['status'] == true) {
                 activeMealsText = 'Meal Active (Full Day)';
                 hasMeal = true;
              }
            }

            return CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        color: AppPallate.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_now.day}/${_now.month}/${_now.year}  ${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Active Meals Today Display
                  Row(
                    children: [
                      Icon(
                        hasMeal ? Icons.restaurant_menu_rounded : Icons.no_meals_rounded,
                        color: hasMeal ? Colors.green : AppPallate.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasMeal ? 'Today\'s Active: $activeMealsText' : 'No meal active today',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: hasMeal ? Colors.green : AppPallate.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppPallate.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: AppPallate.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Next Day Meal Cut-off',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppPallate.textSecondary,
                                ),
                              ),
                              Text(
                                '$hours:$minutes:$seconds remaining',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppPallate.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
