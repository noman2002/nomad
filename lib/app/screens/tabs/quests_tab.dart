import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/quest.dart';
import '../../state/quests_state.dart';
import '../quests/level_up_confetti.dart';

class QuestsTab extends StatefulWidget {
  const QuestsTab({super.key});

  @override
  State<QuestsTab> createState() => _QuestsTabState();
}

class _QuestsTabState extends State<QuestsTab> {
  AdventureLevel? _lastLevel;
  bool _showConfetti = false;

  @override
  Widget build(BuildContext context) {
    final quests = context.watch<QuestsState>();
    final progress = quests.progress;

    if (_lastLevel == null) {
      _lastLevel = progress.level;
    } else if (_lastLevel != progress.level) {
      _lastLevel = progress.level;
      _showConfetti = true;
      Future<void>.delayed(const Duration(milliseconds: 950)).then((_) {
        if (!mounted) return;
        setState(() => _showConfetti = false);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quests')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ScoreCard(progress: progress),
              const SizedBox(height: 16),
              const Text(
                'Active Quests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              for (final q in quests.activeQuests) ...[
                _QuestTile(q),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
              const Text(
                'Daily Challenge',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              _QuestTile(quests.daily, trailing: FilledButton.tonal(
                onPressed: quests.daily.completed ? null : quests.completeDaily,
                child: Text(quests.daily.completed ? 'Done' : 'Complete'),
              )),
              const SizedBox(height: 16),
              const Text(
                'Leaderboard (mock)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const _Leaderboard(),
            ],
          ),
          if (_showConfetti) const Positioned.fill(child: LevelUpConfetti()),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.progress});

  final AdventureProgress progress;

  @override
  Widget build(BuildContext context) {
    final levelLabel = switch (progress.level) {
      AdventureLevel.explorer => 'Explorer',
      AdventureLevel.wanderer => 'Wanderer',
      AdventureLevel.nomad => 'Nomad',
      AdventureLevel.legend => 'Legend',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Adventure Score',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(levelLabel, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${progress.score}',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: progress.toNext, minHeight: 10),
          ),
        ],
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile(this.quest, {this.trailing});

  final Quest quest;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111114),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '${quest.progress}/${quest.goal} • +${quest.points} pts',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ] else if (quest.completed) ...[
            const Icon(Icons.check_circle, color: Colors.greenAccent),
          ],
        ],
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111114),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        children: [
          _LeaderRow(rank: 1, name: 'Sarah', score: 1840),
          SizedBox(height: 10),
          _LeaderRow(rank: 2, name: 'Jess', score: 1710),
          SizedBox(height: 10),
          _LeaderRow(rank: 3, name: 'Mike', score: 1620),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.rank, required this.name, required this.score});

  final int rank;
  final String name;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('#$rank', style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(width: 12),
        Expanded(child: Text(name)),
        Text('$score', style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
