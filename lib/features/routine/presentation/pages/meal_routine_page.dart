import 'package:flutter/material.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';

class MealRoutinePage extends StatefulWidget {
  const MealRoutinePage({super.key});

  @override
  State<MealRoutinePage> createState() => _MealRoutinePageState();
}

class _MealRoutinePageState extends State<MealRoutinePage> {
  final FirestoreService _firestore = FirestoreService();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activated Meal List'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestore.getMeals(AuthService().currentUser?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No active meals.'));
                }

                final upcomingMeals = snapshot.data!.where((meal) {
                  final dateStr = meal['date'] as String?;
                  final status = meal['status'] as bool?;
                  if (dateStr != null && status == true) {
                    final date = DateTime.parse(dateStr);
                    final today = DateTime.now();
                    final todayNormalized = DateTime(today.year, today.month, today.day);
                    return date.isAfter(todayNormalized) || date.isAtSameMomentAs(todayNormalized);
                  }
                  return false;
                }).toList();

                if (upcomingMeals.isEmpty) {
                  return const Center(child: Text('No upcoming active meals.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcomingMeals.length,
                  itemBuilder: (context, index) {
                    final meal = upcomingMeals[index];
                    final dateStr = meal['date'] as String;
                    final date = DateTime.parse(dateStr);
                    final formattedDate = "${date.day}/${date.month}/${date.year}";

                    final mealDetails = meal['meals'] as Map<String, dynamic>?;
                    String activeMealsStr = "";
                    if (mealDetails != null) {
                      List<String> active = [];
                      if (mealDetails['breakfast'] == true) active.add('Breakfast');
                      if (mealDetails['lunch'] == true) active.add('Lunch');
                      if (mealDetails['dinner'] == true) active.add('Dinner');
                      activeMealsStr = active.isEmpty ? "None" : active.join(', ');
                    } else {
                      activeMealsStr = meal['status'] == true ? "All" : "None";
                    }

                    return ListTile(
                      title: Text("Meal on $formattedDate"),
                      subtitle: Text("Active: $activeMealsStr"),
                      onTap: () {
                        _showUpdateDialog(context, date, mealDetails);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          final user = AuthService().currentUser;
                          if (user != null) {
                            final messenger = ScaffoldMessenger.of(context);
                            await _firestore.addMeal(user.uid, {
                              'date': dateStr,
                              'status': false,
                              'timestamp': DateTime.now(),
                            });
                            messenger.showSnackBar(
                              SnackBar(content: Text('Cancelled meal on $formattedDate')),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, DateTime day, Map<String, dynamic>? mealDetails) async {
    final key = DateTime(day.year, day.month, day.day);
    
    var localBreakfast = mealDetails?['breakfast'] ?? true;
    var localLunch = mealDetails?['lunch'] ?? true;
    var localDinner = mealDetails?['dinner'] ?? true;

    final menu = await _firestore.getMenuFuture(day.weekday);
    final breakfastRate = menu?['breakfast']?['rate'] ?? 75.0;
    final lunchRate = menu?['lunch']?['rate'] ?? 75.0;
    final dinnerRate = menu?['dinner']?['rate'] ?? 75.0;

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update meal for ${day.day}/${day.month}/${day.year}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Breakfast'),
                    subtitle: Text('Rate: $breakfastRate TK'),
                    value: localBreakfast,
                    activeThumbColor: AppPallate.primary,
                    onChanged: (value) {
                      setModalState(() => localBreakfast = value);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Lunch'),
                    subtitle: Text('Rate: $lunchRate TK'),
                    value: localLunch,
                    activeThumbColor: AppPallate.primary,
                    onChanged: (value) {
                      setModalState(() => localLunch = value);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dinner'),
                    subtitle: Text('Rate: $dinnerRate TK'),
                    value: localDinner,
                    activeThumbColor: AppPallate.primary,
                    onChanged: (value) {
                      setModalState(() => localDinner = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final anyMealOn = localBreakfast || localLunch || localDinner;
                        final details = {
                          'breakfast': localBreakfast,
                          'lunch': localLunch,
                          'dinner': localDinner,
                          'rates': {
                            'breakfast': breakfastRate,
                            'lunch': lunchRate,
                            'dinner': dinnerRate,
                          }
                        };

                        final navigator = Navigator.of(context);
                        final user = AuthService().currentUser;
                        if (user != null) {
                          await _firestore.addMeal(user.uid, {
                            'date': key.toIso8601String(),
                            'status': anyMealOn,
                            'meals': details,
                            'timestamp': DateTime.now(),
                          });
                        }
                        navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallate.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
