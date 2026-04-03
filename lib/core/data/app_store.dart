import 'package:flutter/material.dart';

enum MealType { breakfast, lunch, dinner }

class MealEntry {
  MealEntry({
    required this.title,
    required this.imageUrl,
    required this.items,
  });

  final String title;
  final String imageUrl;
  final List<String> items;

  MealEntry copyWith({
    String? title,
    String? imageUrl,
    List<String>? items,
  }) {
    return MealEntry(
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      items: items ?? this.items,
    );
  }
}

class DayMenu {
  DayMenu({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  MealEntry breakfast;
  MealEntry lunch;
  MealEntry dinner;

  List<MealEntry> asList() => [breakfast, lunch, dinner];

  MealEntry entryForType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return breakfast;
      case MealType.lunch:
        return lunch;
      case MealType.dinner:
        return dinner;
    }
  }

  void update(MealType type, MealEntry value) {
    switch (type) {
      case MealType.breakfast:
        breakfast = value;
      case MealType.lunch:
        lunch = value;
      case MealType.dinner:
        dinner = value;
    }
  }
}

class AppUser {
  AppUser({
    required this.name,
    required this.email,
    required this.room,
    required this.id,
  });

  final String name;
  final String email;
  final String room;
  final String id;
}

class AppStore extends ChangeNotifier {
  AppStore._();

  static final AppStore instance = AppStore._();

  static const String adminPassKey = 'ADMIN1234';

  final List<AppUser> _users = [
    AppUser(name: 'Jisha Ahmed', email: 'jisha@mail.com', room: 'A-203', id: 'HALL-1024'),
    AppUser(name: 'Mahin Hasan', email: 'mahin@mail.com', room: 'B-110', id: 'HALL-1077'),
  ];

  final Map<int, DayMenu> _weeklyMenus = {
    DateTime.monday: _defaultDayMenu(
      breakfastItems: ['Ruti', 'Vegetable', 'Boiled Egg'],
      lunchItems: ['Rice', 'Chicken Curry', 'Lentils'],
      dinnerItems: ['Khichuri', 'Beef Bhuna', 'Salad'],
    ),
    DateTime.tuesday: _defaultDayMenu(
      breakfastItems: ['Paratha', 'Egg Bhaji', 'Banana'],
      lunchItems: ['Rice', 'Fish Curry', 'Mixed Vegetables'],
      dinnerItems: ['Polao', 'Chicken Roast', 'Cucumber'],
    ),
    DateTime.wednesday: _defaultDayMenu(
      breakfastItems: ['Bread', 'Jam', 'Milk Tea'],
      lunchItems: ['Rice', 'Beef Curry', 'Dal'],
      dinnerItems: ['Fried Rice', 'Egg Curry', 'Salad'],
    ),
    DateTime.thursday: _defaultDayMenu(
      breakfastItems: ['Khichuri', 'Egg', 'Papaya'],
      lunchItems: ['Rice', 'Chicken Korma', 'Dal'],
      dinnerItems: ['Ruti', 'Vegetable Curry', 'Chicken Bhuna'],
    ),
    DateTime.friday: _defaultDayMenu(
      breakfastItems: ['Nan', 'Halwa', 'Egg'],
      lunchItems: ['Polao', 'Beef Rezala', 'Salad'],
      dinnerItems: ['Rice', 'Fish Fry', 'Dal'],
    ),
    DateTime.saturday: _defaultDayMenu(
      breakfastItems: ['Ruti', 'Potato Curry', 'Tea'],
      lunchItems: ['Rice', 'Chicken Roast', 'Dal'],
      dinnerItems: ['Khichuri', 'Egg Chop', 'Salad'],
    ),
    DateTime.sunday: _defaultDayMenu(
      breakfastItems: ['Paratha', 'Vegetable', 'Milk'],
      lunchItems: ['Rice', 'Mutton Curry', 'Dal'],
      dinnerItems: ['Noodles', 'Chicken Fry', 'Cucumber'],
    ),
  };

  List<AppUser> get users => List.unmodifiable(_users);

  Map<int, DayMenu> get weeklyMenus => Map.unmodifiable(_weeklyMenus);

  DayMenu menuForDate(DateTime date) {
    return _weeklyMenus[date.weekday] ?? _weeklyMenus[DateTime.monday]!;
  }

  void registerUser(AppUser user) {
    _users.insert(0, user);
    notifyListeners();
  }

  void upsertUser(AppUser user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      _users.add(user);
    } else {
      _users[index] = user;
    }
    notifyListeners();
  }

  void updateDayMeal({
    required int weekday,
    required MealType mealType,
    required MealEntry entry,
  }) {
    final safeWeekday = weekday.clamp(DateTime.monday, DateTime.sunday);
    final dayMenu = _weeklyMenus[safeWeekday];
    if (dayMenu == null) {
      _weeklyMenus[safeWeekday] = DayMenu(
        breakfast: MealEntry(title: 'Breakfast', imageUrl: entry.imageUrl, items: entry.items),
        lunch: MealEntry(title: 'Lunch', imageUrl: entry.imageUrl, items: entry.items),
        dinner: MealEntry(title: 'Dinner', imageUrl: entry.imageUrl, items: entry.items),
      );
    }

    _weeklyMenus[safeWeekday]!.update(mealType, entry);
    notifyListeners();
  }

  static DayMenu _defaultDayMenu({
    required List<String> breakfastItems,
    required List<String> lunchItems,
    required List<String> dinnerItems,
  }) {
    return DayMenu(
      breakfast: MealEntry(
        title: 'Breakfast',
        imageUrl:
            'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
        items: breakfastItems,
      ),
      lunch: MealEntry(
        title: 'Lunch',
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
        items: lunchItems,
      ),
      dinner: MealEntry(
        title: 'Dinner',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
        items: dinnerItems,
      ),
    );
  }
}
