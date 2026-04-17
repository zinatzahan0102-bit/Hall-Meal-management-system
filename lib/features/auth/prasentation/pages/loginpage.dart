import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_Pallate.dart';
import 'package:meal_management/features/auth/prasentation/widgets/login_form.dart';
import 'package:meal_management/features/auth/prasentation/widgets/login_header.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppPallate.gradient1,
              AppPallate.gradient2,
              Color(0xFFF7FAFF),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: -40,
                    left: -30,
                    child: _GlowBlob(color: Colors.white.withOpacity(0.18), size: 150),
                  ),
                  Positioned(
                    top: 80,
                    right: -25,
                    child: _GlowBlob(color: Colors.white.withOpacity(0.12), size: 110),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 56),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 28),
                          LoginHeader(),
                          SizedBox(height: 28),
                          LoginForm(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}