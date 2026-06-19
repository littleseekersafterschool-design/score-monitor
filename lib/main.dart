import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/monitor_provider.dart';
import 'utils/monitor_theme.dart';
import 'screens/connect_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ScoreMonitorApp());
}

class ScoreMonitorApp extends StatelessWidget {
  const ScoreMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MonitorProvider()..initialize(),
      child: MaterialApp(
        title: 'Score Monitor',
        debugShowCheckedModeBanner: false,
        theme: MonitorTheme.theme,
        home: const _InitGate(),
      ),
    );
  }
}

class _InitGate extends StatelessWidget {
  const _InitGate();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();

    if (!provider.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: MonitorTheme.accent),
              SizedBox(height: 16),
              Text(
                'SCORE MONITOR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: MonitorTheme.textPrimary,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Initializing...',
                style: TextStyle(
                  fontSize: 12,
                  color: MonitorTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const ConnectScreen();
  }
}
