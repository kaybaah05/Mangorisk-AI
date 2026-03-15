import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/theme.dart';

// ── Primary Button ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: C.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

// ── App Text Field ────────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscure;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.obscure = false,
    this.suffix,
    this.prefix,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   controller,
      obscureText:  obscure,
      keyboardType: keyboardType,
      validator:    validator,
      onChanged:    onChanged,
      maxLines:     maxLines,
      enabled:      enabled,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.primary),
      decoration: InputDecoration(
        hintText:   hint,
        labelText:  label,
        suffixIcon: suffix,
        prefixIcon: prefix,
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily:    'Inter',
              fontSize:      13,
              fontWeight:    FontWeight.w600,
              color:         C.muted,
              letterSpacing: 0.5,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Discipline Score Chip ─────────────────────────────────────────────────────
class DisciplineScoreChip extends StatelessWidget {
  final double score;

  const DisciplineScoreChip({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = Scorer.scoreColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border:       Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        score.toStringAsFixed(0),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize:   12,
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
    );
  }
}

// ── Summary Strip ─────────────────────────────────────────────────────────────
class SummaryStrip extends StatelessWidget {
  final double winRate;
  final double avgDiscipline;
  final double avgRR;
  final double totalPnL;

  const SummaryStrip({
    super.key,
    required this.winRate,
    required this.avgDiscipline,
    required this.avgRR,
    required this.totalPnL,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color:        C.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: C.border),
      ),
      child: Row(
        children: [
          _StatCell(label: 'Win Rate',   value: '${winRate.toStringAsFixed(0)}%'),
          _divider(),
          _StatCell(label: 'Discipline', value: avgDiscipline.toStringAsFixed(0)),
          _divider(),
          _StatCell(label: 'Avg R:R',    value: avgRR.toStringAsFixed(1)),
          _divider(),
          _StatCell(
            label: 'P&L',
            value: totalPnL >= 0
                ? '+${totalPnL.toStringAsFixed(1)}'
                : totalPnL.toStringAsFixed(1),
            valueColor: totalPnL >= 0 ? C.win : C.loss,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 32, color: C.border);
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize:   15,
              fontWeight: FontWeight.w700,
              color:      valueColor ?? C.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: C.muted),
          ),
        ],
      ),
    );
  }
}

// ── Filter Pills ──────────────────────────────────────────────────────────────
class FilterPills extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const FilterPills({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _filters = ['All', 'Wins', 'Losses', 'Flagged'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        padding:          const EdgeInsets.symmetric(horizontal: 16),
        itemCount:        _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter   = _filters[i];
          final isActive = selected == filter;
          return GestureDetector(
            onTap: () => onSelect(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? C.primary : C.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? C.primary : C.border),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize:   13,
                  fontWeight: FontWeight.w500,
                  color:      isActive ? C.white : C.secondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Trade Row Card ────────────────────────────────────────────────────────────
class TradeRowCard extends StatelessWidget {
  final Trade trade;
  final VoidCallback? onLongPress;

  const TradeRowCard({
    super.key,
    required this.trade,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final pnlColor = trade.pnl >= 0 ? C.win : C.loss;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        C.background,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: C.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        trade.instrument,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize:   14,
                          fontWeight: FontWeight.w600,
                          color:      C.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _directionBadge(trade.direction),
                    ],
                  ),
                ),
                _outcomeBadge(trade.outcome),
              ],
            ),
            const SizedBox(height: 8),
            // ── Bottom row ────────────────────────────────────────────────
            Row(
              children: [
                DisciplineScoreChip(score: trade.disciplineScore),
                const SizedBox(width: 8),
                Text(
                  trade.preEmotion,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: C.muted),
                ),
                const Spacer(),
                Text(
                  trade.pnl >= 0
                      ? '+${trade.pnl.toStringAsFixed(1)}'
                      : trade.pnl.toStringAsFixed(1),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color:      pnlColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  DateFormat('dd MMM').format(trade.createdAt),
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.muted),
                ),
              ],
            ),
            // ── Flags row ────────────────────────────────────────────────
            if (trade.flags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: trade.flags.map((f) => _flagChip(f)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _directionBadge(String direction) {
    final isLong = direction == 'Long';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:        isLong ? C.win.withValues(alpha: 0.1) : C.loss.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        direction,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize:   11,
          fontWeight: FontWeight.w600,
          color:      isLong ? C.win : C.loss,
        ),
      ),
    );
  }

  Widget _outcomeBadge(String outcome) {
    Color color;
    switch (outcome) {
      case 'Win':  color = C.win;  break;
      case 'Loss': color = C.loss; break;
      default:     color = C.muted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border:       Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        outcome,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize:   12,
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
    );
  }

  Widget _flagChip(String flag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:        C.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border:       Border.all(color: C.accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        flag,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize:   10,
          fontWeight: FontWeight.w600,
          color:      C.accent,
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        C.background,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.muted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize:   20,
              fontWeight: FontWeight.w700,
              color:      valueColor ?? C.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: C.border),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.muted),
          ),
        ],
      ),
    );
  }
}

// ── Loading Overlay ───────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: C.accent, strokeWidth: 2),
    );
  }
}

// ── Score Circle ──────────────────────────────────────────────────────────────
class ScoreCircle extends StatelessWidget {
  final double score;
  final double size;

  const ScoreCircle({
    super.key,
    required this.score,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final color = Scorer.scoreColor(score);
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        shape:  BoxShape.circle,
        color:  color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          score.toStringAsFixed(0),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize:   size * 0.28,
            fontWeight: FontWeight.w700,
            color:      color,
          ),
        ),
      ),
    );
  }
}