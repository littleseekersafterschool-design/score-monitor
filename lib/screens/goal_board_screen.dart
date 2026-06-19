import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitor_provider.dart';
import '../utils/monitor_theme.dart';

class GoalBoardScreen extends StatelessWidget {
  const GoalBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final goals = provider.goals;
    final todayGoalAvgs = provider.todayGoalAverages;
    final yesterdayGoalAvgs = provider.yesterdayGoalAverages;
    final todayLogs = provider.todayLogs;

    if (goals.isEmpty) {
      return const Center(
        child: Text(
          '目標データなし',
          style: TextStyle(color: MonitorTheme.textMuted, fontSize: 16),
        ),
      );
    }

    // Staff scores per goal
    final staffNames = <String, String>{};
    for (final log in todayLogs) {
      if (!staffNames.containsKey(log.staffId)) {
        staffNames[log.staffId] = provider.getStaffName(log.staffId);
      }
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final avg = todayGoalAvgs[goal.goalId] ?? 0.0;
        final yesterdayAvg = yesterdayGoalAvgs[goal.goalId] ?? 0.0;
        final change = avg - yesterdayAvg;
        final color = MonitorTheme.getGoalColor(goal.color);

        // Get individual staff scores for this goal
        final staffScores = <String, int>{};
        for (final log in todayLogs) {
          if (log.goalId == goal.goalId) {
            staffScores[log.staffId] = log.score;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MonitorTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MonitorTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      MonitorTheme.getGoalIcon(goal.icon),
                      size: 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: MonitorTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          goal.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: MonitorTheme.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        avg > 0 ? avg.toStringAsFixed(2) : '---',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: avg > 0
                              ? MonitorTheme.getScoreColor(avg)
                              : MonitorTheme.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (avg > 0 && yesterdayAvg > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              MonitorTheme.getChangeIcon(change),
                              size: 12,
                              color: MonitorTheme.getChangeColor(change),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${MonitorTheme.getChangePrefix(change)}${change.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: MonitorTheme.getChangeColor(change),
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              if (staffScores.isNotEmpty) ...[
                const SizedBox(height: 14),
                // Score bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: avg / 5.0,
                    backgroundColor: MonitorTheme.bgSurface,
                    color: color,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                // Staff breakdown
                Wrap(
                  spacing: isLandscape ? 16 : 8,
                  runSpacing: 8,
                  children: staffScores.entries.map((entry) {
                    final name = staffNames[entry.key] ?? '---';
                    final score = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: MonitorTheme.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: MonitorTheme.border.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: MonitorTheme.getScoreColor(
                                      score.toDouble())
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0] : '?',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: MonitorTheme.getScoreColor(
                                      score.toDouble()),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: MonitorTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: MonitorTheme.getScoreColor(
                                  score.toDouble()),
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
