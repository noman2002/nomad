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
              Text(
                'Active Quests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              for (final q in quests.activeQuests) ...[
                _QuestTile(q),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
              Text(
                'Daily Challenge',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              _QuestTile(quests.daily, trailing: FilledButton.tonal(
                onPressed: quests.daily.completed ? null : quests.completeDaily,
                child: Text(quests.daily.completed ? 'Done' : 'Complete'),
              )),
              const SizedBox(height: 16),
              Text(
                'Leaderboard (mock)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Adventure Score',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                levelLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${progress.score}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${quest.progress}/${quest.goal} • +${quest.points} pts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ] else if (quest.completed) ...[
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '#$rank',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '$score',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
