import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_palette.dart';

class LoginHeader extends StatefulWidget {
  const LoginHeader({super.key});

  @override
  State<LoginHeader> createState() => _LoginHeaderState();
}

class _LoginHeaderState extends State<LoginHeader> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _textController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
    );

    // Start text animation
    _textController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _textController]),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated badge
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppPallate.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                  boxShadow: [
                    BoxShadow(
                      color: AppPallate.primary.withValues(alpha: 0.2),
                      blurRadius: 8 * _pulseAnimation.value,
                      spreadRadius: 2 * (_pulseAnimation.value - 1),
                    ),
                  ],
                ),
                child: const Text(
                  'Hall Meal Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Animated welcome text
            AnimatedOpacity(
              opacity: _textAnimation.value,
              duration: const Duration(milliseconds: 500),
              child: Transform.translate(
                offset: Offset(-20 * (1 - _textAnimation.value), 0),
                child: const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Animated subtitle
            AnimatedOpacity(
              opacity: _textAnimation.value,
              duration: const Duration(milliseconds: 500),
              child: Transform.translate(
                offset: Offset(20 * (1 - _textAnimation.value), 0),
                child: const Text(
                  'Sign in to continue to your account and manage your meal dashboard.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            // Animated decorative container
            AnimatedOpacity(
              opacity: _textAnimation.value,
              duration: const Duration(milliseconds: 500),
              child: Transform.scale(
                scale: 0.9 + (0.1 * _textAnimation.value),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}