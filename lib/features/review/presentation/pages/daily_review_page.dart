import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/custom_button.dart';
import 'package:meal_management/core/widgets/input_field.dart';
import 'package:meal_management/core/widgets/rating_stars.dart';

class DailyReviewPage extends StatefulWidget {
  const DailyReviewPage({super.key});

  @override
  State<DailyReviewPage> createState() => _DailyReviewPageState();
}

class _DailyReviewPageState extends State<DailyReviewPage> {
  final _feedbackController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Meal Review'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=1200&q=80',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 220,
                  color: Colors.black.withValues(alpha: 0.15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Rate today\'s meal',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          RatingStars(
            onRatingChanged: (value) {
              setState(() {
                _rating = value;
              });
            },
          ),
          const SizedBox(height: 12),
          InputField(
            hint: 'Tell us what was good or what should improve...',
            controller: _feedbackController,
            maxLines: 5,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppPallate.textPrimary,
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  label: 'Submit',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_rating == 0
                            ? 'Thanks! Feedback submitted.'
                            : 'Thanks for rating $_rating star(s).'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
