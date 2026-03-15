import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class DB {
  static final _client = Supabase.instance.client;

  // ── Auth helpers ──────────────────────────────────────────────────────────
  static String get _uid => _client.auth.currentUser!.id;

  // ════════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ════════════════════════════════════════════════════════════════════════════

  static Future<UserProfile?> fetchProfile() async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', _uid)
          .single();
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateProfile({required String displayName}) async {
    try {
      await _client
          .from('profiles')
          .update({'display_name': displayName})
          .eq('id', _uid);
    } catch (e) {
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TRADES
  // ════════════════════════════════════════════════════════════════════════════

  static Future<List<Trade>> fetchTrades() async {
    try {
      final data = await _client
          .from('trades')
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false);
      return (data as List).map((e) => Trade.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Trade?> saveTrade(Map<String, dynamic> tradeJson) async {
    try {
      final data = await _client
          .from('trades')
          .insert({...tradeJson, 'user_id': _uid})
          .select()
          .single();
      return Trade.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteTrade(String tradeId) async {
    try {
      await _client
          .from('trades')
          .delete()
          .eq('id', tradeId)
          .eq('user_id', _uid);
    } catch (e) {
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STRATEGIES
  // ════════════════════════════════════════════════════════════════════════════

  static Future<List<Strategy>> fetchStrategies() async {
    try {
      final data = await _client
          .from('strategies')
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false);
      return (data as List).map((e) => Strategy.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Strategy?> saveStrategy(Map<String, dynamic> json) async {
    try {
      final data = await _client
          .from('strategies')
          .insert({...json, 'user_id': _uid})
          .select()
          .single();
      return Strategy.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Strategy?> updateStrategy({
    required String strategyId,
    required Map<String, dynamic> json,
  }) async {
    try {
      final data = await _client
          .from('strategies')
          .update(json)
          .eq('id', strategyId)
          .eq('user_id', _uid)
          .select()
          .single();
      return Strategy.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteStrategy(String strategyId) async {
    try {
      await _client
          .from('strategies')
          .delete()
          .eq('id', strategyId)
          .eq('user_id', _uid);
    } catch (e) {
      rethrow;
    }
  }
}