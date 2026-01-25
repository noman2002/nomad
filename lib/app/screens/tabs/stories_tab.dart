import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/story.dart';
import '../../state/nav_state.dart';
import '../../state/stories_state.dart';
import '../stories/story_comments_sheet.dart';
import '../stories/story_detail_sheet.dart';
import '../stories/story_player.dart';

class StoriesTab extends StatefulWidget {
  const StoriesTab({super.key});

  @override
  State<StoriesTab> createState() => _StoriesTabState();
}

class _StoriesTabState extends State<StoriesTab> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storiesState = context.watch<StoriesState>();
    final stories = storiesState.visibleStories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CategoryChip(
                  label: 'For You',
                  selected: storiesState.category == StoryCategory.forYou,
                  onTap: () => storiesState.setCategory(StoryCategory.forYou),
                ),
                _CategoryChip(
                  label: 'Nearby',
                  selected: storiesState.category == StoryCategory.nearby,
                  onTap: () => storiesState.setCategory(StoryCategory.nearby),
                ),
                _CategoryChip(
                  label: 'On Your Route',
                  selected: storiesState.category == StoryCategory.onYourRoute,
                  onTap: () => storiesState.setCategory(StoryCategory.onYourRoute),
                ),
                _CategoryChip(
                  label: 'Epic Builds',
                  selected: storiesState.category == StoryCategory.epicBuilds,
                  onTap: () => storiesState.setCategory(StoryCategory.epicBuilds),
                ),
                _CategoryChip(
                  label: 'Solo Women',
                  selected: storiesState.category == StoryCategory.soloWomen,
                  onTap: () => storiesState.setCategory(StoryCategory.soloWomen),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Stack(
            children: [
              StoryPlayer(
                videoUrl: story.videoUrl,
                onDoubleTap: () => storiesState.toggleLike(story.id),
              ),
              Positioned(
                left: 16,
                right: 90,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.author.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                bottom: 24,
                child: _ActionRail(
                  story: story,
                  liked: storiesState.liked.contains(story.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        label: Text(label),
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({required this.story, required this.liked});

  final Story story;
  final bool liked;

  @override
  Widget build(BuildContext context) {
    final stories = context.read<StoriesState>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => stories.toggleLike(story.id),
          icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
        ),
        Text(
          '${stories.commentCount(story.id)}',
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 2),
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
        const SizedBox(height: 6),
        IconButton(
          onPressed: () {
            showModalBottomSheet<String>(
              context: context,
              backgroundColor: const Color(0xFF111114),
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => StoryDetailSheet(story: story),
            ).then((result) {
              if (result == 'map' && context.mounted) {
                context.read<NavState>().setIndex(0);
              }
            });
          },
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}
