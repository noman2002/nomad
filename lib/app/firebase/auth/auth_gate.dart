import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore/user_service.dart';
import '../../state/session_state.dart';
import 'auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ensureSignedIn();
  }

  Future<void> _ensureSignedIn() async {
    try {
      if (AuthService.currentUser == null) {
        await AuthService.signInAnonymously();
      }

      final uid = AuthService.currentUser?.uid;
      if (uid != null) {
        await UserService.upsertUser(
          uid: uid,
          data: {
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }

    if (!mounted) return;
    context.read<SessionState>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return widget.child;
    }

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
