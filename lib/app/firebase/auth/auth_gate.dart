import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/auth/login_screen.dart';
import '../../state/session_state.dart';
import '../firebase_refs.dart';
import '../firestore/data_migration.dart';
import '../firestore/user_service.dart';
import '../../revenuecat/revenuecat_bootstrap.dart';
import 'auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  String? _error;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();

    // Listen to auth state changes
    AuthService.authStateChanges.listen((user) {
      if (mounted) {
        setState(() {
          _isAuthenticated = user != null;
          _loading = false;
        });

        if (user != null) {
          _initializeUser();
        } else {
          clearRevenueCatUser();
        }
      }
    });
  }

  Future<void> _checkAuthState() async {
    final currentUser = AuthService.currentUser;

    setState(() {
      _isAuthenticated = currentUser != null;
      _loading = false;
    });

    if (currentUser != null) {
      await _initializeUser();
    }
  }

  Future<void> _initializeUser() async {
    try {
      final uid = AuthService.currentUser?.uid;
      if (uid == null) return;

      // Add retry logic for Firestore connectivity issues
      int retries = 3;
      bool success = false;

      while (retries > 0 && !success) {
        try {
          // Check if user document exists
          final userDoc = await FirebaseRefs.firestore.collection('users').doc(uid).get();

          if (!userDoc.exists) {
            // First time user - create their document
            await UserService.upsertUser(
              uid: uid,
              data: {
                'name': 'New User',
                'age': 0,
                'lookingFor': 'both',
                'activities': [],
                'travelStyle': 'slowExplorer',
                'workSituation': 'remoteWorker',
                'adventureScore': 0,
                'createdAt': FieldValue.serverTimestamp(),
              },
            );

            // Check if we should upload mock data (if there are very few users)
            final usersSnapshot = await FirebaseRefs.firestore.collection('users').get();
            if (usersSnapshot.docs.length <= 1) {
              await DataMigration.uploadMockData();
            }
          }

          success = true;

          // Load user data into session state
          if (mounted) {
            await context.read<SessionState>().loadCurrentUser();
          }

        } catch (e) {
          retries--;
          if (retries > 0) {
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(seconds: 2 * (3 - retries)));
          } else {
            rethrow;
          }
        }
      }
    } catch (e) {
      setState(() {
        _error =
            'Failed to connect to Firestore. Please check:\n'
            '1. Firebase rules are deployed\n'
            '2. You have internet connection\n'
            '3. Firestore is enabled in Firebase Console\n\n'
            'Error: $e';
      });
      debugPrint('Auth error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return widget.child;
    }

    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading...', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Connection Error', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _checkAuthState();
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    await context.read<SessionState>().signOut();
                    setState(() {
                      _isAuthenticated = false;
                      _error = null;
                    });
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show login screen if not authenticated
    if (!_isAuthenticated) {
      return const LoginScreen();
    }

    // Show app if authenticated
    return widget.child;
  }
}
