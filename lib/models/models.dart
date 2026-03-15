import 'package:flutter/material.dart';

// ── Constants ────────────────────────────────────────────────────────────────
class K {
  static const List<String> instruments = [
    'EUR/USD', 'GBP/USD', 'USD/JPY', 'USD/CHF', 'AUD/USD',
    'NZD/USD', 'USD/CAD', 'GBP/JPY', 'EUR/JPY', 'EUR/GBP',
    'XAU/USD', 'XAG/USD', 'BTC/USD', 'ETH/USD', 'US30',
    'NAS100', 'SPX500', 'UK100', 'GER40', 'CRUDE OIL',
  ];

  static const List<String> timeframes = [
    'M1', 'M5', 'M15', 'M30', 'H1', 'H4', 'D1', 'W1',
  ];

  static const List<String> emotions = [
    'Calm', 'Confident', 'Anxious', 'FOMO', 'Revengeful',
    'Bored', 'Excited', 'Fearful',
  ];

  static const List<String> outcomes = ['Win', 'Loss', 'BE'];

  static const List<String> slMoveOptions = ['Held', 'Tighter', 'Wider'];

  static const List<String> directions = ['Long', 'Short'];
}

// ── Trade Model ───────────────────────────────────────────────────────────────
class Trade {
  final String id;
  final String userId;

  // Step 1 — Pre-trade
  final String instrument;
  final String direction;
  final String timeframe;
  final double entryPrice;
  final double slPrice;
  final double targetPrice;
  final String preEmotion;
  final String? strategyId;
  final String reason;

  // Step 2 — Execution
  final String outcome;
  final double actualEntry;
  final double actualExit;
  final String slMoved;

  // Step 3 — Review
  final List<String> rulesFollowed;
  final int executionRating;
  final String postEmotion;
  final String lesson;

  // Computed
  final double disciplineScore;
  final double pnl;
  final double rr;
  final bool isFlagged;
  final List<String> flags;

  final DateTime createdAt;

  const Trade({
    required this.id,
    required this.userId,
    required this.instrument,
    required this.direction,
    required this.timeframe,
    required this.entryPrice,
    required this.slPrice,
    required this.targetPrice,
    required this.preEmotion,
    this.strategyId,
    required this.reason,
    required this.outcome,
    required this.actualEntry,
    required this.actualExit,
    required this.slMoved,
    required this.rulesFollowed,
    required this.executionRating,
    required this.postEmotion,
    required this.lesson,
    required this.disciplineScore,
    required this.pnl,
    required this.rr,
    required this.isFlagged,
    required this.flags,
    required this.createdAt,
  });

  // ── From Supabase JSON ───────────────────────────────────────────────────
  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id:              json['id'] as String,
      userId:          json['user_id'] as String,
      instrument:      json['instrument'] as String,
      direction:       json['direction'] as String,
      timeframe:       json['timeframe'] as String,
      entryPrice:      (json['entry_price'] as num).toDouble(),
      slPrice:         (json['sl_price'] as num).toDouble(),
      targetPrice:     (json['target_price'] as num).toDouble(),
      preEmotion:      json['pre_emotion'] as String,
      strategyId:      json['strategy_id'] as String?,
      reason:          json['reason'] as String,
      outcome:         json['outcome'] as String,
      actualEntry:     (json['actual_entry'] as num).toDouble(),
      actualExit:      (json['actual_exit'] as num).toDouble(),
      slMoved:         json['sl_moved'] as String,
      rulesFollowed:   List<String>.from(json['rules_followed'] ?? []),
      executionRating: json['execution_rating'] as int,
      postEmotion:     json['post_emotion'] as String,
      lesson:          json['lesson'] as String,
      disciplineScore: (json['discipline_score'] as num).toDouble(),
      pnl:             (json['pnl'] as num).toDouble(),
      rr:              (json['rr'] as num).toDouble(),
      isFlagged:       json['is_flagged'] as bool,
      flags:           List<String>.from(json['flags'] ?? []),
      createdAt:       DateTime.parse(json['created_at'] as String),
    );
  }

  // ── To Supabase JSON ─────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'instrument':       instrument,
      'direction':        direction,
      'timeframe':        timeframe,
      'entry_price':      entryPrice,
      'sl_price':         slPrice,
      'target_price':     targetPrice,
      'pre_emotion':      preEmotion,
      'strategy_id':      strategyId,
      'reason':           reason,
      'outcome':          outcome,
      'actual_entry':     actualEntry,
      'actual_exit':      actualExit,
      'sl_moved':         slMoved,
      'rules_followed':   rulesFollowed,
      'execution_rating': executionRating,
      'post_emotion':     postEmotion,
      'lesson':           lesson,
      'discipline_score': disciplineScore,
      'pnl':              pnl,
      'rr':               rr,
      'is_flagged':       isFlagged,
      'flags':            flags,
    };
  }
}

// ── Strategy Model ────────────────────────────────────────────────────────────
class Strategy {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<String> instruments;
  final List<String> rules;
  final double score;
  final DateTime createdAt;

  const Strategy({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.instruments,
    required this.rules,
    required this.score,
    required this.createdAt,
  });

  factory Strategy.fromJson(Map<String, dynamic> json) {
    return Strategy(
      id:          json['id'] as String,
      userId:      json['user_id'] as String,
      name:        json['name'] as String,
      description: json['description'] as String,
      instruments: List<String>.from(json['instruments'] ?? []),
      rules:       List<String>.from(json['rules'] ?? []),
      score:       (json['score'] as num).toDouble(),
      createdAt:   DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name':        name,
      'description': description,
      'instruments': instruments,
      'rules':       rules,
      'score':       score,
    };
  }

  Strategy copyWith({
    String? name,
    String? description,
    List<String>? instruments,
    List<String>? rules,
    double? score,
  }) {
    return Strategy(
      id:          id,
      userId:      userId,
      name:        name ?? this.name,
      description: description ?? this.description,
      instruments: instruments ?? this.instruments,
      rules:       rules ?? this.rules,
      score:       score ?? this.score,
      createdAt:   createdAt,
    );
  }
}

// ── Profile Model ─────────────────────────────────────────────────────────────
class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String plan;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.plan,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id:          json['id'] as String,
      displayName: json['display_name'] as String,
      email:       json['email'] as String,
      plan:        json['plan'] as String,
      createdAt:   DateTime.parse(json['created_at'] as String),
    );
  }

  // Referral code = MANGO- + first 6 chars of user ID
  String get referralCode => 'MANGO-${id.substring(0, 6).toUpperCase()}';
}

// ── Discipline Scorer ─────────────────────────────────────────────────────────
class Scorer {
  /// Calculates discipline score 0-100 from trade inputs.
  /// Formula:
  ///   Rules followed  35%
  ///   SL discipline   30%
  ///   Emotion         20%
  ///   Execution rating 15%
  static double calculate({
    required List<String> rulesFollowed,
    required List<String> totalRules,
    required String slMoved,
    required String preEmotion,
    required int executionRating,
  }) {
    // Rules score
    double rulesScore = 0;
    if (totalRules.isNotEmpty) {
      rulesScore = (rulesFollowed.length / totalRules.length) * 100;
    } else {
      rulesScore = 100; // no rules = full marks
    }

    // SL discipline score
    double slScore;
    switch (slMoved) {
      case 'Held':
        slScore = 100;
        break;
      case 'Tighter':
        slScore = 55;
        break;
      case 'Wider':
      default:
        slScore = 0;
    }

    // Emotion score
    double emotionScore;
    switch (preEmotion) {
      case 'Calm':
        emotionScore = 100;
        break;
      case 'Confident':
        emotionScore = 90;
        break;
      case 'Excited':
        emotionScore = 70;
        break;
      case 'Anxious':
        emotionScore = 40;
        break;
      case 'Bored':
        emotionScore = 30;
        break;
      case 'Fearful':
        emotionScore = 20;
        break;
      case 'FOMO':
        emotionScore = 10;
        break;
      case 'Revengeful':
      default:
        emotionScore = 0;
    }

    // Execution rating score (1-5 star → 0-100)
    final double ratingScore = ((executionRating - 1) / 4) * 100;

    // Weighted total
    final double total = (rulesScore * 0.35) +
        (slScore * 0.30) +
        (emotionScore * 0.20) +
        (ratingScore * 0.15);

    return total.clamp(0, 100);
  }

  /// Returns colour based on score threshold
  static Color scoreColor(double score) {
    if (score >= 75) return const Color(0xFF16A34A); // green
    if (score >= 50) return const Color(0xFFF5A623); // amber
    return const Color(0xFFDC2626);                  // red
  }

  /// Auto-detects behavioral flags from a trade
  static List<String> detectFlags({
    required String preEmotion,
    required String slMoved,
    required List<String> rulesFollowed,
    required List<String> totalRules,
    required String outcome,
    required int executionRating,
  }) {
    final List<String> flags = [];

    if (preEmotion == 'Revengeful') flags.add('REVENGE');
    if (preEmotion == 'FOMO') flags.add('FOMO');
    if (slMoved == 'Wider') flags.add('SL MOVED');

    if (totalRules.isNotEmpty) {
      final double pct = rulesFollowed.length / totalRules.length;
      if (pct < 0.5) flags.add('RULES BROKEN');
    }

    if (outcome == 'Loss' && executionRating <= 2) {
      flags.add('COOLDOWN');
    }

    return flags;
  }

  /// Calculates R:R ratio
  static double calcRR(double entry, double sl, double target, String direction) {
    if (direction == 'Long') {
      final double risk   = entry - sl;
      final double reward = target - entry;
      if (risk <= 0) return 0;
      return reward / risk;
    } else {
      final double risk   = sl - entry;
      final double reward = entry - target;
      if (risk <= 0) return 0;
      return reward / risk;
    }
  }

  /// Calculates P&L
  static double calcPnL(double actualEntry, double actualExit, String direction) {
    if (direction == 'Long') {
      return actualExit - actualEntry;
    } else {
      return actualEntry - actualExit;
    }
  }
}