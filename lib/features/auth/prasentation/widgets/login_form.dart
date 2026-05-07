import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';
import 'package:meal_management/features/navigation/presentation/pages/main_navigation_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _formController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for each form element
    _animations = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _formController,
          curve: Interval(start, end, curve: Curves.elasticOut),
        ),
      );
    });

    // Start animations
    _formController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _formController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Check if user exists in Firestore
        // AuthWrapper will navigate automatically
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in successfully')),
          );
          // Give a moment for auth state to propagate, then navigate
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                (route) => false,
              );
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    try {
      await AuthService().resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title animation
              AnimatedOpacity(
                opacity: _animations[0].value.clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 300),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _animations[0].value)),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF132238),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle animation
              AnimatedOpacity(
                opacity: _animations[1].value.clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 300),
                child: Transform.translate(
                  offset: Offset(0, 15 * (1 - _animations[1].value)),
                  child: const Text(
                    'Use your account details to get started.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Email field animation
              AnimatedOpacity(
                opacity: _animations[2].value.clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 300),
                child: Transform.translate(
                  offset: Offset(-30 * (1 - _animations[2].value), 0),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email or phone number',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Password field animation
              AnimatedOpacity(
                opacity: _animations[3].value.clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 300),
                child: Transform.translate(
                  offset: Offset(30 * (1 - _animations[3].value), 0),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Forgot password animation
              AnimatedOpacity(
                opacity: _animations[4].value.clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 300),
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - _animations[4].value)),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppPallate.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Login button animation
              AnimatedOpacity(
                opacity: _animations[5].value.clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 300),
                child: Transform.scale(
                  scale: 0.8 + (0.2 * _animations[5].value),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}