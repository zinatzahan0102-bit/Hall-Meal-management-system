import 'package:flutter/material.dart';
import 'package:meal_management/core/data/app_store.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/custom_button.dart';

class MenuDetailPage extends StatefulWidget {
  const MenuDetailPage({
    super.key,
    required this.meal,
    this.date,
  });

  final MealEntry meal;
  final DateTime? date;

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  String _selectedEmoji = '😊';

  static const _emojiOptions = ['😋', '😊', '🙂', '😐', '😕', '🤩'];

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.date == null
        ? 'Today\'s ${widget.meal.title}'
        : '${widget.date!.day}/${widget.date!.month}/${widget.date!.year} • ${widget.meal.title}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              widget.meal.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppPallate.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Menu items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          ...widget.meal.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppPallate.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'How do you feel about this menu?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emojiOptions.map((emoji) {
              final selected = _selectedEmoji == emoji;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEmoji = emoji;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFE0EFDF) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppPallate.primary : const Color(0xFFDDE5DD),
                    ),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          CustomButton(
            label: 'Submit reaction',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Thanks for reacting $_selectedEmoji')),
              );
            },
          ),
        ],
      ),
    );
  }
}
