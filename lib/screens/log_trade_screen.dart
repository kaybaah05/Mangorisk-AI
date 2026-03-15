import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/shared.dart';
import '../utils/errors.dart';

class LogTradeScreen extends StatefulWidget {
  const LogTradeScreen({super.key});

  @override
  State<LogTradeScreen> createState() => _LogTradeScreenState();
}

class _LogTradeScreenState extends State<LogTradeScreen> {
  int _step = 0;

  // ── Step 1 state ───────────────────────────────────────────────────────────
  String  _instrument  = K.instruments.first;
  String  _direction   = 'Long';
  String  _timeframe   = K.timeframes[4];
  final   _entryCtrl   = TextEditingController();
  final   _slCtrl      = TextEditingController();
  final   _targetCtrl  = TextEditingController();
  String  _preEmotion  = 'Calm';
  String? _strategyId;
  final   _reasonCtrl  = TextEditingController();

  // ── Step 2 state ───────────────────────────────────────────────────────────
  String _outcome      = 'Win';
  final  _actEntryCtrl = TextEditingController();
  final  _actExitCtrl  = TextEditingController();
  String _slMoved      = 'Held';

  // ── Step 3 state ───────────────────────────────────────────────────────────
  final List<String> _rulesFollowed = [];  // prefer_final_fields fix
  int    _execRating  = 3;
  String _postEmotion = 'Calm';
  final  _lessonCtrl  = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _entryCtrl.dispose();
    _slCtrl.dispose();
    _targetCtrl.dispose();
    _reasonCtrl.dispose();
    _actEntryCtrl.dispose();
    _actExitCtrl.dispose();
    _lessonCtrl.dispose();
    super.dispose();
  }

  double get _rr {
    final entry  = double.tryParse(_entryCtrl.text)  ?? 0;
    final sl     = double.tryParse(_slCtrl.text)     ?? 0;
    final target = double.tryParse(_targetCtrl.text) ?? 0;
    if (entry == 0 || sl == 0 || target == 0) return 0;
    return Scorer.calcRR(entry, sl, target, _direction);
  }

  double get _pnl {
    final entry = double.tryParse(_actEntryCtrl.text) ?? 0;
    final exit  = double.tryParse(_actExitCtrl.text)  ?? 0;
    if (entry == 0 || exit == 0) return 0;
    return Scorer.calcPnL(entry, exit, _direction);
  }

  double get _disciplineScore {
    final strategy   = context.read<AppProvider>().strategyById(_strategyId);
    final totalRules = strategy?.rules ?? [];
    return Scorer.calculate(
      rulesFollowed:   _rulesFollowed,
      totalRules:      totalRules,
      slMoved:         _slMoved,
      preEmotion:      _preEmotion,
      executionRating: _execRating,
    );
  }

  void _nextStep() { if (_step < 2) setState(() => _step++); }
  void _prevStep() { if (_step > 0) setState(() => _step--); }

  bool get _step1Valid =>
      _entryCtrl.text.isNotEmpty &&
      _slCtrl.text.isNotEmpty &&
      _targetCtrl.text.isNotEmpty;

  bool get _step2Valid =>
      _actEntryCtrl.text.isNotEmpty && _actExitCtrl.text.isNotEmpty;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final provider   = context.read<AppProvider>();
      final strategy   = provider.strategyById(_strategyId);
      final totalRules = strategy?.rules ?? [];
      final score      = _disciplineScore;
      final flags      = Scorer.detectFlags(
        preEmotion:      _preEmotion,
        slMoved:         _slMoved,
        rulesFollowed:   _rulesFollowed,
        totalRules:      totalRules,
        outcome:         _outcome,
        executionRating: _execRating,
      );

      await provider.addTrade({
        'instrument':       _instrument,
        'direction':        _direction,
        'timeframe':        _timeframe,
        'entry_price':      double.tryParse(_entryCtrl.text)    ?? 0,
        'sl_price':         double.tryParse(_slCtrl.text)       ?? 0,
        'target_price':     double.tryParse(_targetCtrl.text)   ?? 0,
        'pre_emotion':      _preEmotion,
        'strategy_id':      _strategyId,
        'reason':           _reasonCtrl.text.trim(),
        'outcome':          _outcome,
        'actual_entry':     double.tryParse(_actEntryCtrl.text) ?? 0,
        'actual_exit':      double.tryParse(_actExitCtrl.text)  ?? 0,
        'sl_moved':         _slMoved,
        'rules_followed':   _rulesFollowed,
        'execution_rating': _execRating,
        'post_emotion':     _postEmotion,
        'lesson':           _lessonCtrl.text.trim(),
        'discipline_score': score,
        'pnl':              _pnl,
        'rr':               _rr,
        'is_flagged':       flags.isNotEmpty,
        'flags':            flags,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save trade. ${userFriendlyError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize:     0.6,
      maxChildSize:     0.95,
      expand:           false,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: C.border, borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Log Trade',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize:   18,
                      fontWeight: FontWeight.w700,
                      color:      C.primary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(3, (i) {
                      final done   = i < _step;
                      final active = i == _step;
                      return Container(
                        margin: const EdgeInsets.only(left: 6),
                        width:  active ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? C.accent : done ? C.primary : C.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _step == 0 ? 'Step 1 — Pre-Trade'
                    : _step == 1 ? 'Step 2 — Execution'
                    : 'Step 3 — Review',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13, color: C.muted,
                ),
              ),
            ),
            const Divider(height: 20),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _step == 0 ? _buildStep1()
                    : _step == 1  ? _buildStep2()
                    : _buildStep3(),
              ),
            ),

            _buildFooter(),
          ],
        );
      },
    );
  }

  // ── STEP 1 ─────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    final strategies = context.watch<AppProvider>().strategies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Instrument'),
        _dropdown(value: _instrument, items: K.instruments,
            onChanged: (v) => setState(() => _instrument = v!)),
        const SizedBox(height: 14),

        _label('Direction'),
        Row(
          children: K.directions.map((d) {
            final active = _direction == d;
            final color  = d == 'Long' ? C.win : C.loss;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _direction = d),
                child: Container(
                  margin: EdgeInsets.only(right: d == 'Long' ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:        active ? color : C.surface,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: active ? color : C.border),
                  ),
                  child: Center(
                    child: Text(d, style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color:      active ? C.white : C.secondary,
                    )),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        _label('Timeframe'),
        _dropdown(value: _timeframe, items: K.timeframes,
            onChanged: (v) => setState(() => _timeframe = v!)),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Entry'),
              AppTextField(hint: '0.00', controller: _entryCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {})),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Stop Loss'),
              AppTextField(hint: '0.00', controller: _slCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {})),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Target'),
              AppTextField(hint: '0.00', controller: _targetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {})),
            ])),
          ],
        ),

        if (_rr > 0) ...[
          const SizedBox(height: 8),
          _liveMetric('R:R', _rr.toStringAsFixed(2), C.primary),
        ],
        const SizedBox(height: 14),

        _label('Pre-Trade Emotion'),
        _dropdown(value: _preEmotion, items: K.emotions,
            onChanged: (v) => setState(() => _preEmotion = v!)),
        const SizedBox(height: 14),

        _label('Strategy (optional)'),
        _dropdown(
          value:     _strategyId ?? 'None',
          items:     ['None', ...strategies.map((s) => s.id)],
          labels:    {'None': 'None', ...{for (var s in strategies) s.id: s.name}},
          onChanged: (v) => setState(() => _strategyId = v == 'None' ? null : v),
        ),
        const SizedBox(height: 14),

        _label('Reason for trade'),
        AppTextField(hint: 'Why are you taking this trade?',
            controller: _reasonCtrl, maxLines: 3),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── STEP 2 ─────────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Outcome'),
        Row(
          children: K.outcomes.map((o) {
            final active = _outcome == o;
            Color color;
            if (o == 'Win') {
              color = C.win;
            } else if (o == 'Loss') {
              color = C.loss;
            } else {
              color = C.muted;
            }
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _outcome = o),
                child: Container(
                  margin: EdgeInsets.only(right: o != K.outcomes.last ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:        active ? color : C.surface,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: active ? color : C.border),
                  ),
                  child: Center(
                    child: Text(o, style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color:      active ? C.white : C.secondary,
                    )),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Actual Entry'),
              AppTextField(hint: '0.00', controller: _actEntryCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {})),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Actual Exit'),
              AppTextField(hint: '0.00', controller: _actExitCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {})),
            ])),
          ],
        ),

        if (_pnl != 0) ...[
          const SizedBox(height: 8),
          _liveMetric(
            'P&L',
            _pnl >= 0 ? '+${_pnl.toStringAsFixed(2)}' : _pnl.toStringAsFixed(2),
            _pnl >= 0 ? C.win : C.loss,
          ),
        ],
        const SizedBox(height: 14),

        _label('Did you move your Stop Loss?'),
        Row(
          children: K.slMoveOptions.map((o) {
            final active = _slMoved == o;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _slMoved = o),
                child: Container(
                  margin: EdgeInsets.only(right: o != K.slMoveOptions.last ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:        active ? C.primary : C.surface,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: active ? C.primary : C.border),
                  ),
                  child: Center(
                    child: Text(o, style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize:   13,
                      fontWeight: FontWeight.w600,
                      color:      active ? C.white : C.secondary,
                    )),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── STEP 3 ─────────────────────────────────────────────────────────────────
  Widget _buildStep3() {
    final strategy   = context.watch<AppProvider>().strategyById(_strategyId);
    final totalRules = strategy?.rules ?? [];
    final score      = _disciplineScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (totalRules.isNotEmpty) ...[
          _label('Rules Followed'),
          ...totalRules.map((rule) {
            final checked = _rulesFollowed.contains(rule);
            return CheckboxListTile(
              value:    checked,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _rulesFollowed.add(rule);
                  } else {
                    _rulesFollowed.remove(rule);
                  }
                });
              },
              title: Text(rule, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14, color: C.primary,
              )),
              activeColor:     C.primary,
              checkColor:      C.white,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding:  EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 14),
        ],

        _label('Execution Rating'),
        Row(
          children: List.generate(5, (i) {
            final filled = i < _execRating;
            return GestureDetector(
              onTap: () => setState(() => _execRating = i + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: filled ? C.accent : C.border,
                  size: 32,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),

        _label('Post-Trade Emotion'),
        _dropdown(value: _postEmotion, items: K.emotions,
            onChanged: (v) => setState(() => _postEmotion = v!)),
        const SizedBox(height: 14),

        _label('Lesson learned'),
        AppTextField(hint: 'What did you learn from this trade?',
            controller: _lessonCtrl, maxLines: 3),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        Scorer.scoreColor(score).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Scorer.scoreColor(score).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              ScoreCircle(score: score, size: 52),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Discipline Score', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: C.muted,
                  )),
                  Text(score.toStringAsFixed(0), style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize:   28,
                    fontWeight: FontWeight.w700,
                    color:      Scorer.scoreColor(score),
                  )),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── FOOTER ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color:  C.background,
        border: Border(top: BorderSide(color: C.border)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  side:        const BorderSide(color: C.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Back', style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color:      C.secondary,
                )),
              ),
            ),
          if (_step > 0) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label:   _step == 2 ? 'Save Trade' : 'Next',
              loading: _saving,
              onPressed: _step == 0
                  ? (_step1Valid ? _nextStep : null)
                  : _step == 1
                      ? (_step2Valid ? _nextStep : null)
                      : _save,
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(
        fontFamily: 'Inter',
        fontSize:   12,
        fontWeight: FontWeight.w600,
        color:      C.secondary,
      )),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    Map<String, String>? labels,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:        C.surface,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: C.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:      value,
          isExpanded: true,
          style:      const TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.primary),
          icon:       const Icon(Icons.keyboard_arrow_down, color: C.muted),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(labels?[item] ?? item),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _liveMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 12, color: C.muted,
          )),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(
            fontFamily: 'Inter',
            fontSize:   16,
            fontWeight: FontWeight.w700,
            color:      color,
          )),
        ],
      ),
    );
  }
}