import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../commerce/intent.dart';
import '../data/catalog.dart';
import '../state/model.dart';
import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/chrome.dart';
import '../widgets/pearl.dart';

const _suggest = [
  'Plan my weekend',
  'Remind me to call Rahul at 5',
  'Translate "Thank you so much!" to Hindi',
  'Summarise my day',
];

const _tiles = [
  ('camera', 'camera', 'Camera', 'Take a photo', 'blue'),
  ('photos', 'image', 'Photos', 'Gallery & videos', 'pink'),
  ('files', 'file', 'Files', 'PDF, DOCX, XLSX…', 'violet'),
  ('scan', 'scan', 'Scan', 'Document', 'cyan'),
  ('screen', 'monitor', 'Read screen', 'Screenshot', 'orange'),
  ('voice', 'mic', 'Voice note', 'Record audio', 'green'),
  ('location', 'location', 'Location', 'Share where', 'pink'),
  ('contact', 'contact', 'Contact', 'Share a card', 'blue'),
  ('apps', 'apps', 'Apps', 'Integrations', 'violet'),
  ('notes', 'note', 'Smart Notes', 'Add a note', 'orange'),
  ('image', 'wand', 'Create image', 'Describe it', 'cyan'),
  ('schedule', 'future', 'Schedule', 'Future Message', 'green'),
];

const _contacts = [
  ('Priya Sharma', '+91 98200 00001'),
  ('Rahul Verma', '+91 98200 00002'),
  ('Neha Iyer', '+91 98200 00003'),
  ('Delivery partner', '+91 98200 00004'),
];

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.id, this.attach = false, this.panel});
  final String? id;
  final bool attach;
  final String? panel;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();
  final _atts = <ChatAttachment>[];
  final _modes = <String>{};
  bool _typing = false;
  String? _localId;

  String? get _id => widget.id ?? _localId;

  @override
  void initState() {
    super.initState();
    if (!widget.attach && widget.panel == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.panel != null) {
        _pick(widget.panel!);
      } else {
        _openAttach();
      }
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _add(ChatAttachment a) {
    setState(() {
      if (_atts.length < 12) _atts.add(a);
    });
  }

  void _send(String raw) {
    final msg = raw.trim();
    if ((msg.isEmpty && _atts.isEmpty) || _typing) return;
    final model = AkayaScope.of(context);
    final sent = List<ChatAttachment>.from(_atts);
    final modes = _modes.toList();
    final id = model.sendChat(_id, msg, attachments: sent, modes: modes);
    _text.clear();
    setState(() {
      _typing = true;
      _localId = id;
      _atts.clear();
      _modes.remove('image');
    });
    if (widget.id != id) context.go('/chat/$id');
    Future.delayed(Duration(milliseconds: modes.contains('deep') ? 1700 : 800), () {
      if (mounted) setState(() => _typing = false);
    });
  }

  void _pick(String k) {
    if (k == 'schedule') {
      context.go('/future');
      return;
    }
    if (k == 'image') {
      setState(() {
        if (!_modes.add('image')) _modes.remove('image');
      });
      return;
    }
    if (k == 'apps') {
      _panel('Add an app', _appsBody);
      return;
    }
    if (k == 'notes') {
      _panel('Add a Smart Note', _notesBody);
      return;
    }
    if (k == 'contact') {
      _panel('Share a contact', _contactsBody);
      return;
    }
    if (k == 'voice') {
      AkayaScope.of(context).showToast('Recording a voice note (demo)');
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        _add(ChatAttachment(id: 'a${DateTime.now().millisecondsSinceEpoch}', kind: 'audio', name: 'Voice note', meta: '0:04 · demo'));
      });
      return;
    }
    final stamp = '20261014_094100';
    final att = switch (k) {
      'camera' => ChatAttachment(id: 'a$stamp', kind: 'image', name: 'IMG_$stamp.jpg', visual: true),
      'photos' => ChatAttachment(id: 'p$stamp', kind: 'image', name: 'beach.jpg', visual: true),
      'files' => ChatAttachment(id: 'f$stamp', kind: 'file', name: 'invoice.pdf', meta: 'PDF · 128 KB'),
      'scan' => ChatAttachment(id: 's$stamp', kind: 'scan', name: 'Scan_$stamp.jpg', meta: 'Scanned page', visual: true),
      'screen' => ChatAttachment(id: 'sc$stamp', kind: 'screen', name: 'screenshot.png', meta: 'Screenshot to read', visual: true),
      'location' => ChatAttachment(id: 'l$stamp', kind: 'location', name: 'Current location', meta: '19.07600, 72.87770 · ±40 m'),
      _ => ChatAttachment(id: 'x$stamp', kind: k, name: k),
    };
    _add(att);
  }

  void _panel(String title, Widget Function(AkayaPalette) body) {
    showAkayaSheet(context, title: title, child: Builder(builder: (c) => body(paletteOf(c))));
  }

  Widget _appsBody(AkayaPalette p) {
    final apps = kApps.where((a) => a.popular).take(12).toList();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final a in apps)
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              _add(ChatAttachment(id: 'app-${a.id}', kind: 'app', name: a.name, meta: 'App'));
            },
            child: SizedBox(width: 72, child: Column(children: [AppTile(id: a.id, size: 44), const SizedBox(height: 4), Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(11, p.text, weight: FontWeight.w700))])),
          ),
      ],
    );
  }

  Widget _notesBody(AkayaPalette p) {
    final notes = AkayaScope.of(context).notes;
    if (notes.isEmpty) return Text('No Smart Notes yet.', style: manrope(13, p.text2));
    return Column(
      children: [
        for (final n in notes)
          ListTile(
            leading: AkayaIcon('note', size: 18, color: p.orangeText),
            title: Text(n.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: manrope(13, p.text, weight: FontWeight.w700)),
            onTap: () {
              Navigator.pop(context);
              _add(ChatAttachment(id: 'note-${n.id}', kind: 'note', name: n.text.length > 28 ? '${n.text.substring(0, 28)}…' : n.text, meta: 'Smart Note'));
            },
          ),
      ],
    );
  }

  Widget _contactsBody(AkayaPalette p) {
    return Column(
      children: [
        for (final c in _contacts)
          ListTile(
            leading: CircleAvatar(backgroundColor: p.tint('blue'), child: Text(c.$1[0], style: manrope(14, AkayaPalette.blue, weight: FontWeight.w800))),
            title: Text(c.$1, style: manrope(14, p.text, weight: FontWeight.w800)),
            subtitle: Text(c.$2, style: manrope(12, p.text2)),
            onTap: () {
              Navigator.pop(context);
              _add(ChatAttachment(id: 'c-${c.$2}', kind: 'contact', name: c.$1, meta: c.$2));
            },
          ),
      ],
    );
  }

  void _openAttach() {
    showAkayaSheet(
      context,
      title: 'Add to your message',
      child: Builder(
        builder: (c) {
          final p = paletteOf(c);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.92,
                children: [
                  for (final t in _tiles)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(c);
                        _pick(t.$1);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: t.$1 == 'image' && _modes.contains('image') ? p.tint('cyan') : p.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: p.line),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Gi(icon: t.$2, tone: t.$5, size: 36, iconSize: 18, radius: 12),
                            const SizedBox(height: 6),
                            Text(t.$3, style: manrope(12, p.text, weight: FontWeight.w800)),
                            Text(t.$4, textAlign: TextAlign.center, style: manrope(10, p.text3, weight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _modeRow(p, 'web', 'globe', 'blue', 'Web search', 'Look things up online for this message'),
              const SizedBox(height: 8),
              _modeRow(p, 'deep', 'brain', 'violet', 'Deep think', 'Slower, more careful answers'),
            ],
          );
        },
      ),
    );
  }

  Widget _modeRow(AkayaPalette p, String id, String icon, String tone, String title, String sub) {
    final on = _modes.contains(id);
    return Container(
      decoration: glass(p, radius: 16),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        children: [
          Gi(icon: icon, tone: tone, size: 34, iconSize: 16, radius: 11),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: manrope(13.5, p.text, weight: FontWeight.w800)), Text(sub, style: manrope(11.5, p.text2))])),
          AkayaToggle(on: on, onChanged: (v) => setState(() => v ? _modes.add(id) : _modes.remove(id))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    ChatThread? chat;
    for (final c in model.chats) {
      if (c.id == _id) chat = c;
    }
    final msgs = chat?.messages ?? const <ChatMsg>[];
    final title = chat != null && msgs.isNotEmpty ? chat.title : 'Ask Akaya';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Row(
            children: [
              AkayaIconButton(icon: 'back', label: 'Back to Home', onTap: () => context.go('/home')),
              const SizedBox(width: 8),
              Pearl(width: 44, height: 44, radius: 16, shadow: false, glow: 0.15, mood: _typing ? PearlMood.thinking : PearlMood.idle),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(14, p.text, weight: FontWeight.w800)),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: model.mode == 'on-device' ? AkayaPalette.green : AkayaPalette.blue, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text(_typing ? 'Akaya is thinking…' : (model.mode == 'on-device' ? 'On-device AI' : 'Online'), style: manrope(11, p.text2, weight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              AkayaIconButton(icon: 'history', label: 'History', onTap: () => context.go('/history')),
              const SizedBox(width: 6),
              AkayaIconButton(icon: 'plus', label: 'New chat', onTap: () => context.go('/chat')),
            ],
          ),
        ),
        Expanded(
          child: msgs.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                  children: [
                    const Center(child: Pearl(width: 220, height: 170, radius: 50, scene: true, interactive: true)),
                    const SizedBox(height: 6),
                    Center(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: 'Ask me ', style: comfortaa(26, p.text, height: 1.15)),
                          WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: GradText('anything', size: 26)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Chat, plan, translate, set reminders. Add photos, files or your location with +.', textAlign: TextAlign.center, style: manrope(12.6, p.text2, weight: FontWeight.w600, height: 1.45)),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in _suggest)
                          GestureDetector(
                            onTap: () => _send(s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                              decoration: glass(p, radius: 16),
                              child: Text(s, style: manrope(12, p.text, weight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  children: [
                    for (final m in msgs) _bubble(p, m),
                    if (_typing)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: glass(p, radius: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < 3; i++)
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(color: p.violetText.withValues(alpha: 0.55), shape: BoxShape.circle),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        if (_atts.isNotEmpty || _modes.isNotEmpty)
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              children: [
                for (final m in _modes)
                  _chip(p, m == 'web' ? 'Web search' : (m == 'deep' ? 'Deep think' : 'Create image'), m == 'web' ? 'globe' : (m == 'deep' ? 'brain' : 'wand'), () => setState(() => _modes.remove(m))),
                for (final a in _atts) _chip(p, a.name, a.kind == 'file' ? 'file' : (a.kind == 'location' ? 'location' : (a.kind == 'audio' ? 'mic' : (a.kind == 'contact' ? 'contact' : (a.kind == 'note' ? 'note' : (a.kind == 'app' ? 'apps' : 'image'))))), () => setState(() => _atts.remove(a))),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: Container(
            decoration: glass(p, radius: 26),
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _openAttach,
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: AkayaIcon('plus', size: 20, color: p.text, strokeWidth: 2.4),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _text,
                    style: manrope(14, p.text, weight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Ask Akaya anything…',
                      hintStyle: manrope(14, p.text3, weight: FontWeight.w500),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _text,
                  builder: (context, value, _) {
                    final can = value.text.trim().isNotEmpty || _atts.isNotEmpty;
                    return GestureDetector(
                      onTap: can ? () => _send(_text.text) : () => context.go('/voice'),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(gradient: p.brand, shape: BoxShape.circle),
                        child: AkayaIcon(can ? 'send' : 'mic', size: 18, color: Colors.white),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(AkayaPalette p, String label, String icon, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      decoration: glass(p, radius: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AkayaIcon(icon, size: 14, color: p.text2),
          const SizedBox(width: 6),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 140), child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(12, p.text, weight: FontWeight.w700))),
          GestureDetector(onTap: onRemove, child: Padding(padding: const EdgeInsets.all(4), child: AkayaIcon('close', size: 12, color: p.text3, strokeWidth: 2.6))),
        ],
      ),
    );
  }

  Widget _bubble(AkayaPalette p, ChatMsg m) {
    final mine = m.from == 'me';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.fromLTRB(13, 10, 13, 7),
        decoration: BoxDecoration(
          gradient: mine ? p.brand : null,
          color: mine ? null : p.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(mine ? 20 : 6),
            bottomRight: Radius.circular(mine ? 6 : 20),
          ),
          border: mine ? null : Border.all(color: p.line),
          boxShadow: mine ? const [BoxShadow(color: Color(0xB33C28DC), blurRadius: 18, offset: Offset(0, 8), spreadRadius: -10)] : p.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (m.attachments.isNotEmpty) ...[
              for (final a in m.attachments) _attCard(p, a, mine),
              const SizedBox(height: 6),
            ],
            if (m.text.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(m.text, style: manrope(13.2, mine ? Colors.white : p.text, weight: FontWeight.w600, height: 1.45)),
              ),
            if (m.action != null) _linkCard(p, m.action!),
            const SizedBox(height: 3),
            Text(fmtTime(m.at), style: manrope(9.5, mine ? Colors.white70 : p.text3, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _attCard(AkayaPalette p, ChatAttachment a, bool mine) {
    final icon = switch (a.kind) {
      'location' => 'location',
      'file' => 'file',
      'audio' => 'mic',
      'contact' => 'contact',
      'app' => 'apps',
      'note' => 'note',
      'scan' => 'scan',
      'screen' => 'monitor',
      'generated' => 'wand',
      _ => 'image',
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: mine ? Colors.white24 : p.surface2, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          if (a.kind == 'app')
            AppTile(id: a.id.replaceFirst('app-', ''), size: 34)
          else
            AkayaIcon(icon, size: 18, color: mine ? Colors.white : p.violetText),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(12.5, mine ? Colors.white : p.text, weight: FontWeight.w800)),
                if (a.meta != null) Text(a.meta!, style: manrope(10.5, mine ? Colors.white70 : p.text3)),
              ],
            ),
          ),
          if (a.visual) Container(margin: const EdgeInsets.only(left: 6), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: mine ? Colors.white24 : p.tint('violet'), borderRadius: BorderRadius.circular(8)), child: Text(a.kind == 'generated' ? 'Sample' : (a.kind == 'scan' ? 'Scan' : 'Photo'), style: manrope(9, mine ? Colors.white : p.violetText, weight: FontWeight.w800))),
        ],
      ),
    );
  }

  Widget _linkCard(AkayaPalette p, LinkAction a) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: p.surfaceSolid, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppTile(id: a.platform, size: 36),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.name, style: manrope(13, p.text, weight: FontWeight.w800)), Text(a.summary, style: manrope(11.5, p.text2))])),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: a.url));
              AkayaScope.of(context).showToast('Link copied · ${a.name}');
            },
            child: Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(gradient: p.brand, borderRadius: BorderRadius.circular(12)),
              child: Text('Open in ${a.name}', style: manrope(12.5, Colors.white, weight: FontWeight.w800)),
            ),
          ),
          if (a.earn) ...[
            const SizedBox(height: 6),
            Row(children: [AkayaIcon('help', size: 12, color: p.text3), const SizedBox(width: 4), Expanded(child: Text(a.platform == 'amazon' ? 'Akaya may earn a commission. As an Amazon Associate, Akaya earns from qualifying purchases.' : 'Akaya may earn a commission', style: manrope(10.5, p.text3, weight: FontWeight.w600)))]),
          ],
        ],
      ),
    );
  }
}
