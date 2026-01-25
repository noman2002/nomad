import 'nomad_user.dart';

typedef StoryId = String;

enum StoryCategory { forYou, nearby, onYourRoute, epicBuilds, soloWomen }

class Story {
  const Story({
    required this.id,
    required this.author,
    required this.videoUrl,
    required this.caption,
    required this.category,
  });

  final StoryId id;
  final NomadUser author;
  final String videoUrl;
  final String caption;
  final StoryCategory category;
}
