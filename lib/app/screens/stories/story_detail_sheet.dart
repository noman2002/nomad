import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../mock/mock_profiles.dart';
import '../../models/story.dart';
import '../../state/session_state.dart';
import '../../state/stories_state.dart';
import 'story_comments_sheet.dart';
import '../profile/full_profile_screen.dart';

class StoryDetailSheet extends StatelessWidget {
  const StoryDetailSheet({super.key, required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final stories = context.watch<StoriesState>();
    final session = context.watch<SessionState>();

    final isLiked = stories.liked.contains(story.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            story.author.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(story.caption, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  stories.toggleLike(story.id);
                },
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: const Color(0xFF111114),
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => StoryCommentsSheet(story: story),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
              ),
              IconButton(
                onPressed: () {
                  session.toggleInterested(story.author.id);
                  if (session.matches.contains(story.author.id)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('It\'s a match with ${story.author.name}!'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.local_fire_department_outlined),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop('map');
                },
                icon: const Icon(Icons.place_outlined),
              ),
              IconButton(
                onPressed: () {
                  Share.share('Nomad story by ${story.author.name}: ${story.caption}');
                },
                icon: const Icon(Icons.share_outlined),
              ),
              const Spacer(),
              FilledButton.tonal(
                onPressed: () async {
                  final profile = MockProfiles.profilesByUserId[story.author.id];
                  if (profile == null) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullProfileScreen(profile: profile),
                    ),
                  );
                },
                child: const Text('Full profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
