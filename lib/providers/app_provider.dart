import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/db.dart';

class AppProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  List<Trade>    _trades     = [];
  List<Strategy> _strategies = [];
  UserProfile?   _profile;
  bool           _loading    = false;
  String?        _error;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<Trade>    get trades     => _trades;
  List<Strategy> get strategies => _strategies;
  UserProfile?   get profile    => _profile;
  bool           get loading    => _loading;
  String?        get error      => _error;

  // ── Filtered Trades ────────────────────────────────────────────────────────
  List<Trade> filteredTrades(String filter) {
    switch (filter) {
      case 'Wins':
        return _trades.where((t) => t.outcome == 'Win').toList();
      case 'Losses':
        return _trades.where((t) => t.outcome == 'Loss').toList();
      case 'Flagged':
        return _trades.where((t) => t.isFlagged).toList();
      default:
        return _trades;
    }
  }

  // ── Summary Stats ──────────────────────────────────────────────────────────
  double get winRate {
    if (_trades.isEmpty) return 0;
    final wins = _trades.where((t) => t.outcome == 'Win').length;
    return (wins / _trades.length) * 100;
  }

  double get avgDisciplineScore {
    if (_trades.isEmpty) return 0;
    final total = _trades.fold(0.0, (sum, t) => sum + t.disciplineScore);
    return total / _trades.length;
  }

  double get avgRR {
    if (_trades.isEmpty) return 0;
    final total = _trades.fold(0.0, (sum, t) => sum + t.rr);
    return total / _trades.length;
  }

  double get totalPnL {
    return _trades.fold(0.0, (sum, t) => sum + t.pnl);
  }

  int get totalTrades => _trades.length;

  // ── Behavioral Flags ───────────────────────────────────────────────────────
  int get fomoCount =>
      _trades.where((t) => t.flags.contains('FOMO')).length;

  int get revengeCount =>
      _trades.where((t) => t.flags.contains('REVENGE')).length;

  int get slMovedCount =>
      _trades.where((t) => t.flags.contains('SL MOVED')).length;

  int get rulesBrokenCount =>
      _trades.where((t) => t.flags.contains('RULES BROKEN')).length;

  int get cooldownCount =>
      _trades.where((t) => t.flags.contains('COOLDOWN')).length;

  // ── Emotion vs Win Rate ────────────────────────────────────────────────────
  Map<String, double> get emotionWinRateMap {
    final Map<String, List<Trade>> grouped = {};

    for (final trade in _trades) {
      grouped.putIfAbsent(trade.preEmotion, () => []).add(trade);
    }

    final Map<String, double> result = {};
    grouped.forEach((emotion, trades) {
      final wins = trades.where((t) => t.outcome == 'Win').length;
      result[emotion] = trades.isEmpty ? 0 : (wins / trades.length) * 100;
    });

    return result;
  }

  // ── AI Insight Cards ───────────────────────────────────────────────────────
  List<String> get aiInsights {
    final List<String> insights = [];

    if (_trades.isEmpty) {
      insights.add('Log your first trade to start receiving insights.');
      return insights;
    }

    if (fomoCount >= 3) {
      insights.add(
          'You\'ve entered $fomoCount FOMO trades. Consider a pre-trade checklist to pause before entering.');
    }

    if (revengeCount >= 2) {
      insights.add(
          'Revenge trading detected $revengeCount times. After a loss, take a 15-minute break before the next trade.');
    }

    if (slMovedCount >= 2) {
      insights.add(
          'You\'ve moved your stop loss wider $slMovedCount times. Set your SL and walk away — protect your account.');
    }

    if (avgDisciplineScore < 50 && _trades.length >= 3) {
      insights.add(
          'Your average discipline score is ${avgDisciplineScore.toStringAsFixed(0)}. Focus on following your rules consistently.');
    }

    if (winRate < 40 && _trades.length >= 5) {
      insights.add(
          'Win rate is ${winRate.toStringAsFixed(0)}%. Review your strategy rules and consider paper trading until consistency improves.');
    }

    if (avgRR > 2 && winRate > 50) {
      insights.add(
          'Great R:R ratio of ${avgRR.toStringAsFixed(1)} with a ${winRate.toStringAsFixed(0)}% win rate. You\'re trading well — stay consistent.');
    }

    if (rulesBrokenCount >= 3) {
      insights.add(
          'Rules were broken in $rulesBrokenCount trades. Review your strategy and simplify your rules if needed.');
    }

    if (insights.isEmpty) {
      insights.add(
          'Keep logging trades consistently. Insights will appear as patterns emerge in your data.');
    }

    return insights;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD ALL DATA
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadAll() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        DB.fetchTrades(),
        DB.fetchStrategies(),
        DB.fetchProfile(),
      ]);
      _trades     = results[0] as List<Trade>;
      _strategies = results[1] as List<Strategy>;
      _profile    = results[2] as UserProfile?;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTrades() async {
    try {
      _trades = await DB.fetchTrades();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadStrategies() async {
    try {
      _strategies = await DB.fetchStrategies();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TRADES CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> addTrade(Map<String, dynamic> tradeJson) async {
    try {
      final trade = await DB.saveTrade(tradeJson);
      if (trade != null) {
        _trades.insert(0, trade);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTrade(String tradeId) async {
    try {
      await DB.deleteTrade(tradeId);
      _trades.removeWhere((t) => t.id == tradeId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STRATEGIES CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> addStrategy(Map<String, dynamic> json) async {
    try {
      final strategy = await DB.saveStrategy(json);
      if (strategy != null) {
        _strategies.insert(0, strategy);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStrategy({
    required String strategyId,
    required Map<String, dynamic> json,
  }) async {
    try {
      final updated = await DB.updateStrategy(
        strategyId: strategyId,
        json: json,
      );
      if (updated != null) {
        final index = _strategies.indexWhere((s) => s.id == strategyId);
        if (index != -1) {
          _strategies[index] = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteStrategy(String strategyId) async {
    try {
      await DB.deleteStrategy(strategyId);
      _strategies.removeWhere((s) => s.id == strategyId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> updateProfile({required String displayName}) async {
    try {
      await DB.updateProfile(displayName: displayName);
      if (_profile != null) {
        _profile = UserProfile(
          id:          _profile!.id,
          displayName: displayName,
          email:       _profile!.email,
          plan:        _profile!.plan,
          createdAt:   _profile!.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Strategy lookup by ID
  Strategy? strategyById(String? id) {
    if (id == null) return null;
    try {
      return _strategies.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}