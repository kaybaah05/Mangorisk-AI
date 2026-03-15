import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/shared.dart';
import '../utils/errors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// STRATEGY LIST SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class StrategyScreen extends StatelessWidget {
  const StrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strategies = context.watch<AppProvider>().strategies;

    return Scaffold(
      backgroundColor: C.background,
      appBar: AppBar(
        title: const Text('Strategy Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 26),
            onPressed: () => _openCreateEdit(context, null),
            tooltip: 'New Strategy',
          ),
        ],
      ),
      body: strategies.isEmpty
          ? const EmptyState(
              message: 'No strategies yet.\nTap + to create your first.',
              icon: Icons.shield_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: strategies.length,
              itemBuilder: (context, index) {
                final strategy = strategies[index];
                return _StrategyListTile(strategy: strategy);
              },
            ),
    );
  }

  void _openCreateEdit(BuildContext context, Strategy? strategy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StrategyEditScreen(strategy: strategy),
      ),
    );
  }
}

// ── Strategy List Tile ────────────────────────────────────────────────────────
class _StrategyListTile extends StatelessWidget {
  final Strategy strategy;

  const _StrategyListTile({required this.strategy});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StrategyDetailScreen(strategy: strategy),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.border),
        ),
        child: Row(
          children: [
            ScoreCircle(score: strategy.score, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strategy.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: C.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${strategy.rules.length} rule${strategy.rules.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: C.muted,
                    ),
                  ),
                  if (strategy.instruments.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: strategy.instruments.take(3).map((inst) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.border),
                          ),
                          child: Text(
                            inst,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: C.secondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: C.muted),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STRATEGY DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class StrategyDetailScreen extends StatelessWidget {
  final Strategy strategy;

  const StrategyDetailScreen({super.key, required this.strategy});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final linkedTrades =
        provider.trades.where((t) => t.strategyId == strategy.id).toList();

    return Scaffold(
      backgroundColor: C.background,
      appBar: AppBar(
        title: Text(strategy.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StrategyEditScreen(strategy: strategy),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: C.loss),
            onPressed: () => _confirmDelete(context, provider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Score card ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.border),
            ),
            child: Row(
              children: [
                ScoreCircle(score: strategy.score, size: 64),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Strategy Score',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: C.muted,
                      ),
                    ),
                    Text(
                      strategy.score.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Scorer.scoreColor(strategy.score),
                      ),
                    ),
                    Text(
                      '${linkedTrades.length} linked trade${linkedTrades.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: C.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Description ──────────────────────────────────────────────────
          if (strategy.description.isNotEmpty) ...[
            const SectionHeader(title: 'DESCRIPTION'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                strategy.description,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: C.secondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Rules ────────────────────────────────────────────────────────
          if (strategy.rules.isNotEmpty) ...[
            const SectionHeader(title: 'RULES'),
            ...strategy.rules.asMap().entries.map((entry) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: C.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: C.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: C.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: C.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // ── Adherence bars ────────────────────────────────────────────────
          if (strategy.rules.isNotEmpty && linkedTrades.isNotEmpty) ...[
            const SectionHeader(title: 'RULE ADHERENCE'),
            ...strategy.rules.map((rule) {
              final followed = linkedTrades
                  .where((t) => t.rulesFollowed.contains(rule))
                  .length;
              final pct =
                  linkedTrades.isEmpty ? 0.0 : followed / linkedTrades.length;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            rule,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: C.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(pct * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: C.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: C.border,
                        color: Scorer.scoreColor(pct * 100),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // ── Linked trades ─────────────────────────────────────────────────
          if (linkedTrades.isNotEmpty) ...[
            const SectionHeader(title: 'LINKED TRADES'),
            ...linkedTrades.map((trade) => TradeRowCard(trade: trade)),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete Strategy',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure? This cannot be undone.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await provider.deleteStrategy(strategy.id);
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'Inter', color: C.loss),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STRATEGY CREATE / EDIT SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class StrategyEditScreen extends StatefulWidget {
  final Strategy? strategy;

  const StrategyEditScreen({super.key, this.strategy});

  @override
  State<StrategyEditScreen> createState() => _StrategyEditScreenState();
}

class _StrategyEditScreenState extends State<StrategyEditScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  List<String> _selectedInstruments = [];
  List<TextEditingController> _ruleCtrlList = [TextEditingController()];
  bool _saving = false;

  bool get _isEditing => widget.strategy != null;

  double get _previewScore {
    final rules = _ruleCtrlList
        .map((c) => c.text.trim())
        .where((r) => r.isNotEmpty)
        .toList();
    if (rules.isEmpty) return 0;
    return Scorer.calculate(
      rulesFollowed: rules,
      totalRules: rules,
      slMoved: 'Held',
      preEmotion: 'Calm',
      executionRating: 5,
    );
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.strategy!.name;
      _descCtrl.text = widget.strategy!.description;
      _selectedInstruments = List.from(widget.strategy!.instruments);
      _ruleCtrlList = widget.strategy!.rules.isEmpty
          ? [TextEditingController()]
          : widget.strategy!.rules
              .map((r) => TextEditingController(text: r))
              .toList();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _ruleCtrlList) {
      c.dispose();
    }
    super.dispose();
  }

  void _addRule() {
    setState(() => _ruleCtrlList.add(TextEditingController()));
  }

  void _removeRule(int index) {
    if (_ruleCtrlList.length <= 1) return;
    setState(() {
      _ruleCtrlList[index].dispose();
      _ruleCtrlList.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Strategy name is required')),
      );
      return;
    }

    setState(() => _saving = true);

    final rules = _ruleCtrlList
        .map((c) => c.text.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    final json = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'instruments': _selectedInstruments,
      'rules': rules,
      'score': _previewScore,
    };

    try {
      final provider = context.read<AppProvider>();
      if (_isEditing) {
        await provider.updateStrategy(
          strategyId: widget.strategy!.id,
          json: json,
        );
      } else {
        await provider.addStrategy(json);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save. ${userFriendlyError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Strategy' : 'New Strategy'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ScoreCircle(score: _previewScore, size: 36),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Name ─────────────────────────────────────────────────────────
          _label('Strategy Name'),
          AppTextField(
            hint: 'e.g. London Breakout',
            controller: _nameCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),

          // ── Description ──────────────────────────────────────────────────
          _label('Description (optional)'),
          AppTextField(
            hint: 'Brief description of this strategy',
            controller: _descCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 14),

          // ── Instruments ───────────────────────────────────────────────────
          _label('Instruments'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: K.instruments.map((inst) {
              final selected = _selectedInstruments.contains(inst);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedInstruments.remove(inst);
                    } else {
                      _selectedInstruments.add(inst);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? C.primary : C.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? C.primary : C.border,
                    ),
                  ),
                  child: Text(
                    inst,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected ? C.white : C.secondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Rules ─────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('Rules', inline: true),
              TextButton.icon(
                onPressed: _addRule,
                icon: const Icon(Icons.add, size: 16, color: C.primary),
                label: const Text(
                  'Add Rule',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: C.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._ruleCtrlList.asMap().entries.map((entry) {
            final index = entry.key;
            final ctrl = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: C.border),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: C.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                      hint: 'Describe this rule',
                      controller: ctrl,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (_ruleCtrlList.length > 1) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeRule(index),
                      child: const Icon(
                        Icons.close,
                        color: C.muted,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // ── Save button ───────────────────────────────────────────────────
          PrimaryButton(
            label: _isEditing ? 'Save Changes' : 'Create Strategy',
            loading: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _label(String text, {bool inline = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: inline ? 0 : 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: C.secondary,
        ),
      ),
    );
  }
}