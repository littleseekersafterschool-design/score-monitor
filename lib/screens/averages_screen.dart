import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitor_provider.dart';
import '../utils/monitor_theme.dart';

/// Tab 1: へいきん — Today / Month / Year averages.
/// Adapts layout based on available width AND height to handle all
/// phone/tablet + portrait/landscape combinations without overflow.
class AveragesScreen extends StatelessWidget {
  const AveragesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final displayAvg = provider.displayDayAverage;
    final change = provider.displayDayChange;
    final dateLabel = provider.displayDateLabel;
    final monthAvg = provider.thisMonthAverage;
    final yearAvg = provider.thisYearAverage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final isWide = w > h; // landscape-ish
        final isBig = w > 600 && h > 400; // tablet with enough room
        final pad = isBig ? 16.0 : 10.0;

        // ── Layout A: Tablet landscape (wide + tall enough) ──
        // Today left 55%, month+year stacked right 45%
        if (isWide && isBig) {
          return Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 55,
                  child: _DisplayDayCard(avg: displayAvg, change: change, dateLabel: dateLabel),
                ),
                SizedBox(width: pad),
                Expanded(
                  flex: 45,
                  child: Column(
                    children: [
                      Expanded(
                        child: _AvgCard(
                          label: 'こんげつ の へいきん',
                          icon: Icons.calendar_today_rounded,
                          avg: monthAvg,
                          tintColor: MonitorTheme.yellow,
                          tintBg: MonitorTheme.yellowBg,
                        ),
                      ),
                      SizedBox(height: pad),
                      Expanded(
                        child: _AvgCard(
                          label: 'ことし の へいきん',
                          icon: Icons.auto_awesome_rounded,
                          avg: yearAvg,
                          tintColor: MonitorTheme.red,
                          tintBg: MonitorTheme.redBg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // ── Layout B: Phone landscape (wide but short) ──
        // All three cards in a horizontal row
        if (isWide) {
          return Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _DisplayDayCard(avg: displayAvg, change: change, dateLabel: dateLabel),
                ),
                SizedBox(width: pad),
                Expanded(
                  flex: 3,
                  child: _AvgCard(
                    label: 'こんげつ',
                    icon: Icons.calendar_today_rounded,
                    avg: monthAvg,
                    tintColor: MonitorTheme.yellow,
                    tintBg: MonitorTheme.yellowBg,
                  ),
                ),
                SizedBox(width: pad),
                Expanded(
                  flex: 3,
                  child: _AvgCard(
                    label: 'ことし',
                    icon: Icons.auto_awesome_rounded,
                    avg: yearAvg,
                    tintColor: MonitorTheme.red,
                    tintBg: MonitorTheme.redBg,
                  ),
                ),
              ],
            ),
          );
        }

        // ── Layout C: Portrait (phone or tablet) ──
        // Today top, month+year side-by-side bottom
        return Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: _DisplayDayCard(avg: displayAvg, change: change, dateLabel: dateLabel),
              ),
              SizedBox(height: pad),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      child: _AvgCard(
                        label: 'こんげつ',
                        icon: Icons.calendar_today_rounded,
                        avg: monthAvg,
                        tintColor: MonitorTheme.yellow,
                        tintBg: MonitorTheme.yellowBg,
                      ),
                    ),
                    SizedBox(width: pad),
                    Expanded(
                      child: _AvgCard(
                        label: 'ことし',
                        icon: Icons.auto_awesome_rounded,
                        avg: yearAvg,
                        tintColor: MonitorTheme.red,
                        tintBg: MonitorTheme.redBg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Today's hero card — uses LayoutBuilder to scale contents
// ═══════════════════════════════════════════════════════════
class _DisplayDayCard extends StatelessWidget {
  final double avg;
  final double change;
  final String dateLabel;
  const _DisplayDayCard({required this.avg, required this.change, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    final emoji = MonitorTheme.getScoreEmoji(avg);
    final scoreColor =
        avg > 0 ? MonitorTheme.getScoreColor(avg) : MonitorTheme.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: MonitorTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MonitorTheme.border),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          // Scale factor based on available height
          // ~300px = full size (1.0), ~150px = compact (0.55)
          final s = (box.maxHeight / 300).clamp(0.55, 1.0);
          final compact = s < 0.75;

          final emojiSize = (52 * s).clamp(22.0, 52.0);
          final scoreSize = (64 * s).clamp(28.0, 64.0);
          final subSize = (22 * s).clamp(12.0, 22.0);
          final gap = (14 * s).clamp(4.0, 14.0);
          final barH = (14 * s).clamp(6.0, 14.0);
          final padV = (16 * s).clamp(6.0, 16.0);
          final padH = (20 * s).clamp(8.0, 20.0);

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: padV, horizontal: padH),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge
                  if (!compact)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: MonitorTheme.blueBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'さいしんスコア  $dateLabel',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: MonitorTheme.blue,
                        ),
                      ),
                    ),
                  if (!compact) SizedBox(height: gap),
                  // Emoji
                  Text(emoji, style: TextStyle(fontSize: emojiSize)),
                  SizedBox(height: gap * 0.5),
                  // Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        avg > 0 ? avg.toStringAsFixed(1) : '---',
                        style: TextStyle(
                          fontSize: scoreSize,
                          fontWeight: FontWeight.w800,
                          color: scoreColor,
                          height: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: scoreSize * 0.1),
                        child: Text(
                          ' / 5',
                          style: TextStyle(
                            fontSize: subSize,
                            fontWeight: FontWeight.w500,
                            color: MonitorTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  // Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padH * 0.6),
                    child: _buildBar(avg, barH),
                  ),
                  // Change badge
                  if (avg > 0 && change.abs() > 0.001) ...[
                    SizedBox(height: gap * 0.7),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 12,
                        vertical: compact ? 3 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: MonitorTheme.getChangeColor(change)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(MonitorTheme.getChangeIcon(change),
                              size: compact ? 13 : 16,
                              color: MonitorTheme.getChangeColor(change)),
                          const SizedBox(width: 3),
                          Text(
                            compact
                                ? '${MonitorTheme.getChangePrefix(change)}${change.toStringAsFixed(1)}'
                                : 'ぜんかいから ${MonitorTheme.getChangePrefix(change)}${change.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: compact ? 11 : 13,
                              fontWeight: FontWeight.w700,
                              color: MonitorTheme.getChangeColor(change),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildBar(double score, double barH) {
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
            height: barH,
            decoration: BoxDecoration(
              color: filled
                  ? colors[i]
                  : partial
                      ? colors[i].withValues(alpha: 0.3)
                      : MonitorTheme.bgSurface,
              borderRadius: BorderRadius.circular(barH / 2),
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Month / Year average card — scales contents to fit
// ═══════════════════════════════════════════════════════════
class _AvgCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final double avg;
  final Color tintColor;
  final Color tintBg;
  const _AvgCard({
    required this.label,
    required this.icon,
    required this.avg,
    required this.tintColor,
    required this.tintBg,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor =
        avg > 0 ? MonitorTheme.getScoreColor(avg) : MonitorTheme.textMuted;
    final emoji = MonitorTheme.getScoreEmoji(avg);

    return Container(
      decoration: BoxDecoration(
        color: MonitorTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MonitorTheme.border),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final s = (box.maxHeight / 200).clamp(0.5, 1.0);
          final compact = s < 0.7;

          final emojiSize = (36 * s).clamp(18.0, 36.0);
          final scoreSize = (40 * s).clamp(22.0, 40.0);
          final labelSize = (13 * s).clamp(10.0, 13.0);
          final iconSize = (14 * s).clamp(10.0, 14.0);
          final gap = (10 * s).clamp(3.0, 10.0);
          final barH = (10 * s).clamp(5.0, 10.0);
          final padV = (14 * s).clamp(6.0, 14.0);
          final padH = (12 * s).clamp(6.0, 12.0);

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: padV, horizontal: padH),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(compact ? 3 : 5),
                        decoration: BoxDecoration(
                          color: tintBg,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(icon, size: iconSize, color: tintColor),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: labelSize,
                            fontWeight: FontWeight.w700,
                            color: tintColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  // Emoji
                  Text(emoji, style: TextStyle(fontSize: emojiSize)),
                  SizedBox(height: gap * 0.4),
                  // Score
                  Text(
                    avg > 0 ? avg.toStringAsFixed(1) : '---',
                    style: TextStyle(
                      fontSize: scoreSize,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  SizedBox(height: gap),
                  // Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padH * 0.5),
                    child: _buildBar(avg, barH),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildBar(double score, double barH) {
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
            height: barH,
            decoration: BoxDecoration(
              color: filled
                  ? colors[i]
                  : partial
                      ? colors[i].withValues(alpha: 0.3)
                      : MonitorTheme.bgSurface,
              borderRadius: BorderRadius.circular(barH / 2),
            ),
          ),
        );
      }),
    );
  }
}
