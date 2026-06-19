import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitor_provider.dart';
import '../models/daily_log.dart';
import '../utils/monitor_theme.dart';

class StaffBoardScreen extends StatelessWidget {
  const StaffBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final staffList = provider.staff;
    final todayLogs = provider.todayLogs;
    final goals = provider.goals;

    if (staffList.isEmpty) {
      return const Center(
        child: Text(
          'スタッフデータなし',
          style: TextStyle(color: MonitorTheme.textMuted, fontSize: 16),
        ),
      );
    }

    // Group today's logs by staff
    final logsByStaff = <String, List<DailyLog>>{};
    for (final log in todayLogs) {
      logsByStaff.putIfAbsent(log.staffId, () => []).add(log);
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return _buildLandscapeGrid(staffList, logsByStaff, goals, provider);
    }
    return _buildPortraitList(staffList, logsByStaff, goals, provider);
  }

  Widget _buildLandscapeGrid(List staffList,
      Map<String, List<DailyLog>> logsByStaff, List goals,
      MonitorProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: staffList.length <= 4 ? 2 : 3,
        childAspectRatio: 1.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        return _buildStaffCard(
            staffList[index], logsByStaff, goals, provider);
      },
    );
  }

  Widget _buildPortraitList(List staffList,
      Map<String, List<DailyLog>> logsByStaff, List goals,
      MonitorProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildStaffCard(
              staffList[index], logsByStaff, goals, provider),
        );
      },
    );
  }

  Widget _buildStaffCard(dynamic staff,
      Map<String, List<DailyLog>> logsByStaff, List goals,
      MonitorProvider provider) {
    final logs = logsByStaff[staff.staffId] ?? [];
    final avg = logs.isEmpty
        ? 0.0
        : logs.fold<int>(0, (s, l) => s + l.score) / logs.length;

    // Log count by goal
    final goalScores = <String, int>{};
    for (final log in logs) {
      goalScores[log.goalId] = log.score;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MonitorTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MonitorTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: avg > 0
                      ? MonitorTheme.getScoreColor(avg).withValues(alpha: 0.15)
                      : MonitorTheme.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    staff.staffName.isNotEmpty ? staff.staffName[0] : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: avg > 0
                          ? MonitorTheme.getScoreColor(avg)
                          : MonitorTheme.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.staffName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: MonitorTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      logs.isEmpty ? '未入力' : '${logs.length}件記録',
                      style: TextStyle(
                        fontSize: 11,
                        color: MonitorTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Big score
              Text(
                avg > 0 ? avg.toStringAsFixed(1) : '---',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: avg > 0
                      ? MonitorTheme.getScoreColor(avg)
                      : MonitorTheme.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (logs.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Goal scores as mini chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: goals.map((goal) {
                final score = goalScores[goal.goalId];
                final color = MonitorTheme.getGoalColor(goal.color);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: score != null
                        ? color.withValues(alpha: 0.12)
                        : MonitorTheme.bgSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: score != null
                          ? color.withValues(alpha: 0.3)
                          : MonitorTheme.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MonitorTheme.getGoalIcon(goal.icon),
                        size: 12,
                        color: score != null ? color : MonitorTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        score != null ? '$score' : '-',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: score != null
                              ? MonitorTheme.getScoreColor(score.toDouble())
                              : MonitorTheme.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
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
  }
}
