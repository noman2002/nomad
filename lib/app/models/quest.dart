class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.points,
    required this.progress,
    required this.goal,
  });

  final String id;
  final String title;
  final int points;
  final int progress;
  final int goal;

  bool get completed => progress >= goal;
}

enum AdventureLevel { explorer, wanderer, nomad, legend }

class AdventureProgress {
  const AdventureProgress({required this.score, required this.level, required this.toNext});

  final int score;
  final AdventureLevel level;
  final double toNext;
}
