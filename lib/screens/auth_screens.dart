import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../state/model.dart';
import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/chrome.dart';
import '../widgets/pearl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.phoneTab = false, this.startOtp = false});
  final bool phoneTab;
  final bool startOtp;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late bool _phone = widget.phoneTab || widget.startOtp;
  late String _digits = widget.startOtp ? '9876543210' : '';
  late bool _otp = widget.startOtp;
  String _code = '';
  String? _busy;
  int _resend = 29;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.startOtp) return;
    _resend = 30;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _google() {
    setState(() => _busy = 'google');
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      AkayaScope.of(context).signIn('google', 'priya@example.com');
      context.go('/onboarding');
    });
  }

  void _sendOtp() {
    if (_digits.length != 10) return;
    setState(() => _busy = 'send');
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _busy = null;
        _otp = true;
        _resend = 30;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _resend = (_resend - 1).clamp(0, 30));
        if (_resend == 0) _timer?.cancel();
      });
    });
  }

  void _verify() {
    if (_code.length != 6) return;
    setState(() => _busy = 'verify');
    final contact = '+91 ${_digits.substring(0, 5)} ${_digits.substring(5)}';
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      AkayaScope.of(context).signIn('phone', contact);
      context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return AkayaScreen(
      child: Column(
        children: [
          const SizedBox(height: 10),
          const AkayaLogo(size: 25),
          Text('Your intelligent assistant', style: manrope(11.2, p.text2, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          SizedBox(
            height: 172,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Pearl(width: 360, height: 172, radius: 58, cx: 166, cy: 94, mood: PearlMood.happy, interactive: true, dark: p.dark),
                Positioned(
                  left: 200,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(13, 9, 13, 9),
                    decoration: BoxDecoration(
                      color: p.surfaceSolid,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(6)),
                      border: Border.all(color: p.line),
                      boxShadow: p.shadowLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hi, I'm Akaya!", style: comfortaa(14, p.text)),
                        Text('Your new AI buddy', style: manrope(10.5, p.text2, weight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_otp) ...[
            Text("Let's get you started", style: comfortaa(23.2, p.text), textAlign: TextAlign.center),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 6, 30, 0),
              child: Text('Chat, speak, translate and get things done.', textAlign: TextAlign.center, style: manrope(12.8, p.text2, weight: FontWeight.w600, height: 1.45)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Column(
                children: [
                  OutlineButton(
                    label: _busy == 'google' ? 'Signing in…' : 'Continue with Google',
                    leading: _busy == 'google' ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const GoogleMark(),
                    onTap: _google,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(child: Container(height: 1, color: p.lineStrong)),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('OR', style: manrope(11.2, p.text3, weight: FontWeight.w700))),
                        Expanded(child: Container(height: 1, color: p.lineStrong)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: p.tint('violet'), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        _tab(p, 'Email', 'mail', !_phone, () => setState(() => _phone = false)),
                        _tab(p, 'Phone', 'phone', _phone, () => setState(() => _phone = true)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_phone) ...[
                    _phoneField(p),
                    const SizedBox(height: 12),
                    PrimaryButton(label: 'Send OTP', onTap: _sendOtp, enabled: _digits.length == 10 && _busy == null, busy: _busy == 'send'),
                  ] else
                    const EmailSignUpForm(),
                ],
              ),
            ),
          ] else ...[
            Text('Enter the code', style: comfortaa(23.2, p.text)),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 6, 30, 0),
              child: Text.rich(
                TextSpan(
                  style: manrope(12.8, p.text2, weight: FontWeight.w600, height: 1.45),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to '),
                    TextSpan(text: '+91 ${_digits.substring(0, 5)} ${_digits.substring(5)}', style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Column(
                children: [
                  _otpBoxes(p),
                  const SizedBox(height: 8),
                  Text('Demo: any 6 digits work.', style: manrope(12, p.text3, weight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: _busy == 'verify' ? 'Verifying…' : 'Verify & continue',
                    icon: 'check',
                    busy: _busy == 'verify',
                    enabled: _code.length == 6,
                    onTap: _verify,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _otp = false;
                          _code = '';
                        }),
                        child: Text('Change number', style: manrope(13, AkayaPalette.violet, weight: FontWeight.w800)),
                      ),
                      Text(_resend > 0 ? 'Resend in 0:${_resend.toString().padLeft(2, '0')}' : 'Resend code', style: manrope(13, _resend > 0 ? p.text3 : AkayaPalette.violet, weight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 8),
            child: Text.rich(
              TextSpan(
                style: manrope(11.5, p.text3, weight: FontWeight.w600, height: 1.45),
                children: [
                  const TextSpan(text: "By continuing, you agree to Akaya's "),
                  TextSpan(text: 'Terms of Service', style: TextStyle(color: AkayaPalette.violet, fontWeight: FontWeight.w800)),
                  const TextSpan(text: ' and '),
                  TextSpan(text: 'Privacy Policy', style: TextStyle(color: AkayaPalette.violet, fontWeight: FontWeight.w800)),
                  const TextSpan(text: '.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(AkayaPalette p, String label, String icon, bool on, VoidCallback tap) {
    return Expanded(
      child: GestureDetector(
        onTap: tap,
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? p.surfaceSolid : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: on ? const [BoxShadow(color: Color(0x304632A0), blurRadius: 12, offset: Offset(0, 4))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AkayaIcon(icon, size: 15, color: on ? p.text : p.text2),
              const SizedBox(width: 6),
              Text(label, style: manrope(12.8, on ? p.text : p.text2, weight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneField(AkayaPalette p) {
    final shown = _digits.length > 5 ? '${_digits.substring(0, 5)} ${_digits.substring(5)}' : _digits;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: p.surfaceSolid, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.lineStrong, width: 1.5)),
      child: Row(
        children: [
          Container(width: 16, height: 11, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: const LinearGradient(colors: [Color(0xFFFF9933), Color(0xFFFFFFFF), Color(0xFF138808)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          const SizedBox(width: 6),
          Text('+91', style: manrope(14, p.text, weight: FontWeight.w800)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              style: manrope(14.4, p.text, weight: FontWeight.w600),
              decoration: InputDecoration(border: InputBorder.none, hintText: '98765 43210', hintStyle: manrope(14.4, p.text3, weight: FontWeight.w600), isCollapsed: true),
              onChanged: (v) => setState(() => _digits = v.replaceAll(RegExp(r'\D'), '')),
              controller: TextEditingController(text: shown)..selection = TextSelection.collapsed(offset: shown.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpBoxes(AkayaPalette p) {
    return SizedBox(
      height: 54,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 6; i++)
                Container(
                  width: 46,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.surfaceSolid,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: i == _code.length ? AkayaPalette.violet : p.lineStrong, width: 1.5),
                  ),
                  child: Text(i < _code.length ? _code[i] : '', style: comfortaa(20, p.text)),
                ),
            ],
          ),
          TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
            style: const TextStyle(color: Colors.transparent),
            cursorColor: Colors.transparent,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (v) => setState(() => _code = v),
          ),
        ],
      ),
    );
  }
}

class EmailSignUpForm extends StatefulWidget {
  const EmailSignUpForm({super.key});

  @override
  State<EmailSignUpForm> createState() => _EmailSignUpFormState();
}

class _EmailSignUpFormState extends State<EmailSignUpForm> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _confirm = TextEditingController();
  bool _touched = false;
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? get _emailErr {
    final e = _email.text.trim();
    if (e.isEmpty) return 'Enter your email';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(e)) return 'Enter a valid email, like name@example.com';
    return null;
  }

  String? get _pwErr {
    final pw = _pw.text;
    if (pw.isEmpty) return 'Create a password';
    final missing = <String>[];
    if (pw.length < 8) missing.add('8+ characters');
    if (!RegExp(r'[A-Za-z]').hasMatch(pw)) missing.add('a letter');
    if (!RegExp(r'\d').hasMatch(pw)) missing.add('a number');
    if (missing.isNotEmpty) return 'Password needs ${missing.join(', ')}';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DemoBadge(),
        if (_err != null) _error(p, _err!),
        AuthField(icon: 'mail', label: 'Email', hint: 'you@example.com', controller: _email, error: _touched ? _emailErr : null, onChanged: (_) => setState(() {})),
        AuthField(icon: 'lock', label: 'Password', hint: 'Create a password', controller: _pw, obscure: true, error: _touched ? _pwErr : null, onChanged: (_) => setState(() {})),
        _strength(p, _pw.text),
        AuthField(icon: 'lock', label: 'Confirm password', hint: 'Type it again', controller: _confirm, obscure: true, error: _touched && _confirm.text != _pw.text ? 'Passwords do not match' : null, onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        PrimaryButton(
          label: _busy ? 'Creating account…' : 'Create account',
          busy: _busy,
          onTap: () {
            setState(() => _touched = true);
            if (_emailErr != null || _pwErr != null || _confirm.text != _pw.text) return;
            setState(() => _busy = true);
            final model = AkayaScope.of(context);
            model.pendingEmail = _email.text.trim();
            model.emailVerified = false;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) context.go('/verify-email');
            });
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () => context.go('/login'),
            child: Text.rich(TextSpan(style: manrope(13, p.text2, weight: FontWeight.w600), children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(text: 'Log in', style: TextStyle(color: AkayaPalette.violet, fontWeight: FontWeight.w800)),
            ])),
          ),
        ),
      ],
    );
  }

  Widget _strength(AkayaPalette p, String pw) {
    var score = 0;
    if (pw.isNotEmpty) score = 1;
    if (pw.length >= 8 && RegExp(r'[A-Za-z]').hasMatch(pw) && RegExp(r'\d').hasMatch(pw)) score = 2;
    if (pw.length >= 12) score = 3;
    if (score >= 2 && RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) score = 4;
    const labels = ['', 'Too weak', 'Fair', 'Good', 'Strong'];
    const colors = [Color(0x00000000), Color(0xFFE5484D), Color(0xFFE8743B), Color(0xFF0DABF4), Color(0xFF08DA73)];
    if (pw.isEmpty) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (var i = 1; i <= 4; i++)
            Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(color: i <= score ? colors[score] : p.surface3, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          Text(labels[score], style: manrope(11, colors[score], weight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _touched = false;
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailErr = _email.text.trim().isEmpty ? 'Enter your email' : (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(_email.text.trim()) ? 'Enter a valid email, like name@example.com' : null);
    final pwErr = _pw.text.isEmpty ? 'Enter your password' : null;
    return AuthLayout(
      icon: 'user',
      title: 'Welcome back',
      sub: 'Log in with your email and password.',
      child: Column(
        children: [
          if (_err != null) _error(paletteOf(context), _err!),
          AuthField(icon: 'mail', label: 'Email', hint: 'you@example.com', controller: _email, error: _touched ? emailErr : null, onChanged: (_) => setState(() {})),
          AuthField(icon: 'lock', label: 'Password', hint: 'Your password', controller: _pw, obscure: true, error: _touched ? pwErr : null, onChanged: (_) => setState(() {})),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.go('/forgot?email=${Uri.encodeComponent(_email.text.trim())}'),
              child: Text('Forgot password?', style: manrope(13, AkayaPalette.violet, weight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: _busy ? 'Logging in…' : 'Log in',
            busy: _busy,
            onTap: () {
              setState(() {
                _touched = true;
                _err = null;
              });
              if (emailErr != null || pwErr != null) return;
              setState(() => _busy = true);
              Future.delayed(const Duration(milliseconds: 600), () {
                if (!context.mounted) return;
                AkayaScope.of(context).signIn('email', _email.text.trim());
                context.go('/onboarding');
              });
            },
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.go('/signup'),
            child: Text.rich(TextSpan(style: manrope(13, paletteOf(context).text2), children: [
              const TextSpan(text: 'New to Akaya? '),
              TextSpan(text: 'Create an account', style: TextStyle(color: AkayaPalette.violet, fontWeight: FontWeight.w800)),
            ])),
          ),
        ],
      ),
    );
  }
}

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key, this.email = ''});
  final String email;

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  late final _email = TextEditingController(text: widget.email);
  bool _sent = false;
  bool _touched = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return AuthLayout(
        icon: 'check',
        tone: 'green',
        back: '/login',
        title: 'Check your email',
        sub: 'If an account exists for ${_email.text.trim()}, a reset link is on its way. This demo does not send email.',
        child: PrimaryButton(label: 'Back to log in', onTap: () => context.go('/login')),
      );
    }
    final err = _email.text.trim().isEmpty ? 'Enter your email' : null;
    return AuthLayout(
      icon: 'lock',
      title: 'Forgot password?',
      sub: "Enter your email and we'll send you a reset link.",
      back: '/login',
      child: Column(
        children: [
          AuthField(icon: 'mail', label: 'Email', hint: 'you@example.com', controller: _email, error: _touched ? err : null, onChanged: (_) => setState(() {})),
          PrimaryButton(
            label: _busy ? 'Sending…' : 'Send reset link',
            busy: _busy,
            onTap: () {
              setState(() => _touched = true);
              if (err != null) return;
              setState(() => _busy = true);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() => _sent = true);
              });
            },
          ),
        ],
      ),
    );
  }
}

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  bool _busy = false;
  int _wait = 30;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _wait = (_wait - 1).clamp(0, 30));
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = AkayaScope.of(context);
    final email = model.pendingEmail ?? 'priya@example.com';
    return AuthLayout(
      icon: 'mail',
      tone: 'blue',
      title: 'Verify your email',
      sub: 'We sent a verification link to $email. Open it to activate your account.',
      child: Column(
        children: [
          PrimaryButton(
            label: _busy ? 'Checking…' : "I've verified my email",
            icon: 'check',
            busy: _busy,
            enabled: model.emailVerified,
            onTap: () {
              setState(() => _busy = true);
              model.signIn('email', email);
              context.go('/onboarding');
            },
          ),
          const SizedBox(height: 10),
          OutlineButton(
            label: 'Demo: mark as verified',
            leading: AkayaIcon('spark', size: 16, color: paletteOf(context).text),
            onTap: () {
              model.emailVerified = true;
              model.showToast('Email marked verified (demo)');
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(onTap: () => context.go('/signup'), child: Text('Use a different email', style: manrope(13, AkayaPalette.violet, weight: FontWeight.w800))),
              Text(_wait > 0 ? 'Resend in 0:${_wait.toString().padLeft(2, '0')}' : 'Resend email', style: manrope(13, _wait > 0 ? paletteOf(context).text3 : AkayaPalette.violet, weight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.icon, required this.title, required this.sub, required this.child, this.tone = 'violet', this.back = '/signup'});
  final String icon;
  final String title;
  final String sub;
  final Widget child;
  final String tone;
  final String back;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return AkayaScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                AkayaIconButton(icon: 'back', label: 'Back', onTap: () => context.go(back)),
                const Spacer(),
                const AkayaLogo(size: 20),
                const Spacer(),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Gi(icon: icon, tone: tone, size: 72, iconSize: 30, radius: 24),
          const SizedBox(height: 14),
          Text(title, style: comfortaa(23.2, p.text), textAlign: TextAlign.center),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 6, 30, 8),
            child: Text(sub, textAlign: TextAlign.center, style: manrope(12.8, p.text2, weight: FontWeight.w600, height: 1.45)),
          ),
          const DemoBadge(),
          Padding(padding: const EdgeInsets.fromLTRB(22, 8, 22, 0), child: child),
        ],
      ),
    );
  }
}

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: p.tint('violet'), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: p.surfaceSolid, borderRadius: BorderRadius.circular(99)),
            child: Text('DEMO MODE', style: manrope(10, AkayaPalette.violet, weight: FontWeight.w800, letterSpacing: 0.4)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text('Accounts stay on this device. No emails are sent.', style: manrope(11.5, p.text2, weight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class AuthField extends StatefulWidget {
  const AuthField({super.key, required this.icon, required this.label, required this.hint, required this.controller, this.obscure = false, this.error, this.onChanged});
  final String icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final String? error;
  final ValueChanged<String>? onChanged;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label.toUpperCase(), style: manrope(10.8, p.text2, weight: FontWeight.w800, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: p.surfaceSolid,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.error != null ? const Color(0xFFE5484D) : p.lineStrong, width: 1.5),
            ),
            child: Row(
              children: [
                AkayaIcon(widget.icon, size: 18, color: p.text3),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    obscureText: widget.obscure && _hide,
                    onChanged: widget.onChanged,
                    style: manrope(14.4, p.text, weight: FontWeight.w600),
                    decoration: InputDecoration(border: InputBorder.none, hintText: widget.hint, hintStyle: manrope(14.4, p.text3, weight: FontWeight.w600), isCollapsed: true),
                  ),
                ),
                if (widget.obscure)
                  GestureDetector(onTap: () => setState(() => _hide = !_hide), child: AkayaIcon(_hide ? 'eye' : 'eyeOff', size: 18, color: p.text3)),
              ],
            ),
          ),
          if (widget.error != null) Padding(padding: const EdgeInsets.only(top: 4, left: 4), child: Text(widget.error!, style: manrope(11.5, const Color(0xFFE5484D), weight: FontWeight.w700))),
        ],
      ),
    );
  }
}

Widget _error(AkayaPalette p, String msg) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0x1FE5484D), borderRadius: BorderRadius.circular(12)),
    child: Text(msg, style: manrope(12.5, const Color(0xFFE5484D), weight: FontWeight.w700)),
  );
}
