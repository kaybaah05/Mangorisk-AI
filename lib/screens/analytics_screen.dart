import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/shared.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: C.background,
      appBar: AppBar(title: const Text('Analytics')),
      body: provider.loading && provider.trades.isEmpty
          ? const LoadingOverlay()
          : provider.trades.isEmpty
              ? const EmptyState(
                  message: 'No trades yet.\nLog trades to see analytics.',
                  icon:    Icons.bar_chart_outlined,
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // ── Big discipline score ─────────────────────────────
                    _BigScoreCard(score: provider.avgDisciplineScore),
                    const SizedBox(height: 16),

                    // ── 4 stat cards ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        crossAxisCount:   2,
                        shrinkWrap:       true,
                        physics:          const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing:  10,
                        childAspectRatio: 1.6,
                        children: [
                          StatCard(
                            label: 'Win Rate',
                            value: '${provider.winRate.toStringAsFixed(0)}%',
                          ),
                          StatCard(
                            label: 'Avg R:R',
                            value: provider.avgRR.toStringAsFixed(2),
                          ),
                          StatCard(
                            label: 'Total P&L',
                            value: provider.totalPnL >= 0
                                ? '+${provider.totalPnL.toStringAsFixed(1)}'
                                : provider.totalPnL.toStringAsFixed(1),
                            valueColor: provider.totalPnL >= 0 ? C.win : C.loss,
                          ),
                          StatCard(
                            label: 'Total Trades',
                            value: '${provider.totalTrades}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Behavioral flags ─────────────────────────────────
                    const SectionHeader(title: 'BEHAVIORAL FLAGS'),
                    _BehavioralFlags(provider: provider),
                    const SizedBox(height: 20),

                    // ── Emotion vs Win Rate ──────────────────────────────
                    if (provider.emotionWinRateMap.isNotEmpty) ...[
                      const SectionHeader(title: 'EMOTION VS WIN RATE'),
                      _EmotionChart(emotionMap: provider.emotionWinRateMap),
                      const SizedBox(height: 20),
                    ],

                    // ── AI Insights ──────────────────────────────────────
                    const SectionHeader(title: 'AI INSIGHTS'),
                    _InsightCards(insights: provider.aiInsights),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }
}

// ── Big Score Card ────────────────────────────────────────────────────────────
class _BigScoreCard extends StatelessWidget {
  final double score;

  const _BigScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = Scorer.scoreColor(score);
    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          ScoreCircle(score: score, size: 72),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Avg Discipline Score',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: C.muted),
              ),
              Text(
                score.toStringAsFixed(0),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize:   40,
                  fontWeight: FontWeight.w800,
                  color:      color,
                ),
              ),
              Text(
                score >= 75
                    ? 'Excellent discipline'
                    : score >= 50
                        ? 'Room to improve'
                        : 'Needs attention',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Behavioral Flags ──────────────────────────────────────────────────────────
class _BehavioralFlags extends StatelessWidget {
  final AppProvider provider;

  const _BehavioralFlags({required this.provider});

  @override
  Widget build(BuildContext context) {
    final flags = [
      _FlagData(label: 'FOMO Trades',    count: provider.fomoCount,        icon: Icons.bolt_outlined),
      _FlagData(label: 'Revenge Trades', count: provider.revengeCount,     icon: Icons.local_fire_department_outlined),
      _FlagData(label: 'SL Moved',       count: provider.slMovedCount,     icon: Icons.trending_up_outlined),
      _FlagData(label: 'Rules Broken',   count: provider.rulesBrokenCount, icon: Icons.rule_outlined),
      _FlagData(label: 'Cooldown',       count: provider.cooldownCount,    icon: Icons.pause_circle_outline),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: flags.map((f) => _FlagTile(data: f)).toList(),
      ),
    );
  }
}

class _FlagData {
  final String   label;
  final int      count;
  final IconData icon;

  const _FlagData({required this.label, required this.count, required this.icon});
}

class _FlagTile extends StatelessWidget {
  final _FlagData data;

  const _FlagTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasFlags = data.count > 0;
    return Container(
      margin:  const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        C.background,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: C.border),
      ),
      child: Row(
        children: [
          Icon(data.icon, size: 20, color: hasFlags ? C.accent : C.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.label,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.primary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: hasFlags ? C.accent.withValues(alpha: 0.1) : C.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasFlags ? C.accent.withValues(alpha: 0.3) : C.border,
              ),
            ),
            child: Text(
              '${data.count}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize:   13,
                fontWeight: FontWeight.w700,
                color:      hasFlags ? C.accent : C.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Emotion vs Win Rate Chart (Option A — Card rows with progress bars) ───────
class _EmotionChart extends StatelessWidget {
  final Map<String, double> emotionMap;

  const _EmotionChart({required this.emotionMap});

  @override
  Widget build(BuildContext context) {
    final sorted = emotionMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: sorted.map((entry) {
          final pct   = entry.value / 100;
          final color = Scorer.scoreColor(entry.value);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border:       Border.all(color: C.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize:   13,
                        fontWeight: FontWeight.w500,
                        color:      C.primary,
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize:   13,
                        fontWeight: FontWeight.w500,
                        color:      color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value:           pct,
                    backgroundColor: C.border,
                    color:           color,
                    minHeight:       8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── AI Insight Cards ──────────────────────────────────────────────────────────
class _InsightCards extends StatelessWidget {
  final List<String> insights;

  const _InsightCards({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: insights.map((insight) {
          return Container(
            width:   double.infinity,
            margin:  const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        C.surface,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: C.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color:        C.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.lightbulb_outline, color: C.accent, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize:   13,
                      color:      C.secondary,
                      height:     1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
