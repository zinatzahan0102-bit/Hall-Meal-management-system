import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_palette.dart';

class RatingStars extends StatefulWidget {
  const RatingStars({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
  });

  final int initialRating;
  final ValueChanged<int> onRatingChanged;

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars>
    with SingleTickerProviderStateMixin {
  late int _rating;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final value = index + 1;
          return IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 32,
            onPressed: () {
              setState(() {
                _rating = value;
              });
              _controller.forward(from: 0.9);
              widget.onRatingChanged(_rating);
            },
            icon: Icon(
              _rating >= value ? Icons.star_rounded : Icons.star_border_rounded,
              color: _rating >= value ? AppPallate.accent : const Color(0xFFB0B9B0),
            ),
          );
        }),
      ),
    );
  }
}
