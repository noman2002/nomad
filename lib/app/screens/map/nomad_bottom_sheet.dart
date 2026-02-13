import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../mock/mock_profiles.dart';
import '../../models/nomad_user.dart';
import '../../revenuecat/revenuecat_paywall_sheet.dart';
import '../../screens/profile/full_profile_screen.dart';
import '../../state/session_state.dart';

class NomadBottomSheet extends StatefulWidget {
  const NomadBottomSheet({super.key, required this.nomad});

  final NomadUser nomad;

  @override
  State<NomadBottomSheet> createState() => _NomadBottomSheetState();
}

class _NomadBottomSheetState extends State<NomadBottomSheet> {
  VideoPlayerController? _controller;

  Future<void> _showUpgradePrompt(String message) async {
    if (!mounted) return;
    final session = context.read<SessionState>();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final upgraded = await showRevenueCatPaywall(this.context);
              if (upgraded) {
                await session.refreshSubscriptionStatus();
              }
            },
            child: const Text('View plans'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
    )
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller?.play();
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _controller != null && _controller!.value.isInitialized
                  ? VideoPlayer(_controller!)
                  : Container(
                      color: Colors.black26,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.nomad.name}, ${widget.nomad.age}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            widget.nomad.activities.take(3).join(' • '),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () async {
                    final didToggle = session.toggleConnect(widget.nomad.id);
                    if (didToggle || session.hasPremiumAccess) return;
                    await _showUpgradePrompt(
                      'Free plan includes ${SessionState.freeConnectsDailyLimit} connects per day. Upgrade for unlimited connects.',
                    );
                  },
                  child: Text(
                    session.connected.contains(widget.nomad.id)
                        ? 'Connected'
                        : 'Connect',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => session.toggleInterested(widget.nomad.id),
                  child: Text(
                    session.interested.contains(widget.nomad.id)
                        ? 'Interested ✓'
                        : 'Interested',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () async {
                if (!session.consumeProfileView()) {
                  await _showUpgradePrompt(
                    'Free plan includes ${SessionState.freeProfileViewsDailyLimit} full profile views per day. Upgrade for unlimited views.',
                  );
                  return;
                }

                final profile = MockProfiles.profilesByUserId[widget.nomad.id];
                if (profile == null) return;

                final result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => FullProfileScreen(profile: profile),
                  ),
                );

                if (!context.mounted) return;
                if (result == 'connect') {
                  final didToggle = session.toggleConnect(widget.nomad.id);
                  if (!didToggle && !session.hasPremiumAccess) {
                    await _showUpgradePrompt(
                      'Free plan includes ${SessionState.freeConnectsDailyLimit} connects per day. Upgrade for unlimited connects.',
                    );
                  }
                } else if (result == 'interested') {
                  session.toggleInterested(widget.nomad.id);
                  if (session.matches.contains(widget.nomad.id)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('It\'s a match with ${widget.nomad.name}!'),
                      ),
                    );
                  }
                }
              },
              child: const Text('View full profile'),
            ),
          ),
          if (!session.hasPremiumAccess) ...[
            const SizedBox(height: 10),
            Text(
              'Free today: ${session.profileViewsRemaining} profile views left • ${session.connectsRemaining} connects left',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
