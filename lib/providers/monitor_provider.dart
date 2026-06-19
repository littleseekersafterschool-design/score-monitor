import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import '../models/facility.dart';
import '../models/staff.dart';
import '../models/goal.dart';
import '../models/daily_log.dart';

/// MonthlyAverage data class for chart display
class MonthlyAverage {
  final int year;
  final int month;
  final double average;
  final int logCount;

  MonthlyAverage({
    required this.year,
    required this.month,
    required this.average,
    required this.logCount,
  });

  String get label => '$month月';
}

class MonitorProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connection state
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  String? _connectionError;
  String? get connectionError => _connectionError;

  // Facility info
  Facility? _currentFacility;
  Facility? get currentFacility => _currentFacility;

  bool _isInitialized = true;
  bool get isInitialized => _isInitialized;

  // Cached data from Firestore
  List<Staff> _staff = [];
  List<Goal> _goals = [];
  List<DailyLog> _allLogs = [];
  List<DailyLog> _todayLogs = [];
  List<DailyLog> _yesterdayLogs = [];

  // "Display day" = previous business day (what the monitor shows)
  List<DailyLog> _displayDayLogs = [];
  List<DailyLog> _comparisonDayLogs = [];
  String _displayDateLabel = '';

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Firestore real-time listeners
  StreamSubscription? _staffListener;
  StreamSubscription? _goalsListener;
  StreamSubscription? _logsListener;

  // Refresh tracking
  DateTime _lastRefresh = DateTime.now();
  DateTime get lastRefresh => _lastRefresh;

  int _refreshInterval = 0; // 0 = real-time (Firestore listeners)
  int get refreshInterval => _refreshInterval;

  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  // ============ Password verification ============

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ============ Connection ============

  /// Connect to a facility via Firestore
  Future<bool> connect(String facilityId, String password) async {
    _isConnecting = true;
    _connectionError = null;
    notifyListeners();

    try {
      // Find facility by facilityId field
      final snap = await _firestore
          .collection('facilities')
          .where('facility_id', isEqualTo: facilityId)
          .get();

      if (snap.docs.isEmpty) {
        _connectionError = '施設が見つかりません。施設IDを確認してください。';
        _isConnecting = false;
        notifyListeners();
        return false;
      }

      final facilityData = snap.docs.first.data();
      final facility = Facility.fromMap(facilityData);

      // Verify password
      final passwordHash = _hashPassword(password);
      if (facility.sharedPasswordHash != passwordHash) {
        _connectionError = 'パスワードが正しくありません。';
        _isConnecting = false;
        notifyListeners();
        return false;
      }

      _currentFacility = facility;
      _isConnected = true;
      _isConnecting = false;

      // Start real-time listeners
      _startListeners(facilityId);
      notifyListeners();
      return true;
    } catch (e) {
      _connectionError = '接続エラー: $e';
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  void disconnect() {
    _stopListeners();
    _isConnected = false;
    _currentFacility = null;
    _staff = [];
    _goals = [];
    _allLogs = [];
    _todayLogs = [];
    _yesterdayLogs = [];
    _connectionError = null;
    notifyListeners();
  }

  // ============ Firestore Real-time Listeners ============

  void _startListeners(String facilityId) {
    _stopListeners();

    // Staff listener
    _staffListener = _firestore
        .collection('staff')
        .where('facility_id', isEqualTo: facilityId)
        .snapshots()
        .listen((snap) {
      _staff = snap.docs
          .map((d) => Staff.fromMap(d.data()))
          .where((s) => s.isActive)
          .toList();
      _lastRefresh = DateTime.now();
      notifyListeners();
    });

    // Goals listener
    _goalsListener = _firestore
        .collection('goals')
        .where('facility_id', isEqualTo: facilityId)
        .snapshots()
        .listen((snap) {
      _goals = snap.docs
          .map((d) => Goal.fromMap(d.data()))
          .where((g) => g.isActive)
          .toList();
      _goals.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      _lastRefresh = DateTime.now();
      notifyListeners();
    });

    // Daily logs listener (all logs for this facility)
    _logsListener = _firestore
        .collection('daily_logs')
        .where('facility_id', isEqualTo: facilityId)
        .snapshots()
        .listen((snap) {
      _allLogs = snap.docs.map((d) => DailyLog.fromMap(d.data())).toList();
      _recalculateDailyLogs();
      _lastRefresh = DateTime.now();
      notifyListeners();
    });
  }

  void _stopListeners() {
    _staffListener?.cancel();
    _goalsListener?.cancel();
    _logsListener?.cancel();
    _staffListener = null;
    _goalsListener = null;
    _logsListener = null;
  }

  /// Find the previous business day (skip weekends: Sat/Sun).
  /// Mon -> Fri, Tue-Fri -> previous day, Sat -> Fri, Sun -> Fri.
  static DateTime _previousBusinessDay(DateTime from) {
    var d = from.subtract(const Duration(days: 1));
    // Skip backwards over weekend days
    while (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }

  static String _dateToStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _recalculateDailyLogs() {
    final now = DateTime.now();
    final todayStr = _dateToStr(now);
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = _dateToStr(yesterday);

    _todayLogs = _allLogs.where((l) => l.logDate == todayStr).toList();
    _yesterdayLogs = _allLogs.where((l) => l.logDate == yesterdayStr).toList();

    // Display day = previous business day (confirmed scores)
    final displayDay = _previousBusinessDay(now);
    final displayDayStr = _dateToStr(displayDay);
    _displayDayLogs =
        _allLogs.where((l) => l.logDate == displayDayStr).toList();

    // Comparison day = the business day before display day
    final compDay = _previousBusinessDay(displayDay);
    final compDayStr = _dateToStr(compDay);
    _comparisonDayLogs =
        _allLogs.where((l) => l.logDate == compDayStr).toList();

    // Label: "6/20 (金)" format
    const weekDayNames = ['', '月', '火', '水', '木', '金', '土', '日'];
    _displayDateLabel =
        '${displayDay.month}/${displayDay.day} (${weekDayNames[displayDay.weekday]})';
  }

  // Manual refresh (re-triggers listeners effectively)
  Future<void> refreshData() async {
    if (!_isConnected || _currentFacility == null) return;
    _recalculateDailyLogs();
    _lastRefresh = DateTime.now();
    notifyListeners();
  }

  void setRefreshInterval(int seconds) {
    _refreshInterval = seconds;
    notifyListeners();
  }

  // ============ READ-ONLY Data Access ============

  List<Staff> get staff => _staff;
  List<Goal> get goals => _goals;

  String get facilityId => _currentFacility?.facilityId ?? '';

  // Today's data
  List<DailyLog> get todayLogs => _todayLogs;

  // Yesterday's data (for comparison)
  List<DailyLog> get yesterdayLogs => _yesterdayLogs;

  double get todayAverage => _getAverageScore(_todayLogs);
  double get yesterdayAverage => _getAverageScore(_yesterdayLogs);

  // --- Monitor display getters (previous business day) ---
  /// The confirmed score to show on the monitor (previous business day)
  double get displayDayAverage => _getAverageScore(_displayDayLogs);

  /// Change compared to the business day before the display day
  double get displayDayChange =>
      displayDayAverage - _getAverageScore(_comparisonDayLogs);

  /// Goal averages for the display day
  Map<String, double> get displayDayGoalAverages =>
      _getAverageByGoal(_displayDayLogs);

  /// Goal averages for the comparison day (for change indicators)
  Map<String, double> get comparisonDayGoalAverages =>
      _getAverageByGoal(_comparisonDayLogs);

  /// Human-readable label for the display day (e.g. "6/20 (金)")
  String get displayDateLabel => _displayDateLabel;

  // Legacy getters kept for trend screen compatibility
  double get dailyChange => todayAverage - yesterdayAverage;
  Map<String, double> get todayGoalAverages => _getAverageByGoal(_todayLogs);
  Map<String, double> get yesterdayGoalAverages =>
      _getAverageByGoal(_yesterdayLogs);

  Map<String, double> get todayStaffAverages =>
      _getAverageByStaff(_todayLogs);

  // Chart data
  Map<String, double> getDailyTrend(int days) {
    final now = DateTime.now();
    final result = <String, double>{};

    for (var i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final logs = _allLogs.where((l) => l.logDate == dateStr).toList();
      if (logs.isNotEmpty) {
        result[dateStr] = _getAverageScore(logs);
      }
    }
    return result;
  }

  List<MonthlyAverage> getMonthlyTrend(int months) {
    final now = DateTime.now();
    final result = <MonthlyAverage>[];

    for (var i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final prefix =
          '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final logs =
          _allLogs.where((l) => l.logDate.startsWith(prefix)).toList();
      final avg = logs.isEmpty ? 0.0 : _getAverageScore(logs);
      result.add(MonthlyAverage(
        year: date.year,
        month: date.month,
        average: avg,
        logCount: logs.length,
      ));
    }
    return result;
  }

  // All-time facility data
  List<DailyLog> get allLogs => _allLogs;

  double get overallAverage => _getAverageScore(_allLogs);

  // This month data
  List<DailyLog> get thisMonthLogs {
    final now = DateTime.now();
    final prefix =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _allLogs.where((l) => l.logDate.startsWith(prefix)).toList();
  }

  double get thisMonthAverage => _getAverageScore(thisMonthLogs);

  // This year data
  List<DailyLog> get thisYearLogs {
    final now = DateTime.now();
    final prefix = '${now.year}-';
    return _allLogs.where((l) => l.logDate.startsWith(prefix)).toList();
  }

  double get thisYearAverage => _getAverageScore(thisYearLogs);

  String getStaffName(String staffId) {
    final s = _staff.where((s) => s.staffId == staffId);
    return s.isNotEmpty ? s.first.staffName : '---';
  }

  String getGoalTitle(String goalId) {
    final g = _goals.where((g) => g.goalId == goalId);
    return g.isNotEmpty ? g.first.title : '---';
  }

  Goal? getGoal(String goalId) {
    final matches = _goals.where((g) => g.goalId == goalId);
    return matches.isNotEmpty ? matches.first : null;
  }

  // ============ Local Aggregation Helpers ============

  double _getAverageScore(List<DailyLog> logs) {
    if (logs.isEmpty) return 0;
    final total = logs.fold<int>(0, (acc, log) => acc + log.score);
    return total / logs.length;
  }

  Map<String, double> _getAverageByGoal(List<DailyLog> logs) {
    final grouped = <String, List<int>>{};
    for (final log in logs) {
      grouped.putIfAbsent(log.goalId, () => []).add(log.score);
    }
    return grouped.map(
      (k, v) => MapEntry(k, v.fold<int>(0, (s, e) => s + e) / v.length),
    );
  }

  Map<String, double> _getAverageByStaff(List<DailyLog> logs) {
    final grouped = <String, List<int>>{};
    for (final log in logs) {
      grouped.putIfAbsent(log.staffId, () => []).add(log.score);
    }
    return grouped.map(
      (k, v) => MapEntry(k, v.fold<int>(0, (s, e) => s + e) / v.length),
    );
  }

  @override
  void dispose() {
    _stopListeners();
    super.dispose();
  }
}
