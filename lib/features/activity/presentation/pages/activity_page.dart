import 'package:flutter/material.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';
import 'package:meal_management/features/review/presentation/pages/daily_review_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final FirestoreService _firestore = FirestoreService();
  Stream? _mealsStream;
  Stream? _complaintsStream;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    if (user != null) {
      _mealsStream = _firestore.getMeals(user.uid);
      // For complaints, we can filter the meals stream or create a separate collection
    }
  }

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
            _MealHistoryTab(stream: _mealsStream),
            _ReviewsTab(),
            _ComplaintsTab(stream: _complaintsStream),
          ],
        ),
      ),
    );
  }
}

class _MealHistoryTab extends StatelessWidget {
  final Stream? stream;

  const _MealHistoryTab({this.stream});

  @override
  Widget build(BuildContext context) {
    if (stream == null) {
      return const Center(child: Text('No data available'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream as Stream<List<Map<String, dynamic>>>?,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No meal history'));
        }

        final meals = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            final date = meal['date'] ?? 'Unknown';
            final status = meal['status'] ?? false;
            return ListTile(
              leading: Icon(
                status ? Icons.check_circle : Icons.cancel,
                color: status ? Colors.green : Colors.red,
              ),
              title: Text('Meal on $date'),
              subtitle: Text(status ? 'Active' : 'Inactive'),
            );
          },
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
  final Stream? stream;

  const _ComplaintsTab({this.stream});

  @override
  Widget build(BuildContext context) {
    if (stream == null) {
      return const Center(child: Text('No complaints data'));
    }

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No complaints submitted'));
        }

        final complaints = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['type'] == 'complaint';
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index].data() as Map<String, dynamic>;
            final type = complaint['complaintType'] ?? 'Unknown';
            final status = complaint['status'] ?? 'Pending';
            final isResolved = status == 'Resolved';

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
                        Text(type, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(complaint['description'] ?? '', style: const TextStyle(color: AppPallate.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isResolved ? AppPallate.success.withValues(alpha: 0.1) : AppPallate.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isResolved ? AppPallate.success : AppPallate.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
