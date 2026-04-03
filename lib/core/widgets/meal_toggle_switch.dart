import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_palette.dart';

class MealToggleSwitch extends StatelessWidget {
  const MealToggleSwitch({
    super.key,
    required this.isOn,
    required this.onChanged,
    this.title = 'Meal Status',
  });

  final bool isOn;
  final ValueChanged<bool> onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isOn
              ? const [Color(0xFF4AA35A), AppPallate.success]
              : const [Color(0xFFEF5350), AppPallate.danger],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    isOn ? 'Meal ON' : 'Meal OFF',
                    key: ValueKey(isOn),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: isOn,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.35),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.35),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
