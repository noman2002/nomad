import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/session_state.dart';
import '../widgets/onboarding_scaffold.dart';

class InviteCodeStep extends StatefulWidget {
  const InviteCodeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<InviteCodeStep> createState() => _InviteCodeStepState();
}

class _InviteCodeStepState extends State<InviteCodeStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    if (_controller.text.isEmpty && session.onboarding.inviteCode.isNotEmpty) {
      _controller.text = session.onboarding.inviteCode;
    }

    return OnboardingScaffold(
      title: 'Invite code',
      subtitle: 'Invite-only for safety/exclusivity (mock for now).',
      primaryActionText: 'Continue',
      onPrimaryAction: () {
        session.updateOnboarding((o) {
          o.inviteCode = _controller.text.trim();
        });
        widget.onNext();
      },
      secondaryActionText: session.onboarding.inviteRequested
          ? 'Request sent'
          : 'Request to join',
      onSecondaryAction: session.onboarding.inviteRequested
          ? null
          : () {
              session.updateOnboarding((o) {
                o.inviteRequested = true;
              });
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Enter invite code',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Invite codes are mocked in this prototype.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
