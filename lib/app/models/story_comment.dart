import 'nomad_user.dart';

typedef StoryCommentId = String;

class StoryComment {
  const StoryComment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  final StoryCommentId id;
  final NomadUser author;
  final String text;
  final DateTime createdAt;
}
