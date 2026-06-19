import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitor_provider.dart';
import '../utils/monitor_theme.dart';

/// Tab 2: 各スコア — Goal-by-goal score list, items scrollable.
class ScoresScreen extends StatelessWidget {
  const ScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final goalAvgs = provider.displayDayGoalAverages;
    final compGoalAvgs = provider.comparisonDayGoalAverages;
    final goals = provider.goals;

    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u{2B50}', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              'もくひょうデータなし',
              style: TextStyle(
                color: MonitorTheme.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          // Fixed header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: MonitorTheme.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: MonitorTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: MonitorTheme.yellowBg,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.star_rounded,
                      size: 14, color: MonitorTheme.yellow),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'もくひょう スコア  ${provider.displayDateLabel}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MonitorTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${goals.length} こもく',
                  style: const TextStyle(
                    fontSize: 12,
                    color: MonitorTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable items
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: MonitorTheme.white,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: const Border(
                  left: BorderSide(color: MonitorTheme.border),
                  right: BorderSide(color: MonitorTheme.border),
                  bottom: BorderSide(color: MonitorTheme.border),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final avg = goalAvgs[goal.goalId] ?? 0.0;
                  final compAvg =
                      compGoalAvgs[goal.goalId] ?? 0.0;
                  final goalChange = avg - compAvg;
                  final color = MonitorTheme.getGoalColor(goal.color);
                  final emoji = MonitorTheme.getScoreEmoji(avg);
                  final scoreColor = avg > 0
                      ? MonitorTheme.getScoreColor(avg)
                      : MonitorTheme.textMuted;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      border: index < goals.length - 1
                          ? const Border(
                              bottom: BorderSide(
                                  color: MonitorTheme.border, width: 0.5),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Goal icon
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            MonitorTheme.getGoalIcon(goal.icon),
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name + mini bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                goal.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: MonitorTheme.textPrimary,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              _MiniScoreBar(score: avg, color: color),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Emoji
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 6),
                        // Score
                        SizedBox(
                          width: 48,
                          child: Text(
                            avg > 0 ? avg.toStringAsFixed(1) : '---',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: scoreColor,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                        // Change
                        if (avg > 0 && compAvg > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  MonitorTheme.getChangeIcon(goalChange),
                                  size: 15,
                                  color: MonitorTheme.getChangeColor(
                                      goalChange),
                                ),
                                const SizedBox(width: 1),
                                Text(
                                  '${MonitorTheme.getChangePrefix(goalChange)}${goalChange.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: MonitorTheme.getChangeColor(
                                        goalChange),
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MiniScoreBar extends StatelessWidget {
  final double score;
  final Color color;
  const _MiniScoreBar({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = score >= (i + 1);
        final partial = score > i && score < (i + 1);
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 4 ? 2 : 0),
            height: 6,
            decoration: BoxDecoration(
              color: filled
                  ? color
                  : partial
                      ? color.withValues(alpha: 0.3)
                      : MonitorTheme.bgSurface,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
