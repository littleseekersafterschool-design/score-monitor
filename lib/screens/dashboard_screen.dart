import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitor_provider.dart';
import '../utils/monitor_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();

    final todayAvg = provider.todayAverage;
    final change = provider.dailyChange;
    final monthAvg = provider.thisMonthAverage;
    final yearAvg = provider.thisYearAverage;
    final goalAvgs = provider.todayGoalAverages;
    final yesterdayGoalAvgs = provider.yesterdayGoalAverages;
    final goals = provider.goals;

    // Full-screen layout: fixed summary at top, scrollable goals below
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // ── Fixed top: score summary row ──
          _buildSummaryRow(todayAvg, change, monthAvg, yearAvg),
          const SizedBox(height: 10),
          // ── Scrollable bottom: goal list fills remaining space ──
          Expanded(
            child: _buildGoalList(provider, goalAvgs, yesterdayGoalAvgs, goals),
          ),
        ],
      ),
    );
  }

  // ── Compact summary: today + month + year in one row ──
  Widget _buildSummaryRow(
      double todayAvg, double change, double monthAvg, double yearAvg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's score — takes more space
        Expanded(
          flex: 5,
          child: _buildTodayCard(todayAvg, change),
        ),
        const SizedBox(width: 8),
        // Month average
        Expanded(
          flex: 3,
          child: _buildAvgCard(
            label: 'こんげつ',
            icon: Icons.calendar_today_rounded,
            avg: monthAvg,
            bgColor: MonitorTheme.yellowBg,
            iconColor: MonitorTheme.yellow,
          ),
        ),
        const SizedBox(width: 8),
        // Year average
        Expanded(
          flex: 3,
          child: _buildAvgCard(
            label: 'ことし',
            icon: Icons.auto_awesome_rounded,
            avg: yearAvg,
            bgColor: MonitorTheme.redBg,
            iconColor: MonitorTheme.red,
          ),
        ),
      ],
    );
  }

  // ── Today's score card (compact) ──
  Widget _buildTodayCard(double todayAvg, double change) {
    final emoji = MonitorTheme.getScoreEmoji(todayAvg);
    final scoreColor = todayAvg > 0
        ? MonitorTheme.getScoreColor(todayAvg)
        : MonitorTheme.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: MonitorTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MonitorTheme.border),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MonitorTheme.blueBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'きょうのスコア',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: MonitorTheme.blue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Emoji + score row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 8),
              Text(
                todayAvg > 0 ? todayAvg.toStringAsFixed(1) : '---',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                ' / 5',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: MonitorTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Score bar
          _buildKidScoreBar(todayAvg),
          // Change badge
          if (todayAvg > 0 && change.abs() > 0.001) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  MonitorTheme.getChangeIcon(change),
                  size: 16,
                  color: MonitorTheme.getChangeColor(change),
                ),
                const SizedBox(width: 4),
                Text(
                  'きのうから ${MonitorTheme.getChangePrefix(change)}${change.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: MonitorTheme.getChangeColor(change),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Average card (month / year) ──
  Widget _buildAvgCard({
    required String label,
    required IconData icon,
    required double avg,
    required Color bgColor,
    required Color iconColor,
  }) {
    final scoreColor =
        avg > 0 ? MonitorTheme.getScoreColor(avg) : MonitorTheme.textMuted;
    final emoji = MonitorTheme.getScoreEmoji(avg);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: MonitorTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MonitorTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: iconColor),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 2),
          Text(
            avg > 0 ? avg.toStringAsFixed(1) : '---',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: scoreColor,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKidScoreBar(avg),
          ),
        ],
      ),
    );
  }

  Widget _buildKidScoreBar(double score) {
    final colors = [
      MonitorTheme.red,
      MonitorTheme.red,
      MonitorTheme.yellow,
      MonitorTheme.blue,
      MonitorTheme.blue,
    ];

    return Row(
      children: List.generate(5, (i) {
        final filled = score >= (i + 1);
        final partial = score > i && score < (i + 1);
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 4 ? 3 : 0),
            height: 10,
            decoration: BoxDecoration(
              color: filled
                  ? colors[i]
                  : partial
                      ? colors[i].withValues(alpha: 0.3)
                      : MonitorTheme.bgSurface,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }

  // ── Mini score bar for goal rows ──
  Widget _buildMiniScoreBar(double score, Color accentColor) {
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
                  ? accentColor
                  : partial
                      ? accentColor.withValues(alpha: 0.3)
                      : MonitorTheme.bgSurface,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  // ── Goal list with fixed header + scrollable items ──
  Widget _buildGoalList(
      MonitorProvider provider,
      Map<String, double> goalAvgs,
      Map<String, double> yesterdayGoalAvgs,
      List goals) {
    if (goals.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: MonitorTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MonitorTheme.border),
        ),
        child: const Center(
          child: Text(
            'もくひょうデータなし',
            style: TextStyle(
              color: MonitorTheme.textMuted,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: MonitorTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MonitorTheme.border),
      ),
      child: Column(
        children: [
          // Fixed header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: MonitorTheme.border),
              ),
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
                const Text(
                  'もくひょうスコア',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MonitorTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable goal items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final avg = goalAvgs[goal.goalId] ?? 0.0;
                final yesterdayAvg =
                    yesterdayGoalAvgs[goal.goalId] ?? 0.0;
                final goalChange = avg - yesterdayAvg;
                final color = MonitorTheme.getGoalColor(goal.color);
                final emoji = MonitorTheme.getScoreEmoji(avg);
                final scoreColor = avg > 0
                    ? MonitorTheme.getScoreColor(avg)
                    : MonitorTheme.textMuted;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
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
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          MonitorTheme.getGoalIcon(goal.icon),
                          size: 17,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Goal name + mini bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              goal.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: MonitorTheme.textPrimary,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            _buildMiniScoreBar(avg, color),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Emoji
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      // Score
                      SizedBox(
                        width: 44,
                        child: Text(
                          avg > 0 ? avg.toStringAsFixed(1) : '---',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: scoreColor,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                      ),
                      // Change indicator
                      if (avg > 0 && yesterdayAvg > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                MonitorTheme.getChangeIcon(goalChange),
                                size: 14,
                                color:
                                    MonitorTheme.getChangeColor(goalChange),
                              ),
                              Text(
                                '${MonitorTheme.getChangePrefix(goalChange)}${goalChange.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 12,
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
        ],
      ),
    );
  }
}
