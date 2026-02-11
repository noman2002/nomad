import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../firebase/auth/auth_service.dart';
import '../../firebase/firestore/user_service.dart';
import '../../state/session_state.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Load user data
      await context.read<SessionState>().loadCurrentUser();

      // Navigation is handled by AuthGate
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the test account for guest mode
      await AuthService.signInWithEmailPassword(
        email: 'test@nomad.app',
        password: 'test123456',
      );

      if (!mounted) return;
      await context.read<SessionState>().loadCurrentUser();
    } catch (e) {
      // If test account doesn't exist, create it
      try {
        await AuthService.createAccount(
          email: 'test@nomad.app',
          password: 'test123456',
        );

        if (!mounted) return;
        await context.read<SessionState>().loadCurrentUser();
      } catch (createError) {
        setState(() {
          _errorMessage = 'Failed to sign in as guest: ${createError.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later';
    }
    return 'Failed to sign in. Please try again';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo/Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Welcome to Nomad',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Connect with van lifers on the road',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'your@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 8),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () => _showForgotPasswordDialog(),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login button
                FilledButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Guest login button
                OutlinedButton(
                  onPressed: _isLoading ? null : _handleGuestLogin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid email')),
                );
                return;
              }
              
              try {
                await AuthService.resetPassword(email);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent! Check your inbox.'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
