import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/session_state.dart';
import '../widgets/onboarding_scaffold.dart';

class VideoIntroStep extends StatefulWidget {
  const VideoIntroStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<VideoIntroStep> createState() => _VideoIntroStepState();
}

class _VideoIntroStepState extends State<VideoIntroStep> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();

    return OnboardingScaffold(
      title: 'Record your intro',
      subtitle: '15–60 seconds. One-take. Retake anytime.',
      primaryActionText: session.onboarding.introVideoRecorded
          ? 'Continue'
          : 'Mark as Recorded',
      onPrimaryAction: () {
        final name = _nameController.text.trim();
        session.updateOnboarding((o) {
          if (name.isNotEmpty) {
            o.name = name;
          }
          o.introVideoRecorded = true;
        });
        widget.onNext();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prompts:',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text('• Show us your van'),
          const Text('• What\'s your story?'),
          const Text('• Where are you headed?'),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Name overlay',
              hintText: 'e.g. Noman',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  session.onboarding.introVideoRecorded
                      ? Icons.check_circle
                      : Icons.videocam,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    session.onboarding.introVideoRecorded
                        ? 'Intro video marked as recorded (mock)'
                        : 'Recording is mocked in this prototype.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
