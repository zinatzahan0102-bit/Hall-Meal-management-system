import 'package:flutter/material.dart';
import 'package:meal_management/core/data/default_menu.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/widgets/menu_card.dart';
import 'package:meal_management/features/menu/presentation/pages/menu_detail_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Menu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: FirestoreService().getMenu(DateTime.now().weekday),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final data = snapshot.data;
          List<MealEntry> todayMenu;
          
          if (data != null) {
            todayMenu = [
              MealEntry(
                title: 'Breakfast',
                imageUrl: data['breakfast']?['imageUrl'] ?? 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
                items: List<String>.from(data['breakfast']?['items'] ?? []),
              ),
              MealEntry(
                title: 'Lunch',
                imageUrl: data['lunch']?['imageUrl'] ?? 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
                items: List<String>.from(data['lunch']?['items'] ?? []),
              ),
              MealEntry(
                title: 'Dinner',
                imageUrl: data['dinner']?['imageUrl'] ?? 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
                items: List<String>.from(data['dinner']?['items'] ?? []),
              ),
            ];
          } else {
            final weekday = DateTime.now().weekday;
            final defaultMenu = defaultWeeklyMenu[weekday] ?? defaultWeeklyMenu[1]!;
            todayMenu = [
              MealEntry(
                title: 'Breakfast',
                imageUrl: defaultMenu['breakfast']?['imageUrl'] ?? '',
                items: List<String>.from(defaultMenu['breakfast']?['items'] ?? []),
              ),
              MealEntry(
                title: 'Lunch',
                imageUrl: defaultMenu['lunch']?['imageUrl'] ?? '',
                items: List<String>.from(defaultMenu['lunch']?['items'] ?? []),
              ),
              MealEntry(
                title: 'Dinner',
                imageUrl: defaultMenu['dinner']?['imageUrl'] ?? '',
                items: List<String>.from(defaultMenu['dinner']?['items'] ?? []),
              ),
            ];
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: todayMenu.length,
            itemBuilder: (context, index) {
              final meal = todayMenu[index];
              return MenuCard(
                mealType: meal.title,
                imageUrl: meal.imageUrl,
                items: meal.items,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MenuDetailPage(
                        meal: meal,
                        date: DateTime.now(),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
