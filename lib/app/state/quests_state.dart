import 'package:flutter/foundation.dart';

import '../models/quest.dart';

class QuestsState extends ChangeNotifier {
  int milesTraveled = 120;
  int locationsVisited = 7;

  final List<Quest> activeQuests = <Quest>[
    const Quest(
      id: 'q1',
      title: 'Visit 3 new states',
      progress: 2,
      goal: 3,
      points: 50,
    ),
    const Quest(
      id: 'q2',
      title: 'Meet 5 nomads in person',
      progress: 1,
      goal: 5,
      points: 100,
    ),
    const Quest(
      id: 'q3',
      title: 'Camp above 5000ft',
      progress: 0,
      goal: 1,
      points: 25,
    ),
    const Quest(
      id: 'q4',
      title: 'Share your sunrise spot',
      progress: 0,
      goal: 1,
      points: 15,
    ),
  ];

  Quest daily = const Quest(
    id: 'd1',
    title: 'Post a video today',
    progress: 0,
    goal: 1,
    points: 10,
  );

  int get connectionsMade => 0;

  int get score {
    final base = (milesTraveled ~/ 10) + (locationsVisited * 25) + (connectionsMade * 40);
    final questPoints = activeQuests
        .where((q) => q.completed)
        .fold<int>(0, (sum, q) => sum + q.points);
    final dailyPoints = daily.completed ? daily.points : 0;
    return base + questPoints + dailyPoints;
  }

  AdventureProgress get progress {
    final s = score;
    if (s < 500) {
      return AdventureProgress(score: s, level: AdventureLevel.explorer, toNext: s / 500);
    }
    if (s < 1500) {
      return AdventureProgress(
        score: s,
        level: AdventureLevel.wanderer,
        toNext: (s - 500) / 1000,
      );
    }
    if (s < 3000) {
      return AdventureProgress(
        score: s,
        level: AdventureLevel.nomad,
        toNext: (s - 1500) / 1500,
      );
    }
    return const AdventureProgress(score: 3000, level: AdventureLevel.legend, toNext: 1);
  }

  void completeDaily() {
    if (daily.completed) return;
    daily = Quest(
      id: daily.id,
      title: daily.title,
      points: daily.points,
      progress: daily.goal,
      goal: daily.goal,
    );
    notifyListeners();
  }
}
