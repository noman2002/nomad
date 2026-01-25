import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_state.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.currentUser.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text('Age: ${session.currentUser.age}'),
            const SizedBox(height: 8),
            Text('Looking for: ${session.currentUser.lookingFor.name}'),
            const SizedBox(height: 8),
            Text('Activities: ${session.currentUser.activities.join(', ')}'),
            const SizedBox(height: 16),
            Text('Matches: ${session.matches.length}'),
            const SizedBox(height: 8),
            const Text(
              'Signed in (prototype)',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
