import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/model.dart';
import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/chrome.dart';
import '../widgets/pearl.dart';
import 'feature_screens.dart' show inr;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.sheet, this.scroll, this.focus});
  final String? sheet;
  final String? scroll;
  final String? focus;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _appsKey = GlobalKey();
  final _notesKey = GlobalKey();
  int _tip = 0;
  bool _showTip = false;
  static const _tips = [
    'Tap the bar below and just ask!',
    'I can translate 99+ languages.',
    'Try Read Screen on any app.',
    'Hehe, that tickles!',
    'Need a reminder? Just ask.',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSheet());
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sheet != widget.sheet) _maybeSheet();
  }

  void _maybeSheet() {
    final s = widget.sheet;
    if (s == null || !mounted) return;
    final titles = {
      'notifications': 'Notifications',
      'read': 'Read Screen',
      'read-done': 'Read Screen',
      'today': 'Today',
      'agents': 'AI Agents',
      'explore': 'Explore',
      'loan': 'Instant Loan',
    };
    if (!titles.containsKey(s)) return;
    showAkayaSheet(
      context,
      title: titles[s]!,
      child: _sheetBody(s),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final focus = widget.focus;
    return AkayaScreen(
      jumpEnd: widget.scroll == 'bottom',
      anchor: focus == 'apps' ? _appsKey : (focus == 'vnotes' ? _notesKey : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            child: Row(
              children: [
                GestureDetector(onTap: () => context.go('/more'), child: const AkayaAvatar(size: 44)),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${greeting()},', style: manrope(12.2, p.text2, weight: FontWeight.w600)),
                      Text(model.name, style: comfortaa(19.5, p.text)),
                    ],
                  ),
                ),
                AkayaIconButton(icon: 'history', label: 'History', onTap: () => context.go('/history')),
                const SizedBox(width: 8),
                _bell(p, model),
                const SizedBox(width: 8),
                AkayaIconButton(icon: 'gear', label: 'Settings', onTap: () => context.go('/more')),
              ],
            ),
          ),
          SizedBox(
            height: 196,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Segmented(
                    value: model.mode,
                    onChanged: (v) {
                      model.setMode(v);
                      model.showToast(v == 'on-device' ? 'On-device AI · works offline' : 'Online mode · full cloud models');
                    },
                    options: [
                      ('on-device', Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 7, height: 7, decoration: BoxDecoration(color: model.mode == 'on-device' ? AkayaPalette.green : p.text3, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        const Text('On-device'),
                      ])),
                      ('online', const Row(mainAxisSize: MainAxisSize.min, children: [AkayaIcon('globe', size: 13), SizedBox(width: 4), Text('Online')])),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _showTip = true);
                      _tip = (_tip + 1) % _tips.length;
                      Future.delayed(const Duration(milliseconds: 2600), () {
                        if (mounted) setState(() => _showTip = false);
                      });
                    },
                    child: Pearl(width: 390, height: 196, radius: 66, cy: 116, scene: true, interactive: true, dark: p.dark, label: 'Akaya. Tap me'),
                  ),
                ),
                if (_showTip)
                  Positioned(
                    left: 230,
                    top: 50,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: p.surfaceSolid, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16), bottomLeft: Radius.circular(5)), border: Border.all(color: p.line), boxShadow: p.shadowLg),
                      child: Text(_tips[_tip], style: manrope(11.8, p.text, weight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Text.rich(
              TextSpan(style: comfortaa(21.1, p.text), children: [
                const TextSpan(text: 'How can I help you '),
                WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: GradText('today?', size: 21.1)),
              ]),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              height: 56,
              padding: const EdgeInsets.fromLTRB(4, 6, 6, 6),
              decoration: glass(p, radius: 99).copyWith(boxShadow: p.shadowLg),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/chat?focus=1'),
                      child: Row(
                        children: [
                          SizedBox(width: 44, child: AkayaIcon('keyboard', size: 20, color: p.text2)),
                          Container(width: 1, height: 22, color: p.lineStrong),
                          const SizedBox(width: 12),
                          Text('Ask Akaya anything…', style: manrope(15.2, p.text3, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/voice'),
                    child: Container(
                      width: 66,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(gradient: p.brand, borderRadius: BorderRadius.circular(99), boxShadow: const [BoxShadow(color: Color(0xBF3C28DC), blurRadius: 18, offset: Offset(0, 8), spreadRadius: -8)]),
                      child: const WaveBars(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _bento(context, p, model),
          SectionHead(title: 'Today', action: 'Reminders', onAction: () => context.go('/reminders')),
          SizedBox(height: 210, child: _today(context, p, model)),
          KeyedSubtree(key: _appsKey, child: SectionHead(title: 'Your apps', action: 'Manage', onAction: () => context.go('/apps'))),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final id in model.connected.keys) _appChip(context, p, id),
                _addChip(context, p),
              ],
            ),
          ),
          const SectionHead(title: 'Do more with Akaya'),
          SizedBox(height: 168, child: _features(context)),
          SectionHead(title: 'Recent chats', action: 'History', onAction: () => context.go('/history')),
          _chats(context, p, model),
        ],
      ),
    );
  }

  Widget _bell(AkayaPalette p, AppModel model) {
    return Stack(
      children: [
        AkayaIconButton(icon: 'bell', label: 'Notifications', onTap: () => context.go('/home?sheet=notifications')),
        if (model.unread > 0 && model.notificationsOn)
          Positioned(top: 9, right: 10, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: AkayaPalette.orange, shape: BoxShape.circle, border: Border.all(color: p.surfaceSolid, width: 2)))),
      ],
    );
  }

  Widget _bento(BuildContext context, AkayaPalette p, AppModel model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: LayoutBuilder(
        builder: (context, c) {
          const gap = 9.0;
          final col = (c.maxWidth - gap * 3) / 4;
          final half = col * 2 + gap;
          return Column(
            children: [
              SizedBox(
                height: 74 + gap + 92,
                child: Row(
                  children: [
                    _float(context, p, model, half, 74 + gap + 92),
                    const SizedBox(width: gap),
                    Expanded(
                      child: Column(
                        children: [
                          _tile(context, p, 'ask', 'violet', 'Ask Akaya', 'Start a new chat', () => context.go('/chat?new=1'), height: 74),
                          const SizedBox(height: gap),
                          SizedBox(
                            height: 92,
                            child: Row(
                              children: [
                                Expanded(child: _tile(context, p, 'translate', 'green', 'Translate', '99+ langs', () => context.go('/translate'), stacked: true)),
                                const SizedBox(width: gap),
                                Expanded(child: _tile(context, p, 'read', 'cyan', 'Read Screen', null, () => context.go('/home?sheet=read'), stacked: true)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: gap),
              Row(
                children: [
                  Expanded(child: _tile(context, p, 'future', 'pink', 'Future Message', 'Schedule sends', () => context.go('/future'), height: 66)),
                  const SizedBox(width: gap),
                  Expanded(child: _tile(context, p, 'note', 'blue', 'Smart Note', 'Save & organise', () => context.go('/notes'), height: 66)),
                ],
              ),
              const SizedBox(height: gap),
              GestureDetector(
                key: _notesKey,
                onTap: () => context.go('/vnotes'),
                child: Container(
                  height: 62,
                  padding: const EdgeInsets.fromLTRB(11, 10, 14, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [Color(0xFF0269F8), Color(0xFF7625EF)]),
                    boxShadow: const [BoxShadow(color: Color(0xD9463CF0), blurRadius: 26, offset: Offset(0, 14), spreadRadius: -14)],
                  ),
                  child: Row(
                    children: [
                      Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(13)), child: const AkayaIcon('wave', size: 20, color: Colors.white, strokeWidth: 2.2)),
                      const SizedBox(width: 11),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Voice Notes', style: manrope(12.8, Colors.white, weight: FontWeight.w800)),
                        Text('Lecture & meeting notes, live', style: manrope(10.5, const Color(0xD9FFFFFF), weight: FontWeight.w600)),
                      ])),
                      const WaveBars(height: 26, heights: [0.4, 0.8, 0.55, 1, 0.65, 0.9, 0.45, 0.7, 0.35]),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _float(BuildContext context, AkayaPalette p, AppModel model, double w, double h) {
    final on = model.floating;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: on ? const [Color(0xFF7625EF), Color(0xFF0269F8)] : const [Color(0xFF5D5A7A), Color(0xFF3B3A58)]),
        boxShadow: [BoxShadow(color: on ? const Color(0xCC5028DC) : const Color(0x661E143C), blurRadius: 28, offset: const Offset(0, 16), spreadRadius: -14)],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(99)),
                  child: Row(children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: on ? AkayaPalette.green : const Color(0xFFAAAAAA), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(on ? 'ON' : 'OFF', style: manrope(9, Colors.white, weight: FontWeight.w800, letterSpacing: 0.6)),
                  ]),
                ),
                const Spacer(),
                AkayaToggle(on: on, onChanged: (v) {
                  model.setFloating(v);
                  model.showToast(v ? 'Floating ON · Akaya will float over your apps' : 'Floating is off');
                }),
              ],
            ),
          ),
          Positioned(left: 0, right: 0, top: 28, child: Center(child: Pearl(width: 92, height: 84, radius: 28, shadow: false, glow: 0.25, mood: on ? PearlMood.idle : PearlMood.sleeping, dark: p.dark))),
          Positioned(
            left: 13,
            bottom: 11,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Floating', style: comfortaa(15.7, Colors.white)),
              Text(on ? 'Reply on any app' : 'Tap to turn on', style: manrope(10.9, const Color(0xE6FFFFFF), weight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, AkayaPalette p, String icon, String tone, String title, String? sub, VoidCallback onTap, {double? height, bool stacked = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(11),
        decoration: glass(p, radius: 20),
        child: stacked
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Gi(icon: icon, tone: tone),
                const Spacer(),
                Text(title, style: manrope(12.8, p.text, weight: FontWeight.w800)),
                if (sub != null) Text(sub, style: manrope(10.5, p.text2, weight: FontWeight.w600)),
              ])
            : Row(children: [
                Gi(icon: icon, tone: tone),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(title, style: manrope(12.8, p.text, weight: FontWeight.w800, height: 1.2)),
                  if (sub != null) Text(sub, style: manrope(10.5, p.text2, weight: FontWeight.w600)),
                ])),
              ]),
      ),
    );
  }

  Widget _today(BuildContext context, AkayaPalette p, AppModel model) {
    final due = model.reminders.where((r) => !r.done && DateTime.fromMillisecondsSinceEpoch(r.due).day == DateTime.now().day).length;
    final cards = [
      _Td('Reminders', 'alarm', 'orange', due, 'due today', model.reminders.where((r) => !r.done).take(2).map((r) => (r.title, fmtTime(r.due))).toList(), 'Nothing due today', '/reminders'),
      _Td('Calendar', 'cal', 'blue', model.today.where((t) => t.kind == 'calendar' && !t.done).length, 'events', model.today.where((t) => t.kind == 'calendar').map((t) => (t.title, fmtTime(t.time))).toList(), 'No events today', '/home?sheet=today'),
      _Td('Follow-ups', 'follow', 'green', model.today.where((t) => t.kind == 'followup').length, 'to follow up', model.today.where((t) => t.kind == 'followup').map((t) => (t.title, fmtTime(t.time))).toList(), 'All caught up', '/home?sheet=today'),
      _Td('Medicine & water', 'pill', 'pink', 2, 'left today', const [('Take BP medicine', 'soon'), ('Drink water', 'soon')], 'Nothing scheduled', '/reminders'),
      _Td('Bills & EMI', 'wallet', 'violet', 1, 'in 30 days', const [('Pay electricity bill ₹1,240', 'today')], 'No bills due', '/reminders'),
      _Td('Birthdays & dates', 'gift', 'cyan', 1, 'coming up', const [("Priya's birthday", 'in 4 days')], 'No dates soon', '/reminders'),
      _Td('Habits & goals', 'flame', 'orange', 1, 'of 2 done today', const [('Study 1 hour', 'later')], 'Add a daily goal', '/reminders', badge: '5-day streak'),
      _Td('Future Messages', 'future', 'blue', model.future.where((m) => m.status == 'scheduled').length, 'scheduled', model.future.where((m) => m.status == 'scheduled').take(2).map((m) => ('To ${m.to}', fmtTime(m.when))).toList(), 'Nothing scheduled', '/future'),
      _Td('Missed', 'alert', 'red', model.reminders.where((r) => !r.done && r.due < DateTime.now().millisecondsSinceEpoch).length, 'missed', model.reminders.where((r) => !r.done && r.due < DateTime.now().millisecondsSinceEpoch).take(2).map((r) => (r.title, fmtTime(r.due))).toList(), 'Nothing missed', '/reminders'),
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) => _todayCard(context, p, cards[i]),
    );
  }

  Widget _todayCard(BuildContext context, AkayaPalette p, _Td c) {
    final tone = p.toneColor(c.tone);
    return GestureDetector(
      onTap: () => context.go(c.to),
      child: Container(
        width: 236,
        padding: const EdgeInsets.all(14),
        decoration: glass(p, radius: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: p.tint(c.tone), borderRadius: BorderRadius.circular(12)), child: AkayaIcon(c.icon, size: 18, color: tone)),
              const SizedBox(width: 8),
              Expanded(child: Text(c.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(12.8, p.text, weight: FontWeight.w800))),
              if (c.badge != null)
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(gradient: p.gOrange, borderRadius: BorderRadius.circular(99)), child: Text(c.badge!, style: manrope(9.3, Colors.white, weight: FontWeight.w800))),
            ]),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text('${c.count}', style: comfortaa(30, tone)),
              const SizedBox(width: 6),
              Text(c.unit, style: manrope(10.9, p.text2, weight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            if (c.items.isEmpty) Text(c.empty, style: manrope(11.8, p.text3, weight: FontWeight.w700)) else
              for (final it in c.items.take(2))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Expanded(child: Text(it.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(11.8, p.text, weight: FontWeight.w700))),
                    Text(it.$2, style: manrope(10.2, p.text3, weight: FontWeight.w700)),
                  ]),
                ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: p.tint(c.tone), borderRadius: BorderRadius.circular(99)),
              child: Text('Open', style: manrope(10.6, tone, weight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appChip(BuildContext context, AkayaPalette p, String id) {
    final name = id == 'gmail' ? 'Gmail' : id == 'google-calendar' ? 'Calendar' : 'WhatsApp';
    return GestureDetector(
      onTap: () => context.go('/apps?app=$id'),
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.only(top: 10, bottom: 8),
        decoration: glass(p, radius: 18),
        child: Column(children: [
          AppTile(id: id, size: 44),
          const SizedBox(height: 6),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(10.5, p.text2, weight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _addChip(BuildContext context, AkayaPalette p) {
    return GestureDetector(
      onTap: () => context.go('/apps'),
      child: Container(
        width: 70,
        padding: const EdgeInsets.only(top: 10, bottom: 8),
        decoration: glass(p, radius: 18),
        child: Column(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.tint('blue'), borderRadius: BorderRadius.circular(13), border: Border.all(color: AkayaPalette.blue.withValues(alpha: 0.45), width: 1.5)),
            child: AkayaIcon('plus', size: 20, color: AkayaPalette.blue, strokeWidth: 2.4),
          ),
          const SizedBox(height: 6),
          Text('Add apps', style: manrope(10.5, p.text2, weight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _features(BuildContext context) {
    const cards = [
      ('APPS', 'Connect your\napps', 'Gmail, Notion, Slack + 97 more', 'Connect apps', '/apps', [Color(0xFF06A960), Color(0xFF0DABF4)]),
      ('AGENTS', 'Daily tasks on\nautopilot', 'Morning brief, bill alerts', 'Create agent', '/home?sheet=agents', [Color(0xFF7625EF), Color(0xFF0269F8)]),
      ('EXPLORE', 'Prompts & tools', 'Discover what Akaya can do', 'Explore', '/home?sheet=explore', [Color(0xFF0DABF4), Color(0xFF0269F8)]),
      ('FINANCE', 'Instant Loan', 'Check offers and plan EMIs', 'Check now', '/home?sheet=loan', [Color(0xFFFF9A5C), Color(0xFFD9488F)]),
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final c = cards[i];
        return GestureDetector(
          onTap: () => context.go(c.$5),
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: LinearGradient(colors: c.$6), boxShadow: const [BoxShadow(color: Color(0xB3281478), blurRadius: 26, offset: Offset(0, 14), spreadRadius: -16)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.$1, style: manrope(9.6, const Color(0xE6FFFFFF), weight: FontWeight.w800, letterSpacing: 0.8)),
                const SizedBox(height: 5),
                Text(c.$2, style: comfortaa(16, Colors.white, height: 1.2)),
                const SizedBox(height: 4),
                Text(c.$3, style: manrope(11.5, const Color(0xEBFFFFFF), weight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0x38FFFFFF), borderRadius: BorderRadius.circular(99)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(c.$4, style: manrope(10.6, Colors.white, weight: FontWeight.w800)),
                    const AkayaIcon('chev', size: 12, color: Colors.white, strokeWidth: 2.6),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chats(BuildContext context, AkayaPalette p, AppModel model) {
    final chats = model.chats.where((c) => c.messages.isNotEmpty).take(3);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: glass(p, radius: 22),
      child: Column(
        children: [
          for (final c in chats)
            GestureDetector(
              onTap: () => context.go('/chat/${c.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c == chats.last ? Colors.transparent : p.line))),
                child: Row(
                  children: [
                    Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(13)), child: AkayaIcon(c.title.toLowerCase().contains('translat') ? 'translate' : c.title.toLowerCase().contains('list') ? 'note' : 'ask', size: 19, color: c.title.toLowerCase().contains('translat') ? p.greenText : AkayaPalette.violet)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.title, style: manrope(13.4, p.text, weight: FontWeight.w800)),
                      Text(c.messages.last.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(11.5, p.text2, weight: FontWeight.w600)),
                    ])),
                    Text(relDay(c.updatedAt), style: manrope(10.5, p.text3, weight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sheetBody(String s) {
    final model = AkayaScope.of(context);
    final p = paletteOf(context);
    if (s == 'notifications') {
      return Column(
        children: [
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: model.markAllRead, child: const Text('Mark all read'))),
          for (final n in model.notices)
            ListTile(
              leading: Gi(icon: n.icon, tone: 'violet', size: 36, iconSize: 16),
              title: Text(n.title, style: manrope(13.5, p.text, weight: n.read ? FontWeight.w600 : FontWeight.w800)),
              subtitle: Text(n.body, style: manrope(12, p.text2)),
            ),
        ],
      );
    }
    if (s == 'read' || s == 'read-done') return _ReadBody(startDone: s == 'read-done');
    if (s == 'today') return const _TodayBody();
    if (s == 'agents') {
      const agents = [('Morning brief', 'Every day at 8:00 AM · mails & calendar', true), ('Bill reminders', 'Nudges 2 days before due dates', true), ('Follow-up nudges', 'Reminds you of unanswered chats', false), ('Daily notes digest', 'Evening summary of your Smart Notes', false)];
      return Column(children: [
        for (final a in agents)
          ListTile(title: Text(a.$1, style: manrope(14, p.text, weight: FontWeight.w800)), subtitle: Text(a.$2, style: manrope(12, p.text2)), trailing: AkayaToggle(on: a.$3, onChanged: (_) {})),
      ]);
    }
    if (s == 'loan') return const _LoanBody();
    return const _ExploreBody();
  }
}

class _ReadBody extends StatefulWidget {
  const _ReadBody({required this.startDone});
  final bool startDone;

  @override
  State<_ReadBody> createState() => _ReadBodyState();
}

class _ReadBodyState extends State<_ReadBody> {
  late bool _done = widget.startDone;
  static const _summary = 'Electricity bill for September: ₹1,240 is due on 15 Oct. Usage is 12% lower than last month.';

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Akaya reads what's on your screen and explains it. Demo uses a sample bill.", style: manrope(13, p.text2, weight: FontWeight.w600, height: 1.4)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: glass(p, radius: 18),
          child: Column(
            children: [
              Row(children: [
                const Gi(icon: 'bolt', tone: 'orange', size: 28, iconSize: 15, radius: 8),
                const SizedBox(width: 8),
                Text('City Power Ltd.', style: manrope(14, p.text, weight: FontWeight.w800)),
              ]),
              _billRow(p, 'Bill month', 'Sep 2026', false),
              _billRow(p, 'Units used', '212 kWh', false),
              _billRow(p, 'Due date', '15 Oct 2026', _done),
              _billRow(p, 'Amount due', '₹1,240', _done),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (!_done)
          PrimaryButton(label: 'Read this screen', icon: 'read', onTap: () => setState(() => _done = true))
        else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: glass(p, radius: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Pearl(width: 40, height: 40, radius: 15, mood: PearlMood.happy, shadow: false, glow: 0.1),
                const SizedBox(width: 8),
                Text('Akaya explains', style: manrope(14, p.text, weight: FontWeight.w800)),
              ]),
              const SizedBox(height: 8),
              Text(_summary, style: manrope(13.5, p.text, weight: FontWeight.w600, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            PrimaryButton(label: 'Remind me', icon: 'alarm', onTap: () {
              AkayaScope.of(context).showToast('Reminder set for the electricity bill');
            }),
            OutlineButton(label: 'Copy', onTap: () {
              AkayaScope.of(context).showToast('Summary copied');
            }),
            OutlineButton(label: 'Ask more', onTap: () => context.go('/chat')),
          ]),
        ],
      ],
    );
  }

  Widget _billRow(AkayaPalette p, String k, String v, bool hl) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: hl ? p.tint('violet') : Colors.transparent, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Expanded(child: Text(k, style: manrope(12.5, p.text2, weight: FontWeight.w600))),
        Text(v, style: manrope(13.5, p.text, weight: FontWeight.w800)),
      ]),
    );
  }
}

class _TodayBody extends StatelessWidget {
  const _TodayBody();

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final items = [...model.today]..sort((a, b) => (a.done ? 1 : 0).compareTo(b.done ? 1 : 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Segmented(full: true, value: 'all', onChanged: (_) {}, options: const [('all', Text('All')), ('calendar', Text('Calendar')), ('followup', Text('Follow-ups'))]),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => context.go('/reminders'),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: glass(p, radius: 16),
            child: Row(children: [
              const Gi(icon: 'alarm', tone: 'orange', size: 36, iconSize: 16),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Reminders', style: manrope(14, p.text, weight: FontWeight.w800)),
                Text('Open the reminders dashboard', style: manrope(12, p.text2)),
              ])),
              AkayaIcon('chev', size: 16, color: p.text3),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        for (final t in items)
          GestureDetector(
            onTap: () => model.toggleToday(t.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: glass(p, radius: 16),
              child: Row(children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t.done ? p.greenText : p.lineStrong, width: 1.6), color: t.done ? p.tint('green') : Colors.transparent),
                  child: t.done ? AkayaIcon('check', size: 12, color: p.greenText, strokeWidth: 3) : null,
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.title, style: manrope(13.5, p.text, weight: FontWeight.w800)),
                  Text('${t.kind == 'followup' ? 'Follow-up' : 'Event'} · ${fmtTime(t.time)}', style: manrope(12, p.text2)),
                ])),
                Gi(icon: t.kind == 'followup' ? 'follow' : 'cal', tone: t.kind == 'followup' ? 'green' : 'blue', size: 32, iconSize: 15),
              ]),
            ),
          ),
      ],
    );
  }
}

class _ExploreBody extends StatelessWidget {
  const _ExploreBody();
  static const _prompts = [
    ('Write', 'edit', 'violet', 'Write a polite leave request for Friday'),
    ('Plan', 'cal', 'blue', 'Plan a 3-day Goa trip under ₹15k'),
    ('Translate', 'translate', 'green', 'Translate "See you tomorrow at 6" to Hindi'),
    ('Learn', 'explore', 'cyan', 'Explain mutual funds in simple words'),
    ('Summarise', 'note', 'orange', 'Summarise my day'),
    ('Remind', 'alarm', 'pink', 'Remind me to drink water every 2 hours'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tap a prompt to try it in chat.', style: manrope(13, p.text2, weight: FontWeight.w600)),
        const SizedBox(height: 10),
        for (final x in _prompts)
          GestureDetector(
            onTap: () => context.go('/chat'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: glass(p, radius: 16),
              child: Row(children: [
                Gi(icon: x.$2, tone: x.$3, size: 34, iconSize: 16, radius: 11),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(x.$1, style: manrope(11, p.text3, weight: FontWeight.w700)),
                  Text(x.$4, style: manrope(13, p.text, weight: FontWeight.w800)),
                ])),
              ]),
            ),
          ),
      ],
    );
  }
}

class _LoanBody extends StatefulWidget {
  const _LoanBody();

  @override
  State<_LoanBody> createState() => _LoanBodyState();
}

class _LoanBodyState extends State<_LoanBody> {
  double _amt = 100000;
  double _months = 12;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    const rate = 14.0;
    final r = rate / 12 / 100;
    final n = _months;
    final emi = (_amt * r * _pow(1 + r, n)) / (_pow(1 + r, n) - 1);
    final interest = emi * n - _amt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Plan your EMI before you check offers.', style: manrope(13, p.text2, weight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(gradient: p.brand, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Estimated monthly EMI', style: manrope(12, const Color(0xE6FFFFFF), weight: FontWeight.w700)),
            Text(inr(emi), style: comfortaa(28, Colors.white)),
            Text('Total interest ${inr(interest)} · 14% p.a. (illustrative)', style: manrope(12, const Color(0xE6FFFFFF), weight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 12),
        Text('Loan amount  ${inr(_amt)}', style: manrope(13, p.text, weight: FontWeight.w800)),
        Slider(value: _amt, min: 10000, max: 500000, divisions: 98, activeColor: AkayaPalette.violet, onChanged: (v) => setState(() => _amt = (v / 5000).round() * 5000)),
        Text('Tenure  ${_months.round()} months', style: manrope(13, p.text, weight: FontWeight.w800)),
        Slider(value: _months, min: 3, max: 36, divisions: 11, activeColor: AkayaPalette.violet, onChanged: (v) => setState(() => _months = (v / 3).round() * 3)),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Check my offers', icon: 'chev', onTap: () => AkayaScope.of(context).showToast('Demo: partner offers appear here in the live app')),
        const SizedBox(height: 8),
        Text('Final rate and eligibility are set by the lending partner.', style: manrope(12, p.text3, weight: FontWeight.w600)),
      ],
    );
  }

  double _pow(double b, double e) {
    var r = 1.0;
    for (var i = 0; i < e.round(); i++) {
      r *= b;
    }
    return r;
  }
}

class _Td {
  _Td(this.label, this.icon, this.tone, this.count, this.unit, this.items, this.empty, this.to, {this.badge});
  final String label, icon, tone, unit, empty, to;
  final int count;
  final List<(String, String)> items;
  final String? badge;
}
