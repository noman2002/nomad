import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/nomad_user.dart';
import '../../../state/session_state.dart';
import '../widgets/onboarding_scaffold.dart';

class VibeStep extends StatelessWidget {
  const VibeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  static const availableActivities = <String>[
    'climbing',
    'surfing',
    'hiking',
    'yoga',
    'photography',
    'coffee',
    'van builds',
    'snowboarding',
    'trail running',
    'camping',
  ];

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final selected = session.onboarding.activities;

    return OnboardingScaffold(
      title: 'Your vibe',
      subtitle: 'Pick up to 5 activities.',
      primaryActionText: 'Continue',
      onPrimaryAction: selected.isEmpty ? null : onNext,
      child: ListView(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in availableActivities)
                FilterChip(
                  label: Text(a),
                  selected: selected.contains(a),
                  onSelected: (isSelected) {
                    session.updateOnboarding((o) {
                      if (isSelected) {
                        if (o.activities.length >= 5) return;
                        o.activities.add(a);
                      } else {
                        o.activities.remove(a);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<TravelStyle>(
            value: session.onboarding.travelStyle,
            decoration: const InputDecoration(
              labelText: 'Travel style',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: TravelStyle.slowExplorer,
                child: Text('Slow Explorer'),
              ),
              DropdownMenuItem(
                value: TravelStyle.fastMover,
                child: Text('Fast Mover'),
              ),
              DropdownMenuItem(
                value: TravelStyle.weekendWarrior,
                child: Text('Weekend Warrior'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              session.updateOnboarding((o) => o.travelStyle = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<WorkSituation>(
            value: session.onboarding.workSituation,
            decoration: const InputDecoration(
              labelText: 'Work situation',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: WorkSituation.remoteWorker,
                child: Text('Remote worker'),
              ),
              DropdownMenuItem(
                value: WorkSituation.seasonal,
                child: Text('Seasonal'),
              ),
              DropdownMenuItem(
                value: WorkSituation.retired,
                child: Text('Retired'),
              ),
              DropdownMenuItem(
                value: WorkSituation.other,
                child: Text('Other'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              session.updateOnboarding((o) => o.workSituation = value);
            },
          ),
          const SizedBox(height: 12),
          Text(
            '${selected.length}/5 selected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
