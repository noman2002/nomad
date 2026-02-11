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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const VanAnimation(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Video-first profiles. Real-time community. Built for the road.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
