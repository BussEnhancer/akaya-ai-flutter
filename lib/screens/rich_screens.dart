import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../state/model.dart';
import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/chrome.dart';
import '../widgets/anim_clock.dart';
import '../widgets/mind_map.dart';
import '../widgets/pearl.dart';
import 'feature_screens.dart' show inr;

class _HItem {
  _HItem({
    required this.key,
    required this.type,
    required this.title,
    required this.preview,
    required this.at,
    required this.icon,
    required this.tone,
    required this.tag,
    this.meta,
    this.to,
    this.input,
    this.output,
  });
  final String key, type, title, preview, icon, tone, tag;
  final int at;
  final String? meta, to, input, output;
}

List<_HItem> _history(AppModel m) {
  final out = <_HItem>[
    for (final c in m.chats)
      if (c.messages.isNotEmpty)
        _HItem(
          key: 'chat:${c.id}',
          type: 'chat',
          title: c.title,
          preview: c.messages.first.text,
          at: c.updatedAt,
          icon: 'ask',
          tone: 'violet',
          tag: 'AI Chat',
          meta: '${c.messages.length} messages',
          to: '/chat/${c.id}',
          input: c.messages.firstWhere((x) => x.from == 'me', orElse: () => c.messages.first).text,
          output: c.messages.last.text,
        ),
    for (final a in m.activity)
      _HItem(
        key: 'act:${a.kind}:${a.at}',
        type: a.kind,
        title: a.title,
        preview: a.kind == 'floating' || a.kind == 'translation' ? a.output : a.input,
        at: a.at,
        icon: a.kind == 'voice' ? 'mic' : (a.kind == 'floating' ? 'float' : 'translate'),
        tone: a.kind == 'voice' ? 'blue' : (a.kind == 'floating' ? 'cyan' : 'green'),
        tag: a.kind == 'voice' ? 'Voice Chat' : (a.kind == 'floating' ? 'Floating' : 'Translation'),
        meta: a.app ?? a.langs,
        input: a.input,
        output: a.output,
      ),
    for (final n in m.notes)
      _HItem(key: 'note:${n.id}', type: 'note', title: 'Smart Note', preview: n.text, at: n.createdAt, icon: 'note', tone: 'pink', tag: 'Smart Note', to: '/notes', input: n.text, output: n.text),
    for (final f in m.future)
      _HItem(key: 'fm:${f.id}', type: 'future', title: 'To ${f.to}', preview: f.text, at: f.createdAt, icon: 'future', tone: 'violet', tag: 'Future Message', meta: f.status, to: '/future', input: f.text, output: 'Scheduled for ${fmtTime(f.when)}'),
    for (final v in m.voiceNotes)
      _HItem(key: 'vn:${v.id}', type: 'vnote', title: v.title, preview: '${v.mode} · ${v.subject}', at: v.createdAt, icon: 'wave', tone: 'orange', tag: 'Voice Note', meta: '${(v.duration / 60).floor()} min', to: '/vnotes/${v.id}'),
    for (final id in m.connected.keys)
      _HItem(key: 'app:$id', type: 'app', title: id, preview: m.connected[id]!, at: DateTime.now().millisecondsSinceEpoch - 86400000, icon: 'plug', tone: 'blue', tag: 'App connected', to: '/apps'),
  ];
  out.removeWhere((i) => m.hiddenHistory.contains(i.key));
  return out;
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.filter, this.query, this.openMenu = false, this.openDetail = false, this.jumpEnd = false});
  final String? filter;
  final String? query;
  final bool openMenu;
  final bool openDetail;
  final bool jumpEnd;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all';
  String _sort = 'new';
  String _range = 'all';
  String _q = '';
  String? _menu;
  final _search = TextEditingController();
  final _chips = ScrollController();

  @override
  void initState() {
    super.initState();
    final f = widget.filter;
    if (f != null && f.isNotEmpty) _filter = f;
    final q = widget.query;
    if (q != null && q.isNotEmpty) {
      _q = q.trim().toLowerCase();
      _search.text = q;
    }
    const order = ['all', 'chat', 'voice', 'vnote', 'floating', 'translation', 'note', 'future', 'app'];
    final chip = order.indexOf(_filter);
    if (chip > 2) _reveal(_chips, chip, 72);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.openMenu && !widget.openDetail) return;
      final items = _visible(AkayaScope.of(context));
      if (items.isEmpty) return;
      if (widget.openDetail) {
        _open(context, items.first);
      } else {
        setState(() => _menu = items.first.key);
      }
    });
  }

  void _reveal(ScrollController c, int index, double pitch, [int n = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !c.hasClients) return;
      final max = c.position.maxScrollExtent;
      if (max <= 0 && n < 6) {
        _reveal(c, index, pitch, n + 1);
        return;
      }
      c.jumpTo((index * pitch - 70).clamp(0, max));
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _chips.dispose();
    super.dispose();
  }

  List<_HItem> _visible(AppModel model) {
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final items = _history(model).where((i) {
      if (_filter != 'all' && i.type != _filter) return false;
      if (_range == 'today' && i.at < startToday) return false;
      if (_range == '7d' && i.at < startToday - 6 * 86400000) return false;
      final blob = '${i.title} ${i.preview} ${i.meta ?? ''} ${i.tag}'.toLowerCase();
      return _q.isEmpty || blob.contains(_q);
    }).toList();
    items.sort((a, b) => _sort == 'new' ? b.at.compareTo(a.at) : a.at.compareTo(b.at));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final items = _visible(model);
    final pinned = items.where((i) => model.pinnedHistory.contains(i.key)).toList();
    final rest = items.where((i) => !model.pinnedHistory.contains(i.key)).toList();
    String group(int at) {
      if (at >= startToday) return 'Today';
      if (at >= startToday - 86400000) return 'Yesterday';
      return 'Earlier';
    }

    final sections = <(String, List<_HItem>)>[
      if (pinned.isNotEmpty) ('Pinned', pinned),
      for (final g in _sort == 'new' ? ['Today', 'Yesterday', 'Earlier'] : ['Earlier', 'Yesterday', 'Today'])
        if (rest.where((i) => group(i.at) == g).isNotEmpty) (g, rest.where((i) => group(i.at) == g).toList()),
    ];
    const filters = [('all', 'All'), ('chat', 'Chat'), ('voice', 'Voice'), ('vnote', 'Notes'), ('floating', 'Floating'), ('translation', 'Translate'), ('note', 'Smart'), ('future', 'Future'), ('app', 'Apps')];
    return AkayaScreen(
      jumpEnd: widget.jumpEnd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            title: 'History',
            sub: 'Everything you did with Akaya',
            trailing: AkayaIconButton(
              icon: 'filter',
              label: 'Filter',
              onTap: () => showAkayaSheet(
                context,
                title: 'Filter',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Sort', style: manrope(12, p.text2, weight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Segmented(full: true, value: _sort, onChanged: (v) => setState(() => _sort = v), options: const [('new', Text('Newest first')), ('old', Text('Oldest first'))]),
                    const SizedBox(height: 14),
                    Text('Time', style: manrope(12, p.text2, weight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Segmented(full: true, value: _range, onChanged: (v) => setState(() => _range = v), options: const [('all', Text('All time')), ('today', Text('Today')), ('7d', Text('Last 7 days'))]),
                    const SizedBox(height: 16),
                    PrimaryButton(label: 'Show ${items.length} results', onTap: () => Navigator.pop(context)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p, radius: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  AkayaIcon('search', size: 17, color: p.text3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _search,
                      style: manrope(14, p.text),
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'Search history', hintStyle: manrope(14, p.text3)),
                      onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              controller: _chips,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final c in filters)
                  GestureDetector(
                    onTap: () => setState(() => _filter = c.$1),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: _filter == c.$1 ? p.brand : null,
                        color: _filter == c.$1 ? null : p.surface,
                        borderRadius: BorderRadius.circular(99),
                        border: _filter == c.$1 ? null : Border.all(color: p.line),
                      ),
                      child: Text(c.$2, style: manrope(12, _filter == c.$1 ? Colors.white : p.text2, weight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          if (sections.isEmpty)
            Padding(padding: const EdgeInsets.all(28), child: Text(_q.isEmpty ? 'Try another filter.' : 'No results for “$_q”.', textAlign: TextAlign.center, style: manrope(13, p.text2)))
          else
            for (final s in sections) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Row(children: [
                  if (s.$1 == 'Pinned') ...[AkayaIcon('pin', size: 13, color: p.violetText), const SizedBox(width: 4)],
                  Text(s.$1, style: manrope(12, p.text3, weight: FontWeight.w800)),
                ]),
              ),
              for (final it in s.$2) _card(context, p, model, it),
            ],
          if (sections.isNotEmpty) Padding(padding: const EdgeInsets.all(16), child: Text("— That's all for now —", textAlign: TextAlign.center, style: manrope(12, p.text3))),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, AkayaPalette p, AppModel model, _HItem it) {
    final pinned = model.pinnedHistory.contains(it.key);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        decoration: glass(p, radius: 16),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _open(context, it),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Gi(icon: it.icon, tone: it.tone, size: 44, iconSize: 20, radius: 14),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(child: Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(13.5, p.text, weight: FontWeight.w800))),
                                  Text(relDay(it.at), style: manrope(11, p.text3)),
                                ]),
                                Text(it.preview, maxLines: 2, overflow: TextOverflow.ellipsis, style: manrope(12, p.text2, weight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(color: p.tint(it.tone), borderRadius: BorderRadius.circular(99)),
                                    child: Text(it.tag, style: manrope(10, p.toneColor(it.tone), weight: FontWeight.w800)),
                                  ),
                                  if (it.meta != null) ...[const SizedBox(width: 6), Text(it.meta!, style: manrope(11, p.text3))],
                                  if (pinned) ...[const SizedBox(width: 6), AkayaIcon('pin', size: 12, color: p.violetText)],
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _menu = _menu == it.key ? null : it.key),
                  child: Padding(padding: const EdgeInsets.all(10), child: AkayaIcon('dots', size: 18, color: p.text3)),
                ),
              ],
            ),
            if (_menu == it.key)
              Positioned(
                right: 8,
                top: 36,
                child: Material(
                  color: p.surfaceSolid,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
                    child: Column(
                      children: [
                        _menuItem(p, 'open', 'Open', () => _open(context, it)),
                        _menuItem(p, 'pin', pinned ? 'Unpin' : 'Pin to top', () {
                          model.toggleHistoryPin(it.key);
                          model.showToast(pinned ? 'Unpinned' : 'Pinned to top');
                          setState(() => _menu = null);
                        }),
                        _menuItem(p, 'trash', 'Delete', () {
                          model.hideHistory(it.key);
                          model.showToast('Removed from history');
                          setState(() => _menu = null);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(AkayaPalette p, String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [AkayaIcon(icon, size: 16, color: p.text), const SizedBox(width: 8), Text(label, style: manrope(13, p.text, weight: FontWeight.w700))]),
      ),
    );
  }

  void _open(BuildContext context, _HItem it) {
    setState(() => _menu = null);
    if (it.input != null && it.output != null && (it.type == 'voice' || it.type == 'floating' || it.type == 'translation' || it.type == 'chat')) {
      final p = paletteOf(context);
      showAkayaSheet(
        context,
        title: it.title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(it.tag, style: manrope(12, p.violetText, weight: FontWeight.w800)),
            const SizedBox(height: 10),
            _bubble(p, it.type == 'translation' ? 'Original' : 'You said', it.input!, false),
            const SizedBox(height: 8),
            _bubble(p, it.type == 'translation' ? 'Translation' : 'Akaya', it.output!, true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlineButton(label: 'Copy', onTap: () {
                  Clipboard.setData(ClipboardData(text: it.output!));
                  AkayaScope.of(context).showToast('Copied');
                })),
                const SizedBox(width: 8),
                Expanded(child: PrimaryButton(label: it.type == 'translation' ? 'Open' : 'Ask again', onTap: () {
                  Navigator.pop(context);
                  context.go(it.type == 'translation' ? '/translate' : '/chat');
                })),
              ],
            ),
          ],
        ),
      );
      return;
    }
    if (it.to != null) context.go(it.to!);
  }

  Widget _bubble(AkayaPalette p, String label, String text, bool ai) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: ai ? p.tint('violet') : p.surface2, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: manrope(11, p.text3, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(text, style: manrope(13.5, p.text, weight: FontWeight.w600, height: 1.4)),
      ]),
    );
  }
}

const _channels = [
  ('whatsapp', 'WhatsApp', 'msg'),
  ('gmail', 'Gmail', 'msg'),
  ('slack', 'Slack', 'msg'),
  ('outlook', 'Outlook', 'msg'),
  ('linkedin', 'LinkedIn', 'post'),
  ('instagram', 'Instagram', 'post'),
];

class FutureScreen extends StatefulWidget {
  const FutureScreen({super.key});

  @override
  State<FutureScreen> createState() => _FutureScreenState();
}

class _FutureScreenState extends State<FutureScreen> {
  String _tab = 'queue';

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final queue = model.future.where((m) => m.status != 'sent').toList();
    final sent = model.future.where((m) => m.status == 'sent').toList();
    final list = _tab == 'sent' ? sent : queue;
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Future Message', sub: 'Write now · Akaya sends it later'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _compose(context, null),
              child: Container(
                decoration: glass(p),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(gradient: p.brand, borderRadius: BorderRadius.circular(14)), child: const AkayaIcon('plus', size: 20, color: Colors.white, strokeWidth: 2.6)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('New message or post', style: manrope(14, p.text, weight: FontWeight.w800)),
                      Text('WhatsApp, Gmail, Slack, Instagram, LinkedIn, X and more', style: manrope(11.5, p.text2, weight: FontWeight.w600)),
                    ])),
                    for (final id in ['whatsapp', 'gmail', 'slack', 'linkedin']) ...[AppTile(id: id, size: 22), const SizedBox(width: 3)],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Segmented(
              full: true,
              value: _tab,
              onChanged: (v) => setState(() => _tab = v),
              options: [('queue', Text('Queue · ${queue.length}')), ('sent', Text('Sent · ${sent.length}'))],
            ),
          ),
          for (final m in list)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: GestureDetector(
                onTap: () => _compose(context, m),
                child: Container(
                  decoration: glass(p, radius: 18),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        for (final c in m.channels.take(3)) ...[AppTile(id: c == 'x' ? 'gmail' : c, size: 22), const SizedBox(width: 4)],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: p.tint(m.status == 'sent' ? 'green' : 'blue'), borderRadius: BorderRadius.circular(99)),
                          child: Text(m.status == 'sent' ? 'Sent' : 'Scheduled', style: manrope(11, m.status == 'sent' ? p.greenText : AkayaPalette.blue, weight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text('To ${m.to}', style: manrope(13.5, p.text, weight: FontWeight.w800)),
                      if (m.subject != null) Text(m.subject!, style: manrope(12, p.text2, weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(m.text, style: manrope(13, p.text2, weight: FontWeight.w600, height: 1.4)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Text(m.repeat == 'once' ? fmtTime(m.when) : '${m.repeat} · ${fmtTime(m.when)}', style: manrope(11.5, p.text3, weight: FontWeight.w600)),
                        const Spacer(),
                        if (m.status != 'sent') ...[
                          GestureDetector(onTap: () => model.sendFutureNow(m.id), child: Text('Send now', style: manrope(12, AkayaPalette.blue, weight: FontWeight.w800))),
                          const SizedBox(width: 10),
                          GestureDetector(onTap: () => _compose(context, m), child: Text('Edit', style: manrope(12, p.text, weight: FontWeight.w800))),
                          const SizedBox(width: 10),
                          GestureDetector(onTap: () => model.cancelFuture(m.id), child: Text('Cancel', style: manrope(12, p.orangeText, weight: FontWeight.w800))),
                        ],
                      ]),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _compose(BuildContext context, FutureItem? existing) {
    final to = TextEditingController(text: existing?.to ?? 'Neha');
    final text = TextEditingController(text: existing?.text ?? '');
    final subject = TextEditingController(text: existing?.subject ?? '');
    var channels = List<String>.from(existing?.channels ?? ['whatsapp']);
    var repeat = existing?.repeat ?? 'once';
    var when = existing?.when ?? DateTime.now().millisecondsSinceEpoch + 3600000;
    showAkayaSheet(
      context,
      title: existing == null ? 'New message' : 'Edit message',
      child: StatefulBuilder(
        builder: (context, setLocal) {
          final p = paletteOf(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Channel', style: manrope(12, p.text3, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final c in _channels)
                  GestureDetector(
                    onTap: () => setLocal(() {
                      if (channels.contains(c.$1)) {
                        channels.remove(c.$1);
                      } else {
                        channels.add(c.$1);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: channels.contains(c.$1) ? p.tint('violet') : p.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: channels.contains(c.$1) ? p.violetText : p.line),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [AppTile(id: c.$1, size: 18), const SizedBox(width: 4), Text(c.$2, style: manrope(12, p.text, weight: FontWeight.w700))]),
                    ),
                  ),
              ]),
              const SizedBox(height: 8),
              TextField(controller: to, style: manrope(14, p.text), decoration: InputDecoration(labelText: 'To', labelStyle: manrope(12, p.text3))),
              TextField(controller: subject, style: manrope(14, p.text), decoration: InputDecoration(labelText: 'Subject (email)', labelStyle: manrope(12, p.text3))),
              TextField(controller: text, maxLines: 3, style: manrope(14, p.text), decoration: InputDecoration(labelText: 'Message', labelStyle: manrope(12, p.text3))),
              const SizedBox(height: 8),
              Segmented(
                full: true,
                value: repeat,
                onChanged: (v) => setLocal(() => repeat = v),
                options: const [('once', Text('Once')), ('daily', Text('Daily')), ('yearly', Text('Yearly'))],
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                for (final q in [('In 1 min', 60000), ('Tonight 9 PM', 0), ('Tomorrow 9 AM', 86400000)])
                  GestureDetector(
                    onTap: () {
                      final n = DateTime.now();
                      if (q.$1.startsWith('Tonight')) {
                        when = DateTime(n.year, n.month, n.day, 21).millisecondsSinceEpoch;
                      } else if (q.$2 == 86400000) {
                        final t = n.add(const Duration(days: 1));
                        when = DateTime(t.year, t.month, t.day, 9).millisecondsSinceEpoch;
                      } else {
                        when = DateTime.now().millisecondsSinceEpoch + q.$2;
                      }
                      setLocal(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(99)),
                      child: Text(q.$1, style: manrope(12, p.text, weight: FontWeight.w700)),
                    ),
                  ),
              ]),
              const SizedBox(height: 6),
              Text(fmtTime(when), style: manrope(12, p.text2)),
              const SizedBox(height: 12),
              PrimaryButton(
                label: existing == null ? 'Schedule' : 'Save changes',
                onTap: () {
                  if (text.text.trim().isEmpty || channels.isEmpty || to.text.trim().isEmpty) {
                    AkayaScope.of(context).showToast('Add a recipient, channel and message');
                    return;
                  }
                  AkayaScope.of(context).scheduleFuture(id: existing?.id, to: to.text.trim(), text: text.text.trim(), when: when, channels: channels, repeat: repeat, subject: subject.text.trim().isEmpty ? null : subject.text.trim());
                  AkayaScope.of(context).showToast(existing == null ? 'Scheduled' : 'Changes saved');
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

String _iso(DateTime d) => '${d.month}/${d.day}/${d.year}';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  String _tab = 'hotel';
  late final _city = TextEditingController(text: 'North Goa');
  late final _in = TextEditingController(text: _iso(DateTime.now().add(const Duration(days: 14))));
  late final _out = TextEditingController(text: _iso(DateTime.now().add(const Duration(days: 17))));
  late final _from = TextEditingController(text: 'DEL');
  late final _to = TextEditingController(text: 'GOI');
  late final _date = TextEditingController(text: _iso(DateTime.now().add(const Duration(days: 14))));
  late final _what = TextEditingController(text: 'Goa');
  bool _searched = false;

  @override
  void dispose() {
    for (final c in [_city, _in, _out, _from, _to, _date, _what]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Travel & Stays', sub: 'Hotels, flights and things to do'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Segmented(
              full: true,
              value: _tab,
              onChanged: (v) => setState(() => _tab = v),
              options: const [
                ('hotel', Row(mainAxisAlignment: MainAxisAlignment.center, children: [AkayaIcon('bed', size: 14), SizedBox(width: 4), Text('Stays')])),
                ('flight', Row(mainAxisAlignment: MainAxisAlignment.center, children: [AkayaIcon('plane', size: 14), SizedBox(width: 4), Text('Flights')])),
                ('experience', Row(mainAxisAlignment: MainAxisAlignment.center, children: [AkayaIcon('ticket', size: 14), SizedBox(width: 4), Text('Things to do')])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: glass(p),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (_tab == 'hotel') ...[
                    _field(p, 'Destination', _city),
                    Row(children: [Expanded(child: _field(p, 'Check-in', _in)), const SizedBox(width: 8), Expanded(child: _field(p, 'Check-out', _out))]),
                  ] else if (_tab == 'flight') ...[
                    Row(children: [Expanded(child: _field(p, 'From', _from)), const SizedBox(width: 8), Expanded(child: _field(p, 'To', _to))]),
                    _field(p, 'Date', _date),
                  ] else
                    _field(p, 'Where', _what),
                  const SizedBox(height: 8),
                  PrimaryButton(label: _tab == 'hotel' ? 'Search stays' : (_tab == 'flight' ? 'Search flights' : 'Search'), onTap: () => setState(() => _searched = true)),
                ],
              ),
            ),
          ),
          if (_searched) ...[
            Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 8), child: Text('Sample results · booking opens the partner site', style: manrope(11.5, p.text3, weight: FontWeight.w600))),
            if (_tab == 'hotel') ...[
              _offer(context, p, 'Sea Breeze Resort', '${_city.text} · 300 m to beach', 'agoda', 5980, 'https://www.agoda.com/search?city=${Uri.encodeComponent(_city.text)}&checkIn=${_in.text}&checkOut=${_out.text}'),
              _offer(context, p, 'Palm Grove Villas', 'Anjuna · private pool', 'booking', 8760, 'https://www.booking.com/searchresults.html?ss=${Uri.encodeComponent(_city.text)}&checkin=${_in.text}&checkout=${_out.text}'),
              _offer(context, p, 'Fort View Hostel', 'Candolim · near Fort Aguada', 'makemytrip', 1390, 'https://www.makemytrip.com/hotels/'),
            ] else if (_tab == 'flight') ...[
              _offer(context, p, 'IndiGo 6E 2041', '${_from.text} ${_date.text} 06:10 → ${_to.text} 08:45', 'cleartrip', 5199, 'https://www.cleartrip.com/flights/results?from=${_from.text}&to=${_to.text}&depart=${_date.text}'),
              _offer(context, p, 'Air India AI 883', '10:55 → 13:35 · Non-stop', 'skyscanner', 6420, 'https://www.skyscanner.co.in/'),
              _offer(context, p, 'Akasa Air QP 1305', '17:20 → 19:55 · Non-stop', 'goibibo', 4890, 'https://www.goibibo.com/flights/'),
            ] else ...[
              _offer(context, p, 'Dudhsagar Falls jeep safari', '${_what.text} · Full day · 4.6', 'klook', 2499, 'https://www.klook.com/search/?query=${Uri.encodeComponent(_what.text)}'),
              _offer(context, p, 'Mandovi river sunset cruise', '1.5 hours · 4.4', 'tripadvisor', 899, 'https://www.tripadvisor.com/Search?q=${Uri.encodeComponent(_what.text)}'),
              _offer(context, p, 'Old Goa churches heritage walk', '3 hours · 4.7', 'getyourguide', 1200, 'https://www.getyourguide.com/s/?q=${Uri.encodeComponent(_what.text)}'),
            ],
          ],
        ],
      ),
    );
  }

  Widget _field(AkayaPalette p, String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: manrope(11, p.text3, weight: FontWeight.w700)),
        TextField(controller: c, style: manrope(14, p.text, weight: FontWeight.w700), decoration: const InputDecoration(isDense: true, border: InputBorder.none)),
      ]),
    );
  }

  Widget _offer(BuildContext context, AkayaPalette p, String title, String meta, String platform, int price, String url) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        decoration: glass(p, radius: 18),
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: manrope(15, p.text, weight: FontWeight.w800)),
          Text(meta, style: manrope(12, p.text2)),
          const SizedBox(height: 6),
          Row(children: [
            Text(inr(price), style: manrope(16, p.violetText, weight: FontWeight.w800)),
            const Spacer(),
            GestureDetector(
              onTap: () => _link(context, platform, url),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(gradient: p.brand, borderRadius: BorderRadius.circular(12)),
                child: Text('Open', style: manrope(12, Colors.white, weight: FontWeight.w800)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _link(BuildContext context, String platform, String url) {
    final p = paletteOf(context);
    showAkayaSheet(
      context,
      title: 'Open in $platform',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Demo link. Akaya does not book or pay.', style: manrope(13, p.text2, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        SelectableText(url, style: manrope(12, p.text, weight: FontWeight.w600)),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Copy link', onTap: () {
          Clipboard.setData(ClipboardData(text: url));
          AkayaScope.of(context).showToast('Link copied');
          Navigator.pop(context);
        }),
      ]),
    );
  }
}

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  String _cat = 'all';
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _open(String platform, String q) {
    final host = {
      'amazon': 'https://www.amazon.in/s?k=',
      'flipkart': 'https://www.flipkart.com/search?q=',
      'myntra': 'https://www.myntra.com/',
      'ajio': 'https://www.ajio.com/search/?text=',
      'nykaa': 'https://www.nykaa.com/search/result/?q=',
    };
    final url = '${host[platform] ?? 'https://www.google.com/search?q='}${Uri.encodeComponent(q)}';
    final p = paletteOf(context);
    showAkayaSheet(
      context,
      title: 'Buy on $platform',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Sample link for “$q”. You check out in $platform.', style: manrope(13, p.text2, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        SelectableText(url, style: manrope(12, p.text)),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Copy link', onTap: () {
          Clipboard.setData(ClipboardData(text: url));
          AkayaScope.of(context).showToast('Opens $platform (demo)');
          Navigator.pop(context);
        }),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    const stores = ['amazon', 'flipkart', 'myntra', 'ajio', 'nykaa'];
    const deals = [
      ('🎧', 'boAt Rockerz 450 Bluetooth headphones', 'amazon', 'electronics', 1499, 3990, 4.1, 'boAt Rockerz 450'),
      ('📱', 'Redmi 13C 5G (4 GB / 128 GB)', 'flipkart', 'electronics', 9499, 13999, 4.2, 'Redmi 13C 5G'),
      ('👖', "Levi's 511 slim fit jeans", 'myntra', 'fashion', 1799, 3599, 4.3, 'levis 511 slim jeans'),
      ('👟', 'Puma Smash v2 sneakers', 'ajio', 'fashion', 2199, 4999, 4.2, 'puma smash v2'),
      ('💄', 'Lakmé 9to5 primer + matte foundation', 'nykaa', 'beauty', 399, 650, 4.4, 'lakme 9to5 primer matte'),
      ('🍟', 'Philips 4.1 L air fryer', 'amazon', 'home', 6999, 9995, 4.3, 'Philips air fryer'),
      ('🥤', 'Prestige Iris 750 W mixer grinder', 'flipkart', 'home', 3149, 5795, 4.2, 'Prestige Iris mixer'),
    ];
    final shown = deals.where((d) => _cat == 'all' || d.$4 == _cat).toList();
    final q = _q.text.trim();
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Shopping & Deals', sub: "Search stores · today's deals"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p, radius: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                AkayaIcon('search', size: 18, color: p.text3),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _q, style: manrope(14, p.text), decoration: InputDecoration(border: InputBorder.none, hintText: 'What do you want to buy?', hintStyle: manrope(14, p.text3)), onChanged: (_) => setState(() {}))),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 78,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final s in stores)
                  GestureDetector(
                    onTap: q.isEmpty ? null : () => _open(s, q),
                    child: Opacity(
                      opacity: q.isEmpty ? 0.45 : 1,
                      child: Container(
                        width: 72,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: glass(p, radius: 16),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [AppTile(id: s, size: 30), const SizedBox(height: 4), Text(s, style: manrope(10, p.text2, weight: FontWeight.w700))]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 4), child: Text(q.isEmpty ? 'Type a product, then pick a store.' : 'Tap a store to see results there.', style: manrope(11.5, p.text3))),
          Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 8), child: Row(children: [Text("Today's deals", style: comfortaa(16, p.text)), const Spacer(), Text('SAMPLE PRICES', style: manrope(10, p.orangeText, weight: FontWeight.w800))])),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final c in [('all', 'All'), ('electronics', 'Electronics'), ('fashion', 'Fashion'), ('beauty', 'Beauty'), ('home', 'Home')])
                  GestureDetector(
                    onTap: () => setState(() => _cat = c.$1),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(gradient: _cat == c.$1 ? p.brand : null, color: _cat == c.$1 ? null : p.surface, borderRadius: BorderRadius.circular(99), border: Border.all(color: _cat == c.$1 ? Colors.transparent : p.line)),
                      child: Text(c.$2, style: manrope(12, _cat == c.$1 ? Colors.white : p.text2, weight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final d in shown)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                decoration: glass(p, radius: 18),
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Text(d.$1, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.$2, style: manrope(13.5, p.text, weight: FontWeight.w800)),
                    Text('${d.$3} · ★ ${d.$7}', style: manrope(11.5, p.text2, weight: FontWeight.w600)),
                    Row(children: [
                      Text(inr(d.$5), style: manrope(14, p.text, weight: FontWeight.w800)),
                      const SizedBox(width: 6),
                      Text(inr(d.$6), style: manrope(12, p.text3).copyWith(decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 6),
                      Text('${(((d.$6 - d.$5) / d.$6) * 100).round()}% off', style: manrope(12, p.greenText, weight: FontWeight.w800)),
                    ]),
                  ])),
                  GestureDetector(
                    onTap: () => _open(d.$3, d.$8),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), decoration: BoxDecoration(gradient: p.gOrange, borderRadius: BorderRadius.circular(12)), child: const AkayaIcon('external', size: 16, color: Colors.white)),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _period = '30';

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final k = _period == '7' ? 0.24 : (_period == '90' ? 2.9 : 1.0);
    const base = [
      ('amazon', 'Amazon', 1840, 64, 1450, 0.035),
      ('flipkart', 'Flipkart', 1220, 41, 2100, 0.03),
      ('booking', 'Booking', 410, 9, 14800, 0.04),
      ('makemytrip', 'MakeMyTrip', 360, 11, 9200, 0.025),
      ('myntra', 'Myntra', 520, 23, 1700, 0.06),
      ('agoda', 'Agoda', 190, 4, 11200, 0.045),
      ('nykaa', 'Nykaa', 300, 17, 900, 0.07),
      ('klook', 'Klook', 120, 5, 2300, 0.05),
      ('swiggy', 'Swiggy', 640, 0, 0, 0.0),
      ('uber', 'Uber', 230, 0, 0, 0.0),
    ];
    var clicks = 0, orders = 0;
    var commission = 0.0, pending = 0.0;
    final rows = <(String, String, int, int, double)>[];
    for (final b in base) {
      final c = (b.$3 * k).round();
      final o = (b.$4 * k).round();
      final pendingOrders = (o * 0.3).round();
      final comm = o * b.$5 * b.$6;
      final pend = pendingOrders * b.$5 * b.$6;
      clicks += c;
      orders += o;
      commission += comm;
      pending += pend;
      rows.add((b.$1, b.$2, c, o, comm));
    }
    final stats = [('Clicks', '$clicks', 'blue'), ('Orders', '$orders', 'violet'), ('Commission', inr(commission), 'green'), ('Pending', inr(pending), 'orange')];
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Earnings', sub: 'Affiliate clicks, orders and commission'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p, radius: 16),
              padding: const EdgeInsets.all(12),
              child: Text('Sample data. Live numbers come from the link-redirect service (GET /reports, admin only). Amounts in ₹, IST.', style: manrope(12.5, p.text2, weight: FontWeight.w600, height: 1.4)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Segmented(full: true, value: _period, onChanged: (v) => setState(() => _period = v), options: const [('7', Text('7 days')), ('30', Text('30 days')), ('90', Text('90 days'))]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.1,
              children: [
                for (final s in stats)
                  Container(
                    decoration: glass(p, radius: 16),
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.$1, style: manrope(11.5, p.text3, weight: FontWeight.w700)),
                      Text(s.$2, style: manrope(18, p.toneColor(s.$3), weight: FontWeight.w800)),
                    ]),
                  ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 8), child: Row(children: [Text('By platform', style: comfortaa(16, p.text)), const Spacer(), Text('SAMPLE', style: manrope(10, p.orangeText, weight: FontWeight.w800))])),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                decoration: glass(p, radius: 14),
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  AppTile(id: r.$1, size: 34),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.$2, style: manrope(13.5, p.text, weight: FontWeight.w800)),
                    Text('${r.$3} clicks · ${r.$4} orders', style: manrope(11.5, p.text2)),
                  ])),
                  Text(r.$5 == 0 ? '—' : inr(r.$5), style: manrope(13.5, p.text, weight: FontWeight.w800)),
                ]),
              ),
            ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 0), child: Text('Food, grocery and ride apps are deep links only, so they show clicks without commission.', style: manrope(11.5, p.text3, weight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class VoiceNotesScreen extends StatefulWidget {
  const VoiceNotesScreen({super.key, this.jumpEnd = false});
  final bool jumpEnd;

  @override
  State<VoiceNotesScreen> createState() => _VoiceNotesScreenState();
}

class _VoiceNotesScreenState extends State<VoiceNotesScreen> {
  String _mode = 'lecture';
  String _level = 'University';
  String _lang = 'en';
  final _title = TextEditingController();
  final _subject = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    const modes = [('lecture', 'Lecture', 'cap', 'blue', 'Topics, definitions, formulas and homework', 'Linear Algebra – Chapter 3'), ('meeting', 'Meeting', 'users', 'violet', 'Agenda, discussion points and next steps', 'Team sync'), ('business', 'Business', 'brief', 'orange', 'Attendees, decisions, action items', 'Q4 launch plan'), ('memo', 'Memo', 'mic', 'cyan', 'A clean transcript with a short summary', 'Quick memo'), ('interview', 'Interview', 'chat', 'green', 'Questions, answers and highlights', 'Candidate interview'), ('call', 'Call', 'phone', 'pink', 'What was agreed and follow-ups', 'Client call'), ('ideas', 'Ideas', 'bulb', 'orange', 'Themes, ideas and next steps', 'Ideas'), ('podcast', 'Podcast', 'podcast', 'violet', 'Key takeaways and quotes', 'Talk notes')];
    final m = modes.firstWhere((x) => x.$1 == _mode);
    return AkayaScreen(
      jumpEnd: widget.jumpEnd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Voice Notes', sub: 'Live transcript → smart notes'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Pearl(width: 96, height: 88, radius: 28, mood: PearlMood.listening, shadow: false, glow: 0.45),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Record anything. Akaya writes the notes.', style: manrope(14, p.text, weight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Lectures, meetings, calls or ideas. Watch the transcript and notes build live.', style: manrope(12, p.text2, weight: FontWeight.w600, height: 1.35)),
              ])),
            ]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Text('Choose a mode', style: comfortaa(16, p.text))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final x in modes)
                GestureDetector(
                  onTap: () => setState(() => _mode = x.$1),
                  child: Container(
                    width: 78,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _mode == x.$1 ? p.tint('violet') : p.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _mode == x.$1 ? p.violetText : p.line),
                    ),
                    child: Column(children: [Gi(icon: x.$3, tone: x.$4, size: 34, iconSize: 17, radius: 11), const SizedBox(height: 4), Text(x.$2, style: manrope(11, p.text, weight: FontWeight.w700))]),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: glass(p),
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.$2, style: manrope(14, p.text, weight: FontWeight.w800)),
                Text(m.$5, style: manrope(12, p.text2)),
                if (_mode == 'lecture') ...[
                  const SizedBox(height: 8),
                  Segmented(full: true, value: _level, onChanged: (v) => setState(() => _level = v), options: const [('School', Text('School')), ('College', Text('College')), ('University', Text('University'))]),
                ],
                const SizedBox(height: 8),
                TextField(controller: _title, style: manrope(14, p.text), decoration: InputDecoration(labelText: 'Title', hintText: m.$6, labelStyle: manrope(12, p.text3), hintStyle: manrope(14, p.text3))),
                Row(children: [
                  Expanded(child: TextField(controller: _subject, style: manrope(14, p.text), decoration: InputDecoration(labelText: _mode == 'lecture' ? 'Subject' : 'Tag', labelStyle: manrope(12, p.text3)))),
                  const SizedBox(width: 8),
                  Segmented(value: _lang, onChanged: (v) => setState(() => _lang = v), options: const [('en', Text('English')), ('hi', Text('हिन्दी'))]),
                ]),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Start recording',
                  icon: 'mic',
                  onTap: () => context.go('/vnotes/rec?mode=$_mode&title=${Uri.encodeComponent(_title.text.isEmpty ? m.$6 : _title.text)}&lang=$_lang'),
                ),
              ]),
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Text('Try a live demo', style: comfortaa(16, p.text))),
          _demo(context, p, 'cap', 'blue', 'Sample lecture', 'Linear algebra, 1 min', '/vnotes/rec?demo=lecture&mode=lecture'),
          _demo(context, p, 'brief', 'orange', 'Business meeting', 'Q4 launch plan, 1 min', '/vnotes/rec?demo=business&mode=business'),
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 8), child: Text('Recent recordings', style: comfortaa(16, p.text))),
          for (final v in model.voiceNotes)
            GestureDetector(
              onTap: () => context.go('/vnotes/${v.id}'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  decoration: glass(p, radius: 16),
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    const Gi(icon: 'wave', tone: 'blue', size: 36, iconSize: 17, radius: 12),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(v.title, style: manrope(14, p.text, weight: FontWeight.w800)),
                      Text('${v.subject} · ${(v.duration / 60).floor()} min', style: manrope(12, p.text2)),
                    ])),
                    Text(relDay(v.createdAt), style: manrope(11, p.text3)),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _demo(BuildContext context, AkayaPalette p, String icon, String tone, String title, String sub, String to) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GestureDetector(
        onTap: () => context.go(to),
        child: Container(
          decoration: glass(p, radius: 16),
          padding: const EdgeInsets.all(12),
          child: Row(children: [Gi(icon: icon, tone: tone, size: 36, iconSize: 18, radius: 12), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: manrope(14, p.text, weight: FontWeight.w800)), Text(sub, style: manrope(12, p.text2))])]),
        ),
      ),
    );
  }
}

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key, this.demo, this.tab, this.hold = false});
  final String? demo;
  final String? tab;
  final bool hold;

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  String _phase = 'recording';
  late int _secs = widget.hold ? ((AnimClock.ms != null) ? (AnimClock.ms! / 1000).round() : 48) : 0;
  int _words = 0;
  late String _tab = widget.tab ?? 'notes';
  Timer? _t;

  static const _lecture = 'The derivative of x squared is 2x. A function is differentiable when that limit exists. The power rule says d dx of x to the n is n times x to the n minus one.';
  static const _business = 'We ship Akaya Pro on the 20th. Neha owns the landing page. Rahul owns billing. Decision: launch with the yearly plan highlighted.';

  @override
  void initState() {
    super.initState();
    if (widget.hold) {
      _words = _script.split(' ').length;
      return;
    }
    _t = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!mounted || _phase != 'recording') return;
      setState(() {
        _secs += 1;
        _words = (_secs / 2).floor().clamp(0, _script.split(' ').length);
      });
    });
  }

  String get _script => widget.demo == 'business' ? _business : _lecture;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final lecture = widget.demo != 'business';
    final shown = _script.split(' ').take(_words).join(' ');
    final notes = lecture
        ? '• Power rule: d/dx xⁿ = n·xⁿ⁻¹\n• Differentiability needs the limit\n• Homework follows the examples'
        : '• Ship date: the 20th\n• Neha: landing page\n• Rahul: billing';
    return Column(
      children: [
        ScreenHeader(title: lecture ? 'Sample lecture' : 'Q4 launch plan', sub: _phase == 'paused' ? 'Paused' : 'Recording…'),
        const Pearl(width: 120, height: 90, radius: 32, mood: PearlMood.listening, glow: 0.4, shadow: false),
        Text('${(_secs ~/ 60).toString().padLeft(2, '0')}:${(_secs % 60).toString().padLeft(2, '0')}', style: comfortaa(28, p.text)),
        const SizedBox(height: 6),
        WaveBars(color: p.violetText, height: 36),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Segmented(full: true, value: _tab, onChanged: (v) => setState(() => _tab = v), options: const [('notes', Text('Notes')), ('transcript', Text('Transcript')), ('map', Text('Mind map'))]),
        ),
        Expanded(
          child: _tab == 'map'
              ? SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: MindMapView(root: lecture ? lectureMind : businessMind),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(_tab == 'transcript' ? (shown.isEmpty ? '…' : shown) : notes, style: manrope(14, p.text, weight: FontWeight.w600, height: 1.45)),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(children: [
            Expanded(child: OutlineButton(label: _phase == 'paused' ? 'Resume' : 'Pause', onTap: () => setState(() => _phase = _phase == 'paused' ? 'recording' : 'paused'))),
            const SizedBox(width: 8),
            Expanded(child: PrimaryButton(label: 'Save note', onTap: () {
              AkayaScope.of(context).showToast('Recording saved (demo)');
              context.go('/vnotes');
            })),
          ]),
        ),
      ],
    );
  }
}

class NoteViewScreen extends StatefulWidget {
  const NoteViewScreen({super.key, required this.id, this.tab, this.hindi = false, this.playing = false});
  final String id;
  final String? tab;
  final bool hindi;
  final bool playing;

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  late String _tab = _norm(widget.tab);
  late bool _playing = widget.playing || widget.hindi;
  late double _pos = widget.hindi ? 0.42 : (widget.playing ? 0.18 : 0);

  String _norm(String? t) {
    if (t == null || t.isEmpty) return 'notes';
    if (t == 'map') return 'mind';
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    VoiceNoteItem? v;
    for (final n in model.voiceNotes) {
      if (n.id == widget.id) v = n;
    }
    if (v == null) {
      return const AkayaScreen(child: Column(children: [ScreenHeader(title: 'Voice Notes'), SizedBox(height: 24), Center(child: Text('Recording not found'))]));
    }
    final lecture = v.mode == 'lecture';
    final ideas = v.mode == 'ideas';
    final lines = ideas
        ? [
            ('You', 'Idea for the Diwali campaign: short videos of families using Akaya to plan the festival.', false),
            ('You', 'दिवाली पर परिवार के साथ वीडियो कॉल वाला आइडिया भी अच्छा है।', true),
            ('You', 'Maybe a Hindi and Tamil version of the ad, with greeting templates in the app.', false),
          ]
        : lecture
            ? [
                ('You', 'Today we cover the derivative. The derivative of x squared is 2x.', false),
                ('You', 'Remember the power rule before the quiz.', false),
              ]
            : [
                ('Neha', 'Weekly sync. Pipeline is up 12 percent.', false),
                ('Rahul', 'Next step is the Diwali creative review on Thursday.', false),
              ];
    final summary = ideas
        ? 'Three Diwali campaign ideas, including a Hindi line about a family video call. Share them with Neha by Friday.'
        : lecture
            ? 'The lecture covers the power rule and when a function is differentiable. Homework is problems 3.1–3.8.'
            : 'Sales are up. Neha owns the landing page and Rahul owns billing. The launch highlights the yearly plan.';
    final actions = ideas
        ? '• Share campaign ideas with Neha · Fri\n• Draft Hindi and Tamil ad versions'
        : lecture
            ? '• Finish problems 3.1–3.8\n• Review the limit definition'
            : '• Call both Delhi distributors · Rahul · Tomorrow\n• Update the sales dashboard · Neha · Wed';
    final notes = ideas
        ? '• Short videos of families planning Diwali with Akaya\n• Video call with family (Hindi)\n• Hindi + Tamil ad versions'
        : lecture
            ? '• Power rule: d/dx xⁿ = n·xⁿ⁻¹\n• Differentiability needs the limit of the difference quotient\n• Homework: problems 3.1–3.8'
            : '• Decision captured in the recording\n• Owners and dates are listed in the transcript\n• Follow up before the next sync';
    final mapRoot = ideas ? ideasMind : (lecture ? lectureMind : businessMind);
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(title: v.title, sub: '${v.subject} · ${v.mode}'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p),
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => setState(() => _playing = !_playing),
                  child: Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(gradient: p.brand, shape: BoxShape.circle), child: AkayaIcon(_playing ? 'stop' : 'play', size: 16, color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Slider(value: _pos, onChanged: (n) => setState(() => _pos = n), activeColor: AkayaPalette.violet),
                    Text('${(v.duration / 60).floor()} min ${v.duration % 60}s · ${relDay(v.createdAt)}', style: manrope(12, p.text2)),
                  ]),
                ),
              ]),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final t in [('transcript', 'Transcript'), ('notes', 'Notes'), ('summary', 'Summary'), ('mind', 'Mind map'), ('actions', 'Actions')])
                  GestureDetector(
                    onTap: () => setState(() => _tab = t.$1),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: _tab == t.$1 ? p.brand : null,
                        color: _tab == t.$1 ? null : p.surface,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: _tab == t.$1 ? Colors.transparent : p.line),
                      ),
                      child: Text(t.$2, style: manrope(12, _tab == t.$1 ? Colors.white : p.text2, weight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: glass(p),
              padding: const EdgeInsets.all(14),
              child: _tab == 'transcript'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final line in lines)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: line.$3 && (widget.hindi || _playing) ? p.tint('violet') : p.surface2,
                              borderRadius: BorderRadius.circular(12),
                              border: line.$3 && widget.hindi ? Border.all(color: p.violetText) : null,
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Text(line.$1, style: manrope(11, p.text3, weight: FontWeight.w800)),
                                if (line.$3) ...[const SizedBox(width: 6), Text('हि', style: manrope(11, p.violetText, weight: FontWeight.w800))],
                              ]),
                              const SizedBox(height: 4),
                              Text(line.$2, style: manrope(14, p.text, weight: FontWeight.w600, height: 1.4)),
                            ]),
                          ),
                      ],
                    )
                  : _tab == 'mind'
                      ? MindMapView(root: mapRoot)
                      : Text(_tab == 'summary' ? summary : (_tab == 'actions' ? actions : notes), style: manrope(14, p.text, weight: FontWeight.w600, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
