import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/features/auth/prasentation/widgets/login_form.dart';
import 'package:meal_management/features/auth/prasentation/widgets/login_header.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _formController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _formAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOut),
    );

    // Start form animation after a delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_backgroundController, _formController]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppPallate.gradient1,
                  AppPallate.gradient2,
                  AppPallate.gradient3,
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Animated background blobs
                      AnimatedPositioned(
                        duration: const Duration(seconds: 2),
                        top: -40 + (_backgroundAnimation.value * 20),
                        left: -30 + (_backgroundAnimation.value * 10),
                        child: Transform.rotate(
                          angle: _backgroundAnimation.value * 0.5,
                          child: _AnimatedGlowBlob(
                            color: Colors.white.withValues(alpha: 0.18),
                            size: 150 + (_backgroundAnimation.value * 20),
                            animation: _backgroundAnimation,
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(seconds: 2),
                        top: 80 + (_backgroundAnimation.value * 15),
                        right: -25 + (_backgroundAnimation.value * 8),
                        child: Transform.rotate(
                          angle: _backgroundAnimation.value * -0.3,
                          child: _AnimatedGlowBlob(
                            color: Colors.white.withValues(alpha: 0.12),
                            size: 110 + (_backgroundAnimation.value * 15),
                            animation: _backgroundAnimation,
                          ),
                        ),
                      ),
                      // Additional floating elements
                      Positioned(
                        bottom: 100,
                        left: 50,
                        child: _FloatingElement(
                          animation: _backgroundAnimation,
                          delay: 0.5,
                        ),
                      ),
                      Positioned(
                        bottom: 200,
                        right: 80,
                        child: _FloatingElement(
                          animation: _backgroundAnimation,
                          delay: 0.8,
                        ),
                      ),

                      // Main content
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight - 56),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 28),
                              // Animated header
                              AnimatedOpacity(
                                opacity: _formAnimation.value,
                                duration: const Duration(milliseconds: 500),
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - _formAnimation.value)),
                                  child: const LoginHeader(),
                                ),
                              ),
                              const SizedBox(height: 28),
                              // Animated form
                              AnimatedOpacity(
                                opacity: _formAnimation.value,
                                duration: const Duration(milliseconds: 500),
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Transform.translate(
                                    offset: Offset(0, 30 * (1 - _formAnimation.value)),
                                    child: const LoginForm(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedGlowBlob extends StatelessWidget {
  const _AnimatedGlowBlob({
    required this.color,
    required this.size,
    required this.animation,
  });

  final Color color;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20 + (animation.value * 10),
            spreadRadius: 5 + (animation.value * 5),
          ),
        ],
      ),
    );
  }
}

class _FloatingElement extends StatelessWidget {
  const _FloatingElement({
    required this.animation,
    required this.delay,
  });

  final Animation<double> animation;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(delay, 1.0, curve: Curves.easeInOut),
      ),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            -10 + (delayedAnimation.value * 20),
          ),
          child: Opacity(
            opacity: 0.1 + (delayedAnimation.value * 0.2),
            child: Container(
              width: 20 + (delayedAnimation.value * 10),
              height: 20 + (delayedAnimation.value * 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        );
      },
    );
  }
}