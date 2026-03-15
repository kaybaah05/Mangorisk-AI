import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared.dart';
import 'log_trade_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _filter = 'All';

  Future<void> _refresh() async {
    await context.read<AppProvider>().loadTrades();
  }

  void _openLogTrade() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const LogTradeScreen(),
    );
  }

  void _confirmDelete(BuildContext context, String tradeId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete Trade',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: C.primary),
        ),
        content: const Text(
          'Are you sure you want to delete this trade? This cannot be undone.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context); // capture before await
              Navigator.of(context, rootNavigator: true).pop();
              try {
                await context.read<AppProvider>().deleteTrade(tradeId);
              } catch (_) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Failed to delete trade')),
                );
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final trades   = provider.filteredTrades(_filter);

    return Scaffold(
      backgroundColor: C.background,
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 26),
            onPressed: _openLogTrade,
            tooltip: 'Log Trade',
          ),
        ],
      ),
      body: provider.loading && provider.trades.isEmpty
          ? const LoadingOverlay()
          : RefreshIndicator(
              onRefresh: _refresh,
              color: C.accent,
              child: CustomScrollView(
                slivers: [
                  // ── Summary Strip ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: SummaryStrip(
                      winRate:       provider.winRate,
                      avgDiscipline: provider.avgDisciplineScore,
                      avgRR:         provider.avgRR,
                      totalPnL:      provider.totalPnL,
                    ),
                  ),

                  // ── Filter Pills ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: FilterPills(
                        selected: _filter,
                        onSelect: (f) => setState(() => _filter = f),
                      ),
                    ),
                  ),

                  // ── Trade count ───────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Text(
                        '${trades.length} trade${trades.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize:   12,
                          color:      C.muted,
                        ),
                      ),
                    ),
                  ),

                  // ── Trade List ────────────────────────────────────────────
                  trades.isEmpty
                      ? SliverFillRemaining(
                          child: EmptyState(
                            message: _filter == 'All'
                                ? 'No trades yet.\nTap + to log your first trade.'
                                : 'No $_filter trades found.',
                            icon: Icons.receipt_long_outlined,
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final trade = trades[index];
                              return TradeRowCard(
                                trade:       trade,
                                onLongPress: () =>
                                    _confirmDelete(context, trade.id),
                              );
                            },
                            childCount: trades.length,
                          ),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
    );
  }
}