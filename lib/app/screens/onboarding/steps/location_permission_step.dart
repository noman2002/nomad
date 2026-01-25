import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/session_state.dart';
import '../widgets/onboarding_scaffold.dart';

class LocationPermissionStep extends StatelessWidget {
  const LocationPermissionStep({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();

    return OnboardingScaffold(
      title: 'Location permission',
      subtitle: 'Needed to show nearby nomads (mock toggle for now).',
      primaryActionText: 'Finish',
      onPrimaryAction: () {
        session.completeOnboarding();
        onFinish();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: session.onboarding.locationEnabled,
            title: const Text('Enable location (mock)'),
            subtitle: const Text('Background location is mocked in this prototype.'),
            onChanged: (value) {
              session.updateOnboarding((o) => o.locationEnabled = value);
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: const Text(
              'Location is mocked in this prototype.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
