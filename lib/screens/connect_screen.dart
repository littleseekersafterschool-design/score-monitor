import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitor_provider.dart';
import '../utils/monitor_theme.dart';
import 'monitor_shell.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _facilityIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isConnecting = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _facilityIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final facilityId = _facilityIdController.text.trim();
    final password = _passwordController.text;

    if (facilityId.isEmpty) {
      setState(() => _error = 'しせつIDをいれてね');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'パスワードをいれてね');
      return;
    }

    setState(() {
      _isConnecting = true;
      _error = null;
    });

    if (!mounted) return;
    final provider = context.read<MonitorProvider>();
    final ok = await provider.connect(facilityId, password);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MonitorShell()),
      );
    } else {
      setState(() {
        _isConnecting = false;
        _error = provider.connectionError ?? 'せつぞくできませんでした';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: MonitorTheme.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 80 : 32,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo ──
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: MonitorTheme.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: MonitorTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: MonitorTheme.blue.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.monitor_rounded,
                        size: 44,
                        color: MonitorTheme.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Title ──
                  const Text(
                    'SCORE MONITOR',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: MonitorTheme.textPrimary,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'よかレッジ！コミュニティスコア',
                    style: TextStyle(
                      fontSize: 13,
                      color: MonitorTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Cloud badge ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: MonitorTheme.blueBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_rounded,
                            size: 14, color: MonitorTheme.blue),
                        SizedBox(width: 6),
                        Text(
                          'CLOUD SYNC',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: MonitorTheme.blue,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Steps info card ──
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: MonitorTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: MonitorTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: MonitorTheme.blueBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.info_outline_rounded,
                                  size: 16, color: MonitorTheme.blue),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'つなぎかた',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: MonitorTheme.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStep(
                            '1', 'メインアプリの せってい から しせつID をかくにん'),
                        _buildStep('2', 'しせつID と パスワード をしたにいれる'),
                        _buildStep(
                            '3', 'クラウドで じどうてきに リアルタイムどうき'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Facility ID field ──
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'しせつID',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MonitorTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _facilityIdController,
                    style: const TextStyle(
                      color: MonitorTheme.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'メインアプリの しせつID',
                      prefixIcon: Icon(Icons.business_rounded,
                          color: MonitorTheme.textMuted),
                    ),
                    onSubmitted: (_) => _connect(),
                  ),
                  const SizedBox(height: 16),

                  // ── Password field ──
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'パスワード',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MonitorTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    style: const TextStyle(
                      color: MonitorTheme.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'パスワードをいれてね',
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: MonitorTheme.textMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: MonitorTheme.textMuted,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onSubmitted: (_) => _connect(),
                  ),
                  const SizedBox(height: 16),

                  // ── Error message ──
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: MonitorTheme.redBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 20, color: MonitorTheme.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: MonitorTheme.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Connect button ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isConnecting ? null : _connect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MonitorTheme.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            MonitorTheme.blue.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isConnecting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_sync_rounded, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'モニターにつなぐ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MonitorTheme.blueBg,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: MonitorTheme.blue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: MonitorTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
