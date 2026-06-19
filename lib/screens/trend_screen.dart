import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitor_provider.dart';
import '../utils/monitor_theme.dart';
import 'dart:math' as math;

class TrendScreen extends StatefulWidget {
  const TrendScreen({super.key});

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  int _dailyRange = 14;
  int _monthlyRange = 6;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final dailyTrend = provider.getDailyTrend(_dailyRange);
    final monthlyTrend = provider.getMonthlyTrend(_monthlyRange);

    // Use LayoutBuilder instead of MediaQuery.orientation to avoid
    // rotation scroll bugs caused by rebuild timing issues.
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > constraints.maxHeight;
        final pad = isWide ? 16.0 : 12.0;

        if (isWide) {
          // Landscape / wide: two charts side by side
          return Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              children: [
                Expanded(
                  child: _buildDailyTrendCard(dailyTrend, expanded: true),
                ),
                SizedBox(width: pad),
                Expanded(
                  child: _buildMonthlyCard(monthlyTrend, expanded: true),
                ),
              ],
            ),
          );
        }

        // Portrait / narrow: two charts stacked
        return Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            children: [
              Expanded(
                child: _buildDailyTrendCard(dailyTrend, expanded: true),
              ),
              SizedBox(height: pad),
              Expanded(
                child: _buildMonthlyCard(monthlyTrend, expanded: true),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Daily trend card ──
  Widget _buildDailyTrendCard(Map<String, double> dailyTrend,
      {bool expanded = false}) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: MonitorTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MonitorTheme.border),
        boxShadow: [
          BoxShadow(
            color: MonitorTheme.blue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MonitorTheme.blueBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.show_chart_rounded,
                    size: 16, color: MonitorTheme.blue),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'にちべつ すいい',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: MonitorTheme.textPrimary,
                  ),
                ),
              ),
              _buildRangeSelector(
                values: [7, 14, 30],
                selected: _dailyRange,
                onChanged: (v) => setState(() => _dailyRange = v),
                labels: ['7にち', '14にち', '30にち'],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Chart fills remaining space
          Expanded(
            child: dailyTrend.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\u{1F4CA}',
                            style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text('データがまだないよ',
                            style: TextStyle(
                              color: MonitorTheme.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  )
                : _LineChart(data: dailyTrend),
          ),
        ],
      ),
    );
    return content;
  }

  // ── Monthly average card ──
  Widget _buildMonthlyCard(List<MonthlyAverage> monthlyTrend,
      {bool expanded = false}) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: MonitorTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MonitorTheme.border),
        boxShadow: [
          BoxShadow(
            color: MonitorTheme.yellow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MonitorTheme.yellowBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 16, color: MonitorTheme.yellow),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'つきべつ へいきん',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: MonitorTheme.textPrimary,
                  ),
                ),
              ),
              _buildRangeSelector(
                values: [6, 12],
                selected: _monthlyRange,
                onChanged: (v) => setState(() => _monthlyRange = v),
                labels: ['6か月', '12か月'],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Chart fills remaining space
          Expanded(
            child: monthlyTrend.every((m) => m.logCount == 0)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\u{1F4CA}',
                            style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text('データがまだないよ',
                            style: TextStyle(
                              color: MonitorTheme.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  )
                : _BarChart(data: monthlyTrend),
          ),
        ],
      ),
    );
    return content;
  }

  // ── Range selector (kid-friendly pill buttons) ──
  Widget _buildRangeSelector({
    required List<int> values,
    required int selected,
    required ValueChanged<int> onChanged,
    List<String>? labels,
  }) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: MonitorTheme.bgSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(values.length, (i) {
          final isActive = values[i] == selected;
          final label = labels != null ? labels[i] : '${values[i]}';
          return GestureDetector(
            onTap: () => onChanged(values[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? MonitorTheme.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: MonitorTheme.blue.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : MonitorTheme.textMuted,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============ Line Chart (CustomPaint) ============

class _LineChart extends StatelessWidget {
  final Map<String, double> data;
  const _LineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LineChartPainter(data: data),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final Map<String, double> data;
  _LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 28.0;
    const bottomPad = 28.0;
    const topPad = 8.0;
    const rightPad = 8.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;
    if (chartW <= 0 || chartH <= 0) return;

    // Grid
    final gridPaint = Paint()
      ..color = MonitorTheme.border
      ..strokeWidth = 0.8;

    for (var i = 0; i <= 5; i++) {
      final y = topPad + chartH - (chartH * i / 5);
      _drawDashedLine(canvas, Offset(leftPad, y),
          Offset(size.width - rightPad, y), gridPaint, 4, 4);

      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: MonitorTheme.textMuted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    if (data.isEmpty) return;
    final entries = data.entries.toList();
    final n = entries.length;
    if (n < 2) {
      final x = leftPad + chartW / 2;
      final y = topPad + chartH - (entries.first.value / 5.0 * chartH);
      final color = MonitorTheme.getScoreColor(entries.first.value);
      canvas.drawCircle(
          Offset(x, y), 10, Paint()..color = color.withValues(alpha: 0.15));
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = MonitorTheme.white);
      return;
    }

    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    for (var i = 0; i < n; i++) {
      final x = leftPad + (i / (n - 1)) * chartW;
      final y = topPad + chartH - (entries[i].value / 5.0 * chartH);
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, topPad + chartH);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(points.last.dx, topPad + chartH);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          MonitorTheme.blue.withValues(alpha: 0.18),
          MonitorTheme.blue.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(leftPad, topPad, chartW, chartH));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = MonitorTheme.blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < points.length; i++) {
      final dotColor = MonitorTheme.getScoreColor(entries[i].value);
      canvas.drawCircle(
          points[i], 6, Paint()..color = dotColor.withValues(alpha: 0.15));
      canvas.drawCircle(points[i], 4, Paint()..color = dotColor);
      canvas.drawCircle(points[i], 2.5, Paint()..color = MonitorTheme.white);
    }

    final labelIndices = <int>{0, n ~/ 2, n - 1};
    for (final idx in labelIndices) {
      final dateStr = entries[idx].key;
      final shortDate = dateStr.length >= 10
          ? '${dateStr.substring(5, 7)}/${dateStr.substring(8, 10)}'
          : dateStr;
      final tp = TextPainter(
        text: TextSpan(
          text: shortDate,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: MonitorTheme.textMuted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(points[idx].dx - tp.width / 2, topPad + chartH + 8),
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint,
      double dashWidth, double dashSpace) {
    final totalLength = (to - from).distance;
    if (totalLength <= 0) return;
    final direction = (to - from) / totalLength;
    var drawn = 0.0;
    while (drawn < totalLength) {
      final start = from + direction * drawn;
      drawn += dashWidth;
      final end = from + direction * math.min(drawn, totalLength);
      canvas.drawLine(start, end, paint);
      drawn += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) => old.data != data;
}

// ============ Bar Chart (CustomPaint) ============

class _BarChart extends StatelessWidget {
  final List<MonthlyAverage> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _BarChartPainter(data: data),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<MonthlyAverage> data;
  _BarChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 28.0;
    const bottomPad = 28.0;
    const topPad = 14.0;
    const rightPad = 8.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - bottomPad - topPad;
    if (chartW <= 0 || chartH <= 0) return;

    final gridPaint = Paint()
      ..color = MonitorTheme.border
      ..strokeWidth = 0.8;

    for (var i = 0; i <= 5; i++) {
      final y = topPad + chartH - (chartH * i / 5);
      _drawDashedLine(canvas, Offset(leftPad, y),
          Offset(size.width - rightPad, y), gridPaint, 4, 4);

      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: MonitorTheme.textMuted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    final n = data.length;
    if (n == 0) return;

    final barGroupW = chartW / n;
    final barW = math.min(barGroupW * 0.55, 32.0);
    final barRadius = barW / 4;

    for (var i = 0; i < n; i++) {
      final item = data[i];
      final x = leftPad + i * barGroupW + (barGroupW - barW) / 2;
      final barH = (item.average / 5.0) * chartH;
      final barTop = topPad + chartH - barH;

      if (item.logCount > 0) {
        final color = MonitorTheme.getScoreColor(item.average);
        final barRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x, barTop, barW, barH),
          topLeft: Radius.circular(barRadius),
          topRight: Radius.circular(barRadius),
          bottomLeft: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        );

        final barPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withValues(alpha: 0.7)],
          ).createShader(Rect.fromLTWH(x, barTop, barW, barH));
        canvas.drawRRect(barRect, barPaint);

        final scoreTp = TextPainter(
          text: TextSpan(
            text: item.average.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        scoreTp.paint(
            canvas, Offset(x + barW / 2 - scoreTp.width / 2, barTop - 14));
      } else {
        final noData = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + barW * 0.3, topPad + chartH - 3, barW * 0.4, 3),
          const Radius.circular(2),
        );
        canvas.drawRRect(noData, Paint()..color = MonitorTheme.bgSurface);
      }

      final labelTp = TextPainter(
        text: TextSpan(
          text: item.label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: MonitorTheme.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(
        canvas,
        Offset(x + barW / 2 - labelTp.width / 2, topPad + chartH + 6),
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint,
      double dashWidth, double dashSpace) {
    final totalLength = (to - from).distance;
    if (totalLength <= 0) return;
    final direction = (to - from) / totalLength;
    var drawn = 0.0;
    while (drawn < totalLength) {
      final start = from + direction * drawn;
      drawn += dashWidth;
      final end = from + direction * math.min(drawn, totalLength);
      canvas.drawLine(start, end, paint);
      drawn += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => old.data != data;
}
