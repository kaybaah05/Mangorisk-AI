import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared.dart';
import '../utils/errors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  bool  _saving   = false;
  bool  _edited   = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().profile;
    if (profile != null) {
      _nameCtrl.text = profile.displayName;
    }
    _nameCtrl.addListener(() {
      final profile = context.read<AppProvider>().profile;
      setState(() {
        _edited = _nameCtrl.text.trim() != (profile?.displayName ?? '');
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await context.read<AppProvider>().updateProfile(
            displayName: _nameCtrl.text.trim(),
          );
      if (mounted) {
        setState(() => _edited = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update. ${userFriendlyError(e)}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Sign Out',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(fontFamily: 'Inter', color: C.loss),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/auth');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed. ${userFriendlyError(e)}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile  = provider.profile;

    return Scaffold(
      backgroundColor: C.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Profile avatar + name ────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color:  C.accent.withValues(alpha: 0.15),
                    shape:  BoxShape.circle,
                    border: Border.all(
                      color: C.accent.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      profile?.displayName.isNotEmpty == true
                          ? profile!.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize:   28,
                        fontWeight: FontWeight.w700,
                        color:      C.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profile?.displayName ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize:   18,
                    fontWeight: FontWeight.w600,
                    color:      C.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color:        C.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(color: C.accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    profile?.plan ?? 'Trial',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                      color:      C.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 20),

          // ── Display Name ─────────────────────────────────────────────────
          _sectionTitle('PROFILE'),
          const SizedBox(height: 10),
          AppTextField(
            hint:       'Your display name',
            label:      'Display Name',
            controller: _nameCtrl,
          ),
          if (_edited) ...[
            const SizedBox(height: 10),
            PrimaryButton(
              label:     'Save Name',
              loading:   _saving,
              onPressed: _saveName,
            ),
          ],
          const SizedBox(height: 20),

          // ── Read-only info ────────────────────────────────────────────────
          _sectionTitle('ACCOUNT'),
          const SizedBox(height: 10),
          _infoTile(
            label: 'Email',
            value: profile?.email ?? '—',
            icon:  Icons.email_outlined,
          ),
          _infoTile(
            label: 'Plan',
            value: profile?.plan ?? 'Trial',
            icon:  Icons.workspace_premium_outlined,
          ),
          _infoTile(
            label: 'Member since',
            value: profile != null ? _formatDate(profile.createdAt) : '—',
            icon:  Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 20),

          // ── Referral code ─────────────────────────────────────────────────
          _sectionTitle('REFERRAL'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              if (profile == null) return;
              Clipboard.setData(ClipboardData(text: profile.referralCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral code copied')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        C.surface,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: C.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard_outlined, color: C.accent, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Referral Code',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.muted),
                      ),
                      Text(
                        profile?.referralCode ?? '—',
                        style: const TextStyle(
                          fontFamily:    'Inter',
                          fontSize:      16,
                          fontWeight:    FontWeight.w700,
                          color:         C.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.copy_outlined, color: C.muted, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Sign out ──────────────────────────────────────────────────────
          SizedBox(
            width:  double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _signOut,
              style: OutlinedButton.styleFrom(
                side:  const BorderSide(color: C.loss),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize:   15,
                  fontWeight: FontWeight.w600,
                  color:      C.loss,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily:    'Inter',
        fontSize:      11,
        fontWeight:    FontWeight.w600,
        color:         C.muted,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _infoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        C.surface,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: C.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: C.muted),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.muted),
              ),
              Text(
                value,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
