import 'package:flutter/foundation.dart';

import '../mock/mock_stories.dart';
import '../models/nomad_user.dart';
import '../models/story.dart';
import '../models/story_comment.dart';

class StoriesState extends ChangeNotifier {
  StoryCategory category = StoryCategory.forYou;

  final Set<StoryId> liked = <StoryId>{};
  final Map<StoryId, List<StoryComment>> _commentsByStory =
      <StoryId, List<StoryComment>>{};

  List<Story> get visibleStories {
    return MockStories.stories.where((s) {
      if (category == StoryCategory.forYou) return true;
      return s.category == category;
    }).toList();
  }

  List<StoryComment> commentsFor(StoryId storyId) {
    return List<StoryComment>.unmodifiable(
      _commentsByStory[storyId] ?? const <StoryComment>[],
    );
  }

  int commentCount(StoryId storyId) => _commentsByStory[storyId]?.length ?? 0;

  void addComment({
    required StoryId storyId,
    required NomadUser author,
    required String text,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final list = [...(_commentsByStory[storyId] ?? const <StoryComment>[])];
    list.add(
      StoryComment(
        id: 'c-${DateTime.now().microsecondsSinceEpoch}',
        author: author,
        text: trimmed,
        createdAt: DateTime.now(),
      ),
    );
    _commentsByStory[storyId] = list;
    notifyListeners();
  }

  void setCategory(StoryCategory c) {
    category = c;
    notifyListeners();
  }

  void toggleLike(StoryId id) {
    if (liked.contains(id)) {
      liked.remove(id);
    } else {
      liked.add(id);
    }
    notifyListeners();
  }
}
