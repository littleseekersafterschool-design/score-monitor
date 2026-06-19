import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitor_provider.dart';
import '../utils/monitor_theme.dart';
import 'averages_screen.dart';
import 'scores_screen.dart';
import 'trend_screen.dart';
import 'connect_screen.dart';

class MonitorShell extends StatefulWidget {
  const MonitorShell({super.key});

  @override
  State<MonitorShell> createState() => _MonitorShellState();
}

class _MonitorShellState extends State<MonitorShell> {
  int _currentIndex = 0;

  final _screens = const [
    AveragesScreen(),
    ScoresScreen(),
    TrendScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final facility = provider.currentFacility;

    if (facility == null) {
      return const ConnectScreen();
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: MonitorTheme.blueBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.monitor_rounded,
                  color: MonitorTheme.blue,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    facility.facilityName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MonitorTheme.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MonitorTheme.blue,
                          boxShadow: [
                            BoxShadow(
                              color: MonitorTheme.blue.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: MonitorTheme.blue,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            color: MonitorTheme.textMuted,
            onPressed: () => _confirmDisconnect(context, provider),
            tooltip: '接続解除',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: MonitorTheme.white,
          border: Border(
            top: BorderSide(color: MonitorTheme.border, width: 1),
          ),
        ),
        child: NavigationBar(
          height: 68,
          backgroundColor: MonitorTheme.white,
          indicatorColor: MonitorTheme.blueBg,
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined,
                  color: MonitorTheme.textMuted),
              selectedIcon:
                  Icon(Icons.analytics_rounded, color: MonitorTheme.blue),
              label: 'へいきん',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_outline_rounded,
                  color: MonitorTheme.textMuted),
              selectedIcon:
                  Icon(Icons.star_rounded, color: MonitorTheme.blue),
              label: '各スコア',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart_outlined,
                  color: MonitorTheme.textMuted),
              selectedIcon:
                  Icon(Icons.show_chart_rounded, color: MonitorTheme.blue),
              label: 'すいい',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDisconnect(BuildContext context, MonitorProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('接続解除',
            style: TextStyle(
                color: MonitorTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('モニターの接続を解除しますか？',
            style: TextStyle(color: MonitorTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('もどる',
                style: TextStyle(color: MonitorTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.disconnect();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const ConnectScreen()),
                (route) => false,
              );
            },
            child: const Text('かいじょする',
                style: TextStyle(
                    color: MonitorTheme.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
