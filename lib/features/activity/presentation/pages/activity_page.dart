import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/features/review/presentation/pages/daily_review_page.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Meal History'),
              Tab(text: 'Reviews'),
              Tab(text: 'Complaints'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MealHistoryTab(),
            _ReviewsTab(),
            _ComplaintsTab(),
          ],
        ),
      ),
    );
  }
}

class _MealHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final history = [
      ('20 Apr 2026', true),
      ('19 Apr 2026', false),
      ('18 Apr 2026', true),
      ('17 Apr 2026', true),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.$2 ? AppPallate.success : AppPallate.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(item.$1)),
              Text(
                item.$2 ? 'ON' : 'OFF',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: item.$2 ? AppPallate.success : AppPallate.danger,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReviewTile(
          title: 'Lunch was great',
          subtitle: 'Rice was soft and chicken was tasty.',
          rating: 5,
        ),
        _ReviewTile(
          title: 'Dinner feedback',
          subtitle: 'Could be less oily next time.',
          rating: 3,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DailyReviewPage()),
            );
          },
          icon: const Icon(Icons.add_comment_rounded),
          label: const Text('Write new review'),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.title,
    required this.subtitle,
    required this.rating,
  });

  final String title;
  final String subtitle;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppPallate.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 18,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final complaints = [
      ('Food Quality', 'Pending'),
      ('Service', 'Resolved'),
      ('Others', 'Pending'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        final isResolved = complaint.$2 == 'Resolved';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint.$1,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Submitted recently',
                      style: TextStyle(color: AppPallate.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isResolved ? const Color(0xFFDDEEDC) : const Color(0xFFFFF0D8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  complaint.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isResolved ? AppPallate.success : const Color(0xFFB87000),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
