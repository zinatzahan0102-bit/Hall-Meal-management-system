import 'package:flutter/material.dart';
import 'package:meal_management/core/data/app_store.dart';
import 'package:meal_management/core/widgets/menu_card.dart';
import 'package:meal_management/features/menu/presentation/pages/menu_detail_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Menu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final todayMenu = store.menuForDate(DateTime.now()).asList();

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
