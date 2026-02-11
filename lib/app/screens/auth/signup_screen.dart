import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../firebase/auth/auth_service.dart';
import '../../firebase/firestore/user_service.dart';
import '../../firebase/firestore/data_migration.dart';
import '../../state/session_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create Firebase auth account
      await AuthService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = AuthService.currentUser?.uid;
      if (uid == null) throw Exception('Failed to get user ID');

      // Create user profile in Firestore
      await UserService.upsertUser(
        uid: uid,
        data: {
          'name': _nameController.text.trim(),
          'age': 0, // Will be set during onboarding
          'lookingFor': 'both',
          'activities': [],
          'travelStyle': 'slowExplorer',
          'workSituation': 'remoteWorker',
          'adventureScore': 0,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      // Check if this is the first user - if so, upload mock data
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      if (usersSnapshot.docs.length <= 1) {
        await DataMigration.uploadMockData();
      }

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

  String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'An account with this email already exists';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    }
    return 'Failed to create account. Please try again';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                Text(
                  'Join Nomad',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Start connecting with van lifers',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
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
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'John Doe',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 16),
                
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
                    if (!value.contains('@') || !value.contains('.')) {
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
                  textInputAction: TextInputAction.next,
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
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignup(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 32),
                
                // Signup button
                FilledButton(
                  onPressed: _isLoading ? null : _handleSignup,
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
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Terms text
                Text(
                  'By signing up, you agree to our Terms of Service and Privacy Policy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
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
}
