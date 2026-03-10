import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/custom_card.dart';
import 'package:meal_management/core/widgets/meal_toggle_switch.dart';
import 'package:meal_management/features/complaint/presentation/pages/complaint_page.dart';
import 'package:meal_management/features/review/presentation/pages/daily_review_page.dart';
import 'package:meal_management/features/routine/presentation/pages/meal_routine_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _mealOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, Jisha', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 2),
            Text(
              'Manage your meals smarter today',
              style: TextStyle(fontSize: 12, color: AppPallate.textSecondary),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFFD6E7D6),
              child: Icon(Icons.person_rounded, color: AppPallate.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          MealToggleSwitch(
            isOn: _mealOn,
            title: 'Today\'s Meal Status',
            onChanged: (value) {
              setState(() {
                _mealOn = value;
              });
            },
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: const [
              _InfoCard(title: 'Total Meals', value: '58', hint: 'Current month'),
              _InfoCard(title: 'Current Bill', value: 'BDT 4,350', hint: 'Till today'),
              _InfoCard(title: 'Remaining', value: 'BDT 1,150', hint: 'Balance left'),
              _InfoCard(title: 'Meal Rate', value: 'BDT 75', hint: 'Per meal'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.repeat_rounded,
            title: 'Meal Routine',
            subtitle: 'Set recurring weekly schedule',
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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ComplaintPage()),
              );
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
  });

  final String title;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
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
            style: const TextStyle(fontSize: 12, color: AppPallate.textSecondary),
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppPallate.textSecondary),
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
