import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../state/model.dart';
import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/chrome.dart';
import '../widgets/pearl.dart';

void showAppConnect(BuildContext context, AkayaAppInfo app, {String step = 'detail'}) {
  final title = switch (step) {
    'consent' => app.kind == 'deeplink' ? 'Enable deep link' : 'Allow access',
    'connecting' || 'done' => '',
    _ => app.name,
  };
  showAkayaSheet(context, title: title, child: _ConnectBody(app: app, step: step));
}

class _Ability {
  const _Ability(this.label, this.prompt);
  final String label;
  final String prompt;
}

List<_Ability> _abilities(AkayaAppInfo app) {
  final n = app.name;
  return switch (app.category) {
    'email' => [
      _Ability('Read & summarise your inbox', 'Summarise my unread $n emails'),
      _Ability('Draft replies in your tone', 'Draft a polite reply to the latest $n email'),
      _Ability('Floating reply inside $n', 'Help me reply in $n'),
    ],
    'docs' => [
      _Ability('Search and summarise $n pages', 'Summarise my latest $n page'),
      _Ability('Save Smart Notes to $n', 'Save my last note to $n'),
      _Ability('Draft docs and meeting notes', 'Draft meeting notes in $n'),
    ],
    'calendar' => [
      _Ability('Daily agenda in your morning brief', "What's on my $n today?"),
      _Ability('Create events by voice', 'Add a meeting with Rahul tomorrow at 3 PM to $n'),
      _Ability('Spot clashes and suggest free slots', 'Find a free 30-minute slot this week in $n'),
    ],
    _ => [
      _Ability('Ask Akaya about $n', 'What can you do with my $n?'),
      _Ability('Draft with $n', 'Draft something in $n'),
      _Ability('Open $n for me', 'Open $n'),
    ],
  };
}

List<String> _permissions(AkayaAppInfo app) {
  final n = app.name;
  return switch (app.category) {
    'email' => ['Read your $n messages and labels', 'Create drafts (you review before sending)', 'Send only when you tap Send'],
    'docs' => ['Read pages you share with Akaya in $n', 'Create new pages', 'Edit pages Akaya created'],
    'calendar' => ['See events on your $n', 'Create and edit events you ask for', 'See free/busy times'],
    _ => ['Use $n only when you ask', 'Disconnect anytime in Apps & Integrations'],
  };
}

String _kindLabel(String kind) => switch (kind) {
      'oauth' => 'Sign in',
      'business-api' => 'Official API',
      'deeplink' => 'Deep link',
      'connector' => 'Connector',
      _ => kind,
    };

String _catLabel(String id) {
  for (final c in kCategories) {
    if (c.$1 == id) return c.$2;
  }
  return id;
}

class _ConnectBody extends StatefulWidget {
  const _ConnectBody({required this.app, required this.step});
  final AkayaAppInfo app;
  final String step;

  @override
  State<_ConnectBody> createState() => _ConnectBodyState();
}

class _ConnectBodyState extends State<_ConnectBody> {
  late String _step = widget.step;
  int _stage = 1;
  bool _confirm = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _allow() {
    setState(() {
      _step = 'connecting';
      _stage = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (!mounted) return;
      if (_stage >= 2) {
        t.cancel();
        final model = AkayaScope.of(context);
        model.connect(widget.app.id, model.email);
        model.showToast('${widget.app.name} connected');
        setState(() => _step = 'done');
        return;
      }
      setState(() => _stage += 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      'consent' => _consent(context),
      'connecting' => _connecting(context),
      'done' => _done(context),
      _ => _detail(context),
    };
  }

  Widget _detail(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final app = widget.app;
    final account = model.connected[app.id];
    final on = account != null;
    final abilities = _abilities(app);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          AppTile(id: app.id, size: 64),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.name, style: manrope(16, p.text, weight: FontWeight.w800)),
            Text('${_catLabel(app.category)} · ${_kindLabel(app.kind)}', style: manrope(12, p.text2, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(on ? 'Connected · $account' : 'Not connected', style: manrope(12, on ? p.greenText : p.text3, weight: FontWeight.w800)),
          ])),
        ]),
        const SizedBox(height: 10),
        Text(app.desc, style: manrope(13, p.text2, weight: FontWeight.w600, height: 1.4)),
        const SizedBox(height: 12),
        Text('What Akaya can do', style: manrope(13, p.text, weight: FontWeight.w800)),
        const SizedBox(height: 6),
        for (final ab in abilities)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Gi(icon: 'spark', tone: 'violet', size: 28, iconSize: 14, radius: 9),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ab.label, style: manrope(13, p.text, weight: FontWeight.w800)),
                Text('“${ab.prompt}”', style: manrope(12, p.text2, weight: FontWeight.w600)),
              ])),
            ]),
          ),
        const SizedBox(height: 4),
        Text('Permissions', style: manrope(13, p.text, weight: FontWeight.w800)),
        for (final perm in _permissions(app))
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(children: [
              AkayaIcon('check', size: 14, color: p.greenText, strokeWidth: 2.6),
              const SizedBox(width: 8),
              Expanded(child: Text(perm, style: manrope(12.5, p.text, weight: FontWeight.w600))),
            ]),
          ),
        const SizedBox(height: 8),
        Text(
          app.kind == 'oauth' ? 'You sign in on the app’s own page and choose what to allow. You can disconnect anytime.' : 'Disconnect anytime in Apps & Integrations.',
          style: manrope(12, p.text3, weight: FontWeight.w600, height: 1.35),
        ),
        const SizedBox(height: 12),
        if (on && _confirm)
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Disconnect ${app.name}? Akaya will stop using it and remove access.', style: manrope(13, p.text, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlineButton(label: 'Cancel', onTap: () => setState(() => _confirm = false))),
              const SizedBox(width: 8),
              Expanded(child: PrimaryButton(label: 'Disconnect', onTap: () {
                model.disconnect(app.id);
                model.showToast('${app.name} disconnected');
                setState(() => _confirm = false);
              })),
            ]),
          ])
        else if (on)
          Row(children: [
            Expanded(child: OutlineButton(label: 'Disconnect', onTap: () => setState(() => _confirm = true))),
            const SizedBox(width: 8),
            Expanded(child: PrimaryButton(label: 'Try in chat', icon: 'chat', onTap: () => context.go('/chat'))),
          ])
        else
          PrimaryButton(label: 'Connect ${app.name}', icon: 'plug', onTap: () => setState(() => _step = 'consent')),
      ],
    );
  }

  Widget _consent(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final app = widget.app;
    final deep = app.kind == 'deeplink';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Pearl(width: 64, height: 64, radius: 24, shadow: false, glow: 0.2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('···', style: manrope(18, p.text3, weight: FontWeight.w800))),
          AppTile(id: app.id, size: 60),
        ]),
        const SizedBox(height: 12),
        Text(deep ? 'Let Akaya open ${app.name} for you' : 'Akaya wants to connect to your ${app.name}', textAlign: TextAlign.center, style: comfortaa(18, p.text)),
        const SizedBox(height: 6),
        Text(deep ? 'Akaya will open the app with details filled in. Nothing else is shared.' : 'Signed in to Akaya as ${model.email}', textAlign: TextAlign.center, style: manrope(13, p.text2, weight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text('Akaya will be able to', style: manrope(12, p.text3, weight: FontWeight.w800)),
        for (final perm in _permissions(app))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const Gi(icon: 'check', tone: 'green', size: 26, iconSize: 13, radius: 8),
              const SizedBox(width: 8),
              Expanded(child: Text(perm, style: manrope(13, p.text, weight: FontWeight.w700))),
            ]),
          ),
        const SizedBox(height: 10),
        Text(
          app.kind == 'oauth' ? 'You’ll confirm on ${app.name}’s own sign-in page. Disconnect anytime in Apps & Integrations.' : 'Disconnect anytime in Apps & Integrations.',
          style: manrope(12, p.text3, weight: FontWeight.w600, height: 1.35),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlineButton(label: 'Cancel', onTap: () => setState(() => _step = 'detail'))),
          const SizedBox(width: 8),
          Expanded(child: PrimaryButton(label: deep ? 'Enable' : 'Allow & continue', onTap: _allow)),
        ]),
        const SizedBox(height: 8),
        Text('Demo: sign-in is simulated, no real account is linked.', textAlign: TextAlign.center, style: manrope(12, p.text3, weight: FontWeight.w600)),
      ],
    );
  }

  Widget _connecting(BuildContext context) {
    final p = paletteOf(context);
    final app = widget.app;
    const stages = ['sign-in', 'approval', 'abilities'];
    String label(int i) => switch (i) {
          0 => 'Opening ${app.name} sign-in',
          1 => 'Waiting for your approval',
          _ => 'Setting up abilities',
        };
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Pearl(width: 72, height: 72, radius: 27, mood: PearlMood.thinking, shadow: false, glow: 0.25),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('···', style: manrope(18, p.violetText, weight: FontWeight.w800))),
          AppTile(id: app.id, size: 64),
        ]),
        const SizedBox(height: 12),
        Text('Connecting to ${app.name}…', textAlign: TextAlign.center, style: comfortaa(18, p.text)),
        const SizedBox(height: 12),
        for (var i = 0; i < stages.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: i < _stage ? p.tint('green') : (i == _stage ? p.tint('violet') : p.surface2)),
                child: i < _stage ? AkayaIcon('check', size: 12, color: p.greenText, strokeWidth: 3) : Text('${i + 1}', style: manrope(11, p.text, weight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              Text(label(i), style: manrope(13.5, i == _stage ? p.text : p.text2, weight: FontWeight.w700)),
            ]),
          ),
      ],
    );
  }

  Widget _done(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final app = widget.app;
    final account = model.connected[app.id] ?? model.email;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 84,
            height: 84,
            child: Stack(children: [
              AppTile(id: app.id, size: 76),
              Positioned(right: 0, bottom: 0, child: Container(width: 26, height: 26, alignment: Alignment.center, decoration: BoxDecoration(color: p.greenText, shape: BoxShape.circle), child: const AkayaIcon('check', size: 14, color: Colors.white, strokeWidth: 3))),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Text('${app.name} connected', textAlign: TextAlign.center, style: comfortaa(20, p.text)),
        Text('$account · just now', textAlign: TextAlign.center, style: manrope(13, p.text2, weight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text('Try asking', textAlign: TextAlign.center, style: manrope(12, p.text3, weight: FontWeight.w800)),
        const SizedBox(height: 6),
        for (final ab in _abilities(app))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => context.go('/chat'),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: glass(p, radius: 14),
                child: Row(children: [
                  AkayaIcon('ask', size: 16, color: p.violetText),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ab.prompt, style: manrope(13, p.text, weight: FontWeight.w700))),
                ]),
              ),
            ),
          ),
        PrimaryButton(label: 'Manage ${app.name}', onTap: () => setState(() => _step = 'detail')),
      ],
    );
  }
}
