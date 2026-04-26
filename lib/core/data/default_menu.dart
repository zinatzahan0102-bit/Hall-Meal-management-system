const Map<int, Map<String, dynamic>> defaultWeeklyMenu = {
  1: {
    'breakfast': {
      'imageUrl': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
      'items': ['Ruti', 'Vegetable', 'Boiled Egg'],
    },
    'lunch': {
      'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
      'items': ['Rice', 'Chicken Curry', 'Lentils'],
    },
    'dinner': {
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
      'items': ['Khichuri', 'Beef Bhuna', 'Salad'],
    },
  },
  2: {
    'breakfast': {
      'imageUrl': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
      'items': ['Paratha', 'Egg Bhaji', 'Banana'],
    },
    'lunch': {
      'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
      'items': ['Rice', 'Fish Curry', 'Mixed Vegetables'],
    },
    'dinner': {
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
      'items': ['Polao', 'Chicken Roast', 'Cucumber'],
    },
  },
  3: {
    'breakfast': {
      'imageUrl': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
      'items': ['Bread', 'Jam', 'Milk Tea'],
    },
    'lunch': {
      'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
      'items': ['Rice', 'Beef Curry', 'Dal'],
    },
    'dinner': {
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
      'items': ['Fried Rice', 'Egg Curry', 'Salad'],
    },
  },
  4: {
    'breakfast': {
      'imageUrl': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
      'items': ['Khichuri', 'Egg', 'Papaya'],
    },
    'lunch': {
      'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
      'items': ['Rice', 'Chicken Korma', 'Dal'],
    },
    'dinner': {
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
      'items': ['Ruti', 'Vegetable Curry', 'Chicken Bhuna'],
    },
  },
  5: {
    'breakfast': {
      'imageUrl': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
      'items': ['Nan', 'Halwa', 'Egg'],
    },
    'lunch': {
      'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
      'items': ['Polao', 'Beef Rezala', 'Salad'],
    },
    'dinner': {
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
      'items': ['Rice', 'Fish Fry', 'Dal'],
    },
  },
  6: {
    'breakfast': {
      'imageUrl': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
      'items': ['Ruti', 'Potato Curry', 'Tea'],
    },
    'lunch': {
      'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
      'items': ['Rice', 'Chicken Roast', 'Dal'],
    },
    'dinner': {
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
      'items': ['Khichuri', 'Egg Chop', 'Salad'],
    },
  },
  7: {
    'breakfast': {
      'imageUrl': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=1200&q=80',
      'items': ['Paratha', 'Vegetable', 'Milk'],
    },
    'lunch': {
      'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
      'items': ['Rice', 'Mutton Curry', 'Dal'],
    },
    'dinner': {
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
      'items': ['Noodles', 'Chicken Fry', 'Cucumber'],
    },
  },
};

class MealEntry {
  MealEntry({
    required this.title,
    required this.imageUrl,
    required this.items,
  });

  final String title;
  final String imageUrl;
  final List<String> items;
}

enum MealType { breakfast, lunch, dinner }

const String defaultAdminPassKey = 'ADMIN1234';
