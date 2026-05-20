import 'package:flutter/material.dart';
import 'package:meal_management/core/data/default_menu.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/menu_card.dart';
import 'package:meal_management/features/menu/presentation/pages/menu_detail_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _showWeeklyOverview = false;

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  DateTime _getDateForWeekday(int targetWeekday) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final difference = targetWeekday - currentWeekday;
    return now.add(Duration(days: difference));
  }

  Widget _buildViewSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSwitcherButton(
              label: 'Daily Menu',
              isSelected: !_showWeeklyOverview,
              onTap: () => setState(() => _showWeeklyOverview = false),
            ),
          ),
          Expanded(
            child: _buildSwitcherButton(
              label: 'Weekly Menu',
              isSelected: _showWeeklyOverview,
              onTap: () => setState(() => _showWeeklyOverview = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitcherButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppPallate.primary : AppPallate.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyMenuList() {
    return StreamBuilder<Map<String, dynamic>?>(
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
              imageUrl: data['breakfast']?['imageUrl'] ??
                  'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
              items: List<String>.from(data['breakfast']?['items'] ?? []),
            ),
            MealEntry(
              title: 'Lunch',
              imageUrl: data['lunch']?['imageUrl'] ??
                  'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
              items: List<String>.from(data['lunch']?['items'] ?? []),
            ),
            MealEntry(
              title: 'Dinner',
              imageUrl: data['dinner']?['imageUrl'] ??
                  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _buildWeeklyMenuList() {
    return StreamBuilder<Map<int, Map<String, dynamic>>>(
      stream: FirestoreService().getWeeklyMenuStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final weeklyData = snapshot.data ?? {};

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 7,
          itemBuilder: (context, index) {
            final weekday = index + 1; // 1 = Monday, 7 = Sunday
            final dayName = _getDayName(weekday);
            final dayMenu = weeklyData[weekday] ?? defaultWeeklyMenu[weekday] ?? {};

            final breakfastItems = List<String>.from(dayMenu['breakfast']?['items'] ?? []);
            final lunchItems = List<String>.from(dayMenu['lunch']?['items'] ?? []);
            final dinnerItems = List<String>.from(dayMenu['dinner']?['items'] ?? []);

            final breakfastImg = dayMenu['breakfast']?['imageUrl'] ??
                'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80';
            final lunchImg = dayMenu['lunch']?['imageUrl'] ??
                'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80';
            final dinnerImg = dayMenu['dinner']?['imageUrl'] ??
                'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppPallate.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          dayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppPallate.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 8),
                    _buildWeeklyMealRow(
                      context,
                      mealName: 'Breakfast',
                      items: breakfastItems,
                      imageUrl: breakfastImg,
                      icon: Icons.wb_sunny_outlined,
                      weekday: weekday,
                    ),
                    _buildWeeklyMealRow(
                      context,
                      mealName: 'Lunch',
                      items: lunchItems,
                      imageUrl: lunchImg,
                      icon: Icons.light_mode_outlined,
                      weekday: weekday,
                    ),
                    _buildWeeklyMealRow(
                      context,
                      mealName: 'Dinner',
                      items: dinnerItems,
                      imageUrl: dinnerImg,
                      icon: Icons.nights_stay_outlined,
                      weekday: weekday,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyMealRow(
    BuildContext context, {
    required String mealName,
    required List<String> items,
    required String imageUrl,
    required IconData icon,
    required int weekday,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.shade100,
                  width: 0.5,
                ),
              ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppPallate.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppPallate.primary,
            size: 16,
          ),
        ),
        title: Text(
          mealName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppPallate.textPrimary,
          ),
        ),
        subtitle: Text(
          items.isNotEmpty ? items.join(' • ') : 'No menu set',
          style: TextStyle(
            fontSize: 12,
            color: items.isNotEmpty ? AppPallate.textSecondary : Colors.grey.shade400,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 10,
          color: AppPallate.textSecondary,
        ),
        onTap: () {
          final mealEntry = MealEntry(
            title: mealName,
            imageUrl: imageUrl,
            items: items,
          );
          final date = _getDateForWeekday(weekday);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MenuDetailPage(
                meal: mealEntry,
                date: date,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showWeeklyOverview ? 'Weekly Menu' : 'Daily Menu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildViewSwitcher(),
          Expanded(
            child: _showWeeklyOverview ? _buildWeeklyMenuList() : _buildDailyMenuList(),
          ),
        ],
      ),
    );
  }
}
