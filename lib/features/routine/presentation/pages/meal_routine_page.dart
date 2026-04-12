import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_palette.dart';

class MealRoutinePage extends StatefulWidget {
  const MealRoutinePage({super.key});

  @override
  State<MealRoutinePage> createState() => _MealRoutinePageState();
}

class _MealRoutinePageState extends State<MealRoutinePage> {
  final Map<String, bool> _days = {
    'Mon': true,
    'Tue': true,
    'Wed': false,
    'Thu': true,
    'Fri': true,
    'Sat': false,
    'Sun': false,
  };

  final Map<String, bool> _mealTimes = {
    'Breakfast': true,
    'Lunch': true,
    'Dinner': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Routine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppPallate.primary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Routine saved successfully.')),
          );
        },
        icon: const Icon(Icons.check_rounded, color: Colors.white),
        label: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Selector',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _days.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.key),
                  selected: entry.value,
                  selectedColor: const Color(0xFFCFE8D0),
                  checkmarkColor: AppPallate.primary,
                  onSelected: (selected) {
                    setState(() {
                      _days[entry.key] = selected;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Time-based Option',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ..._mealTimes.entries.map(
              (entry) => SwitchListTile.adaptive(
                title: Text(entry.key),
                value: entry.value,
                activeThumbColor: AppPallate.primary,
                onChanged: (value) {
                  setState(() {
                    _mealTimes[entry.key] = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
