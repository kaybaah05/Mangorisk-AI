import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/theme.dart';
import '../widgets/shared.dart';
import '../utils/errors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.background,
      body: Stack(
        children: [
          // ── Background circles top-right ──────────────────────────────
          _circle(top: -100, right: -100, size: 280, alpha: 0.10),
          _circle(top:  -40, right:  -40, size: 160, alpha: 0.15),
          _circle(top:   30, right:   30, size:  60, alpha: 0.22),

          // ── Background circles bottom-left ────────────────────────────
          _circle(bottom: -100, left: -100, size: 280, alpha: 0.10),
          _circle(bottom:  -40, left:  -40, size: 160, alpha: 0.15),
          _circle(bottom:   30, left:   30, size:  60, alpha: 0.22),

          // ── Content ───────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: C.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.show_chart, color: C.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text('MangoRisk', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 22,
                            fontWeight: FontWeight.w700, color: C.primary,
                          )),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Tagline
                      const Text('Track your discipline.', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 28,
                        fontWeight: FontWeight.w800, color: C.primary, height: 1.2,
                      )),
                      const Text('Improve your edge.', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 28,
                        fontWeight: FontWeight.w800, color: C.muted, height: 1.2,
                      )),
                      const SizedBox(height: 32),

                      // Tab switcher
                      Container(
                        height: 48,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: C.border),
                        ),
                        child: TabBar(
                          controller:           _tabController,
                          indicator: BoxDecoration(
                            color: C.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          indicatorSize:        TabBarIndicatorSize.tab,
                          indicatorPadding:     EdgeInsets.zero,
                          dividerColor:         Colors.transparent,
                          labelColor:           C.white,
                          unselectedLabelColor: C.muted,
                          labelStyle: const TextStyle(
                            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                          ),
                          tabs: const [Tab(text: 'Log In'), Tab(text: 'Sign Up')],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Form — switches on tab tap, no swipe
                      _tabController.index == 0
                          ? const _LoginForm()
                          : const _SignupForm(),

                      const Spacer(),
                      const SizedBox(height: 32),

                      // Footer
                      Center(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(
                            _tabController.index == 0 ? 1 : 0,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 13, color: C.muted,
                              ),
                              children: [
                                TextSpan(
                                  text: _tabController.index == 0
                                      ? 'New to MangoRisk? '
                                      : 'Already have an account? ',
                                ),
                                TextSpan(
                                  text: _tabController.index == 0
                                      ? 'Create an account'
                                      : 'Log in',
                                  style: const TextStyle(
                                    fontFamily: 'Inter', fontSize: 13,
                                    fontWeight: FontWeight.w700, color: C.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Privacy Policy', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11, color: C.muted,
                          )),
                          SizedBox(width: 24),
                          Text('Terms of Service', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11, color: C.muted,
                          )),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle({
    double? top, double? bottom, double? left, double? right,
    required double size, required double alpha,
  }) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: C.accent.withValues(alpha: alpha),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LOGIN FORM
// ══════════════════════════════════════════════════════════════════════════════
class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _obscure   = true;
  bool  _loading   = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(), password: _passCtrl.text.trim(),
      );
      if (mounted) {
        context.go('/journal');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first')),
      );
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('EMAIL'),
          const SizedBox(height: 6),
          AppTextField(
            hint: 'Enter your email', controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fieldLabel('PASSWORD'),
              GestureDetector(
                onTap: _forgotPassword,
                child: const Text('Forgot password?', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: C.accent,
                )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppTextField(
            hint: 'Enter your password', controller: _passCtrl, obscure: _obscure,
            suffix: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: C.muted, size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 20),

          PrimaryButton(label: 'Log In', loading: _loading, onPressed: _login),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SIGNUP FORM
// ══════════════════════════════════════════════════════════════════════════════
class _SignupForm extends StatefulWidget {
  const _SignupForm();
  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool  _obscure        = true;
  bool  _obscureConfirm = true;
  bool  _loading        = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(), password: _passCtrl.text.trim(),
        data:  {'display_name': _nameCtrl.text.trim()},
      );
      if (mounted) {
        context.go('/journal');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('NAME'),
          const SizedBox(height: 6),
          AppTextField(
            hint: 'Enter your name', controller: _nameCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 16),

          _fieldLabel('EMAIL'),
          const SizedBox(height: 6),
          AppTextField(
            hint: 'Enter your email', controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),

          _fieldLabel('PASSWORD'),
          const SizedBox(height: 6),
          AppTextField(
            hint: 'Create a password', controller: _passCtrl, obscure: _obscure,
            suffix: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: C.muted, size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 16),

          _fieldLabel('CONFIRM PASSWORD'),
          const SizedBox(height: 6),
          AppTextField(
            hint: 'Repeat your password', controller: _confirmCtrl, obscure: _obscureConfirm,
            suffix: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: C.muted, size: 20,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 24),

          PrimaryButton(label: 'Create Account', loading: _loading, onPressed: _signup),
        ],
      ),
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────
Widget _fieldLabel(String text) {
  return Text(text, style: const TextStyle(
    fontFamily: 'Inter', fontSize: 11,
    fontWeight: FontWeight.w700, color: C.secondary, letterSpacing: 0.8,
  ));
}
