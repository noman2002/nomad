import 'package:flutter/material.dart';

import '../widgets/onboarding_scaffold.dart';
import '../widgets/van_animation.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Welcome to Nomad',
      subtitle: 'Where van lifers connect.',
      primaryActionText: 'Get Started',
      onPrimaryAction: onNext,
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: const VanAnimation(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Video-first profiles. Real-time community. Built for the road.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
