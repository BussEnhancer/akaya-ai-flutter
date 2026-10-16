import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../state/model.dart';
import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/chrome.dart';
import '../widgets/pearl.dart';
import 'app_connect.dart';

DateTime _ist(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).add(const Duration(hours: 5, minutes: 30));

String _fmtIst(int ms) {
  final d = _ist(ms);
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ap = d.hour >= 12 ? 'PM' : 'AM';
  final min = d.minute.toString().padLeft(2, '0');
  return '$h:$min $ap';
}

String _relIst(int ms) {
  final d = _ist(ms);
  final n = _ist(DateTime.now().millisecondsSinceEpoch);
  final day = DateTime.utc(d.year, d.month, d.day);
  final today = DateTime.utc(n.year, n.month, n.day);
  if (day == today) return 'Today';
  if (day == today.add(const Duration(days: 1))) return 'Tomorrow';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${d.month}/${d.day}';
}

String inr(num n) {
  final v = n.round().abs().toString();
  if (v.length <= 3) return '₹$v';
  final last = v.substring(v.length - 3);
  var rest = v.substring(0, v.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '₹${parts.join(',')},$last';
}

const _langs = [
  ('en', 'English', 'English'),
  ('hi', 'Hindi', 'हिन्दी'),
  ('ta', 'Tamil', 'தமிழ்'),
  ('bn', 'Bengali', 'বাংলা'),
  ('mr', 'Marathi', 'मराठी'),
  ('es', 'Spanish', 'Español'),
  ('fr', 'French', 'Français'),
  ('ja', 'Japanese', '日本語'),
  ('ar', 'Arabic', 'العربية'),
];

const _phrases = [
  {
    'en': 'How are you? Let’s meet tomorrow.',
    'hi': 'आप कैसे हैं? चलो कल मिलते हैं।',
    'ta': 'நீங்கள் எப்படி இருக்கிறீர்கள்? நாளை சந்திப்போம்.',
    'bn': 'আপনি কেমন আছেন? চলুন কাল দেখা করি।',
    'mr': 'तुम्ही कसे आहात? उद्या भेटूया.',
    'es': '¿Cómo estás? Nos vemos mañana.',
    'fr': 'Comment ça va ? On se voit demain.',
    'ja': 'お元気ですか？明日会いましょう。',
    'ar': 'كيف حالك؟ لنلتقِ غدًا.',
  },
  {
    'en': 'Thank you so much!',
    'hi': 'बहुत-बहुत धन्यवाद!',
    'ta': 'மிக்க நன்றி!',
    'bn': 'অনেক ধন্যবাদ!',
    'mr': 'खूप खूप धन्यवाद!',
    'es': '¡Muchas gracias!',
    'fr': 'Merci beaucoup !',
    'ja': '本当にありがとう！',
    'ar': 'شكرًا جزيلًا!',
  },
  {
    'en': 'Where is the nearest metro station?',
    'hi': 'सबसे नज़दीकी मेट्रो स्टेशन कहाँ है?',
    'ta': 'அருகிலுள்ள மெட்ரோ நிலையம் எங்கே?',
    'bn': 'সবচেয়ে কাছের মেট্রো স্টেশন কোথায়?',
    'mr': 'सर्वात जवळचे मेट्रो स्टेशन कुठे आहे?',
    'es': '¿Dónde está la estación de metro más cercana?',
    'fr': 'Où est la station de métro la plus proche ?',
    'ja': '最寄りの地下鉄の駅はどこですか？',
    'ar': 'أين أقرب محطة مترو؟',
  },
];

String? _translate(String text, String to) {
  for (final p in _phrases) {
    if (p.values.any((v) => v == text)) return p[to];
  }
  return null;
}

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  String _from = 'hi';
  String _to = 'en';
  late final _ctrl = TextEditingController(text: _phrases[0]['hi']);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final out = _translate(_ctrl.text, _to);
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Translate', sub: '99+ languages · sample phrasebook in this demo'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _pick(p, 'From', _from, (v) => setState(() => _from = v))),
                GestureDetector(
                  onTap: () => setState(() {
                    final t = _from;
                    _from = _to;
                    _to = t;
                    if (out != null) _ctrl.text = out;
                  }),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: glass(p, radius: 20),
                    child: AkayaIcon('swap', size: 18, color: p.text),
                  ),
                ),
                Expanded(child: _pick(p, 'To', _to, (v) => setState(() => _to = v))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: glass(p),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _ctrl,
                    maxLines: 4,
                    style: manrope(15, p.text, weight: FontWeight.w600, height: 1.45),
                    decoration: InputDecoration(border: InputBorder.none, hintText: 'Type or paste text…', hintStyle: manrope(15, p.text3)),
                    onChanged: (_) => setState(() {}),
                  ),
                  Row(
                    children: [
                      AkayaIcon('volume', size: 18, color: p.text2),
                      const Spacer(),
                      Text('${_ctrl.text.length}/500', style: manrope(11, p.text3, weight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: BoxDecoration(gradient: p.brand, borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_langs.firstWhere((l) => l.$1 == _to).$2, style: manrope(11, Colors.white70, weight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    out ?? 'This demo translates the sample phrases below. Live translation connects to the Akaya API.',
                    style: manrope(15.5, Colors.white, weight: FontWeight.w700, height: 1.45),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const AkayaIcon('volume', size: 18, color: Colors.white),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (out == null) return;
                          Clipboard.setData(ClipboardData(text: out));
                          AkayaScope.of(context).showToast('Translation copied');
                        },
                        child: const AkayaIcon('copy', size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 8), child: Text('Try a phrase', style: manrope(13, p.text2, weight: FontWeight.w800))),
          for (final ph in _phrases)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: GestureDetector(
                onTap: () => setState(() => _ctrl.text = ph[_from] ?? ph['en']!),
                child: Container(
                  width: double.infinity,
                  decoration: glass(p, radius: 16),
                  padding: const EdgeInsets.all(12),
                  child: Text(ph[_from] ?? ph['en']!, style: manrope(13.5, p.text, weight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pick(AkayaPalette p, String label, String value, ValueChanged<String> onChanged) {
    return Container(
      decoration: glass(p, radius: 16),
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: manrope(10.5, p.text3, weight: FontWeight.w700)),
          DropdownButton<String>(
            isExpanded: true,
            value: value,
            underline: const SizedBox.shrink(),
            style: manrope(12.5, p.text, weight: FontWeight.w700),
            items: [for (final l in _langs) DropdownMenuItem(value: l.$1, child: Text('${l.$2} · ${l.$3}', overflow: TextOverflow.ellipsis))],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _text = TextEditingController();
  final _q = TextEditingController();
  String _color = 'violet';

  @override
  void dispose() {
    _text.dispose();
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final notes = model.notes.where((n) => n.text.toLowerCase().contains(_q.text.toLowerCase())).toList();
    const colors = ['violet', 'blue', 'green', 'orange', 'pink'];
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(title: 'Smart Note', sub: '${model.notes.length} notes · saved on this device'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                children: [
                  TextField(
                    controller: _text,
                    maxLines: 3,
                    style: manrope(14, p.text, weight: FontWeight.w600),
                    decoration: InputDecoration(border: InputBorder.none, hintText: 'Jot something down…', hintStyle: manrope(14, p.text3)),
                    onChanged: (_) => setState(() {}),
                  ),
                  Row(
                    children: [
                      for (final c in colors)
                        GestureDetector(
                          onTap: () => setState(() => _color = c),
                          child: Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: p.toneColor(c),
                              shape: BoxShape.circle,
                              border: Border.all(color: _color == c ? p.text : Colors.transparent, width: 2),
                            ),
                          ),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _text.text.trim().isEmpty
                            ? null
                            : () {
                                model.addNote(_text.text.trim(), _color);
                                _text.clear();
                                model.showToast('Note saved');
                                setState(() {});
                              },
                        child: Opacity(
                          opacity: _text.text.trim().isEmpty ? 0.45 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(gradient: p.gOrange, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const AkayaIcon('plus', size: 14, color: Colors.white, strokeWidth: 2.4),
                                const SizedBox(width: 4),
                                Text('Add note', style: manrope(12.5, Colors.white, weight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Container(
              decoration: glass(p, radius: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  AkayaIcon('search', size: 17, color: p.text3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _q,
                      style: manrope(14, p.text),
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'Search notes', hintStyle: manrope(14, p.text3)),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (notes.isEmpty)
            Padding(padding: const EdgeInsets.all(24), child: Text(_q.text.isEmpty ? 'No notes yet. Add your first one above.' : 'No notes match your search.', textAlign: TextAlign.center, style: manrope(13, p.text2)))
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final n in notes)
                    Container(
                      width: 168,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: p.tint(n.color), borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.text, style: manrope(13, p.text, weight: FontWeight.w700, height: 1.4)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(relDay(n.createdAt), style: manrope(11, p.text3, weight: FontWeight.w600)),
                              const Spacer(),
                              GestureDetector(onTap: () => model.deleteNote(n.id), child: AkayaIcon('trash', size: 16, color: p.text2)),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final k = _q.text.trim().toLowerCase();
    const feats = [
      ('Floating', 'float', '/more'),
      ('Ask Akaya / New chat', 'ask', '/chat'),
      ('Voice', 'mic', '/voice'),
      ('Translate', 'translate', '/translate'),
      ('Read Screen', 'read', '/home?sheet=read'),
      ('Future Message', 'future', '/future'),
      ('Smart Note', 'note', '/notes'),
      ('Agents', 'agent', '/home?sheet=agents'),
      ('Explore', 'explore', '/home?sheet=explore'),
      ('Instant Loan', 'loan', '/home?sheet=loan'),
      ('History', 'history', '/history'),
      ('Settings', 'more', '/more'),
    ];
    final shown = feats.where((f) => k.isEmpty || f.$1.toLowerCase().contains(k)).toList();
    final chats = k.isEmpty ? <ChatThread>[] : model.chats.where((c) => c.title.toLowerCase().contains(k) || c.messages.any((m) => m.text.toLowerCase().contains(k))).toList();
    final notes = k.isEmpty ? <NoteItem>[] : model.notes.where((n) => n.text.toLowerCase().contains(k)).toList();
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Search'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p, radius: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  AkayaIcon('search', size: 19, color: p.text3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _q,
                      autofocus: true,
                      style: manrope(14.5, p.text),
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'Search features, chats and notes', hintStyle: manrope(14.5, p.text3)),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (shown.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Text('Features', style: manrope(13, p.text2, weight: FontWeight.w800))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p, radius: 18),
              child: Column(
                children: [
                  for (final f in shown)
                    GestureDetector(
                      onTap: () => context.go(f.$3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        child: Row(
                          children: [
                            AkayaIcon(f.$2, size: 18, color: p.violetText),
                            const SizedBox(width: 10),
                            Expanded(child: Text(f.$1, style: manrope(14, p.text, weight: FontWeight.w800))),
                            AkayaIcon('chev', size: 15, color: p.text3),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (chats.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Text('Chats', style: manrope(13, p.text2, weight: FontWeight.w800))),
            for (final c in chats)
              ListTile(
                leading: AkayaIcon('chat', size: 18, color: AkayaPalette.blue),
                title: Text(c.title, style: manrope(14, p.text, weight: FontWeight.w800)),
                subtitle: Text(c.messages.last.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: manrope(12, p.text2)),
                onTap: () => context.go('/chat/${c.id}'),
              ),
          ],
          if (notes.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Text('Notes', style: manrope(13, p.text2, weight: FontWeight.w800))),
            for (final n in notes)
              ListTile(
                leading: AkayaIcon('note', size: 18, color: p.orangeText),
                title: Text(n.text, style: manrope(13.5, p.text, weight: FontWeight.w700)),
                onTap: () => context.go('/notes'),
              ),
          ],
          if (k.isNotEmpty && shown.isEmpty && chats.isEmpty && notes.isEmpty)
            Padding(padding: const EdgeInsets.all(28), child: Text('No results for “${_q.text}”.', textAlign: TextAlign.center, style: manrope(13, p.text2))),
        ],
      ),
    );
  }
}


class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  String _cycle = 'yearly';

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    const pro = [
      'Unlimited Online mode chats',
      'Up to 20 active AI Agents',
      'Longer voice conversations',
      'Priority Read Screen & Translate',
      'Unlimited Future Messages',
    ];
    return AkayaScreen(
      child: Column(
        children: [
          const ScreenHeader(title: 'Upgrade Plan'),
          const Pearl(width: 200, height: 150, radius: 46, scene: true, mood: PearlMood.happy),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Akaya ', style: comfortaa(26, p.text)),
              WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: const GradText('Pro', size: 26)),
            ]),
          ),
          Text('Do more with your intelligent assistant.', style: manrope(13, p.text2, weight: FontWeight.w600)),
          const SizedBox(height: 14),
          Segmented(
            value: _cycle,
            onChanged: (v) => setState(() => _cycle = v),
            options: const [('monthly', Text('Monthly')), ('yearly', Text('Yearly · save 29%'))],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Container(
              decoration: glass(p),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_cycle == 'yearly' ? '₹1,699' : '₹199', style: comfortaa(32, p.text)),
                      Text(_cycle == 'yearly' ? '/year' : '/month', style: manrope(14, p.text2, weight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: p.tint('orange'), borderRadius: BorderRadius.circular(99)),
                        child: Text('Sample pricing', style: manrope(11, p.orangeText, weight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final f in pro)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: p.tint('green'), shape: BoxShape.circle),
                            child: AkayaIcon('check', size: 13, color: p.greenText, strokeWidth: 3),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(f, style: manrope(13.5, p.text, weight: FontWeight.w700))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  PrimaryButton(label: 'Upgrade to Pro', icon: 'crown', onTap: () => AkayaScope.of(context).showToast('Demo: checkout opens via the app store')),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 12, 30, 0),
            child: Text("You're on the Free plan. Cancel anytime from your store account.", textAlign: TextAlign.center, style: manrope(12, p.text3, weight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _msg = TextEditingController();
  int? _open;

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    const faq = [
      ('What is Floating?', 'A small Akaya bubble that sits over other apps (Android). Tap it to draft replies, translate or read the screen without switching apps.'),
      ('On-device vs Online?', 'On-device AI runs on your phone and works offline. Online mode uses cloud models for longer, richer answers. Switch anytime from Home or Settings.'),
      ('How do Future Messages work?', 'Write a message, pick a date and time, and Akaya sends it then. You can cancel it until it is sent.'),
      ('Which languages are supported?', 'Akaya translates across 99+ languages, including Hindi, Tamil, Bengali, Marathi, Spanish and Japanese.'),
    ];
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Support', sub: "We're here to help"),
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 8), child: Text('FAQs', style: manrope(13, p.text2, weight: FontWeight.w800))),
          for (var i = 0; i < faq.length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: GestureDetector(
                onTap: () => setState(() => _open = _open == i ? null : i),
                child: Container(
                  decoration: glass(p, radius: 16),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(faq[i].$1, style: manrope(14, p.text, weight: FontWeight.w800))),
                          AkayaIcon('chev', size: 16, color: p.text3),
                        ],
                      ),
                      if (_open == i) ...[
                        const SizedBox(height: 8),
                        Text(faq[i].$2, style: manrope(13, p.text2, weight: FontWeight.w600, height: 1.45)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 8), child: Text('Contact us', style: manrope(13, p.text2, weight: FontWeight.w800))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _msg,
                    maxLines: 4,
                    style: manrope(14, p.text),
                    decoration: InputDecoration(border: InputBorder.none, hintText: 'Describe your issue or idea…', hintStyle: manrope(14, p.text3)),
                    onChanged: (_) => setState(() {}),
                  ),
                  BrandButton(
                    label: 'Send to support',
                    icon: 'send',
                    enabled: _msg.text.trim().isNotEmpty,
                    onTap: () {
                      _msg.clear();
                      AkayaScope.of(context).showToast('Thanks! Our team will get back to you (demo)');
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key, this.category, this.query, this.appId, this.step, this.jumpEnd = false});
  final String? category;
  final String? query;
  final String? appId;
  final String? step;
  final bool jumpEnd;

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  final _q = TextEditingController();
  final _chips = ScrollController();
  String _region = 'all';
  String _cat = 'all';

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    if (cat != null && cat.isNotEmpty) _cat = cat;
    final q = widget.query;
    if (q != null && q.isNotEmpty) _q.text = q;
    const order = ['all', 'email', 'messaging', 'calendar', 'docs', 'storage', 'tasks', 'crm', 'finance'];
    final chip = order.indexOf(_cat);
    if (chip > 2) _revealChips(chip);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = widget.appId;
      if (id == null) return;
      for (final a in kApps) {
        if (a.id == id) {
          showAppConnect(context, a, step: widget.step ?? 'detail');
          return;
        }
      }
    });
  }

  void _revealChips(int index, [int n = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_chips.hasClients) return;
      final max = _chips.position.maxScrollExtent;
      if (max <= 0 && n < 6) {
        _revealChips(index, n + 1);
        return;
      }
      _chips.jumpTo((index * 84.0 - 36).clamp(0, max));
    });
  }

  @override
  void dispose() {
    _q.dispose();
    _chips.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final needle = _q.text.trim().toLowerCase();
    final list = kApps.where((a) {
      if (_cat != 'all' && a.category != _cat) return false;
      if (_region != 'all' && !a.regions.contains(_region)) return false;
      if (needle.isEmpty) return true;
      return '${a.name} ${a.desc}'.toLowerCase().contains(needle);
    }).toList();
    final connected = kApps.where((a) => model.connected.containsKey(a.id)).toList();
    final popular = kApps.where((a) => a.popular).take(12).toList();
    return AkayaScreen(
      jumpEnd: widget.jumpEnd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(title: 'Apps & Integrations', sub: '${kApps.length} apps · ${connected.length} connected'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p, radius: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  AkayaIcon('search', size: 18, color: p.text3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _q,
                      style: manrope(14, p.text),
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'Search ${kApps.length} apps: Notion, Gmail, Shopify…', hintStyle: manrope(13, p.text3)),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final r in [('all', 'All regions'), ('in', 'India'), ('global', 'Global')])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _region = r.$1),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: _region == r.$1 ? p.brand : null,
                          color: _region == r.$1 ? null : p.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _region == r.$1 ? Colors.transparent : p.line),
                        ),
                        child: Text(r.$2, style: manrope(11.5, _region == r.$1 ? Colors.white : p.text2, weight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
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
                for (final c in [('all', 'All'), ...kCategories])
                  GestureDetector(
                    onTap: () => setState(() => _cat = c.$1),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: _cat == c.$1 ? p.brand : null,
                        color: _cat == c.$1 ? null : p.surface,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: _cat == c.$1 ? Colors.transparent : p.line),
                      ),
                      child: Text(c.$2, style: manrope(12, _cat == c.$1 ? Colors.white : p.text2, weight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          if (needle.isEmpty && _cat == 'all') ...[
            Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 8), child: Text('Connected', style: manrope(13, p.text2, weight: FontWeight.w800))),
            for (final a in connected) _row(context, p, model, a),
            Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 8), child: Text('Popular', style: manrope(13, p.text2, weight: FontWeight.w800))),
            SizedBox(
              height: 92,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final a in popular)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          AppTile(id: a.id, size: 48),
                          const SizedBox(height: 6),
                          SizedBox(width: 64, child: Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: manrope(11, p.text, weight: FontWeight.w700))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 8), child: Text(needle.isEmpty && _cat == 'all' ? 'All apps' : '${list.length} apps', style: manrope(13, p.text2, weight: FontWeight.w800))),
          for (final a in list) _row(context, p, model, a),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, AkayaPalette p, AppModel model, AkayaAppInfo a) {
    final on = model.connected.containsKey(a.id);
    final region = a.regions.length > 1 ? 'India · Global' : (a.regions.first == 'in' ? 'India' : 'Global');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => showAppConnect(context, a),
            child: AppTile(id: a.id, size: 44),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => showAppConnect(context, a),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.name, style: manrope(14, p.text, weight: FontWeight.w800)),
                  Text(a.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: manrope(11.5, p.text2, weight: FontWeight.w600)),
                  Text(region, style: manrope(10.5, p.text3, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => showAppConnect(context, a, step: on ? 'detail' : 'consent'),
            child: Container(
              width: on ? 32 : null,
              height: 32,
              padding: on ? null : const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? p.tint('green') : p.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: on ? Colors.transparent : p.line),
              ),
              child: on ? AkayaIcon('check', size: 14, color: p.greenText, strokeWidth: 3) : Text(a.kind == 'deeplink' ? 'Enable' : 'Connect', style: manrope(12, p.text, weight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}


class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  String _view = 'upcoming';
  String _cat = 'all';
  String _priority = 'all';
  String _sort = 'time';
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final now = DateTime.now().millisecondsSinceEpoch;
    final needle = _q.text.trim().toLowerCase();
    bool match(ReminderItem r) {
      if (_cat != 'all' && r.category != _cat) return false;
      if (_priority != 'all' && r.priority != _priority) return false;
      if (needle.isNotEmpty && !r.title.toLowerCase().contains(needle)) return false;
      return true;
    }
    final base = model.reminders.where(match).toList();
    final upcoming = base.where((r) => !r.done && r.due >= now - 3600000).toList();
    final completed = base.where((r) => r.done).toList();
    final missed = base.where((r) => !r.done && r.due < now - 3600000).toList();
    final list = _view == 'completed' ? completed : (_view == 'missed' ? missed : upcoming);
    list.sort((a, b) {
      if (_sort == 'priority') {
        const rank = {'high': 0, 'normal': 1, 'low': 2};
        return (rank[a.priority] ?? 1).compareTo(rank[b.priority] ?? 1);
      }
      return a.due.compareTo(b.due);
    });
    return AkayaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            title: 'Reminders',
            sub: 'Never miss a thing · IST',
            trailing: AkayaIconButton(icon: 'bell', label: 'Notification states (demo)', onTap: () => model.showToast('Notification demo: Take BP medicine in 10 minutes')),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              decoration: glass(p, radius: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(children: [
                AkayaIcon('search', size: 16, color: p.text3),
                const SizedBox(width: 6),
                Expanded(child: TextField(controller: _q, onChanged: (_) => setState(() {}), style: manrope(14, p.text), decoration: InputDecoration(hintText: 'Search reminders', hintStyle: manrope(14, p.text3), border: InputBorder.none, isCollapsed: true, contentPadding: const EdgeInsets.symmetric(vertical: 12)))),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Segmented(
              full: true,
              value: _view,
              onChanged: (v) => setState(() => _view = v),
              options: [
                ('upcoming', Text('Upcoming ${upcoming.length}')),
                ('completed', Text('Completed ${completed.length}')),
                ('missed', Text('Missed ${missed.length}')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final c in const [('all', 'All'), ('health', 'Health'), ('work', 'Work'), ('finance', 'Finance'), ('personal', 'Personal'), ('dates', 'Dates')])
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              for (final pr in const [('all', 'Any priority'), ('high', 'High'), ('normal', 'Normal'), ('low', 'Low')])
                GestureDetector(
                  onTap: () => setState(() => _priority = pr.$1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(color: _priority == pr.$1 ? p.tint('violet') : p.surface, borderRadius: BorderRadius.circular(99), border: Border.all(color: _priority == pr.$1 ? p.violetText : p.line)),
                    child: Text(pr.$2, style: manrope(11, _priority == pr.$1 ? p.violetText : p.text2, weight: FontWeight.w700)),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _sort = _sort == 'time' ? 'priority' : 'time'),
                child: Row(children: [AkayaIcon('sort', size: 14, color: p.text2), const SizedBox(width: 4), Text(_sort == 'time' ? 'Time' : 'Priority', style: manrope(12, p.text2, weight: FontWeight.w700))]),
              ),
            ]),
          ),
          if (_view == 'missed')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                decoration: glass(p, radius: 16),
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  AkayaIcon('spark', size: 18, color: p.orangeText),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Smart follow-up', style: manrope(13, p.text, weight: FontWeight.w800)),
                    Text(model.autoFollowUp ? 'Akaya re-schedules missed reminders for you.' : 'Akaya suggests a new time for each missed reminder.', style: manrope(11.5, p.text2)),
                  ])),
                  AkayaToggle(on: model.autoFollowUp, onChanged: (v) => model.setAutoFollowUp(v)),
                ]),
              ),
            ),
          const SizedBox(height: 10),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.all(24), child: Text(_view == 'missed' ? 'Nothing missed. Nice!' : (_view == 'completed' ? 'Nothing completed yet.' : (needle.isEmpty ? 'No reminders here yet.' : 'No reminders match.')), textAlign: TextAlign.center, style: manrope(13, p.text2))),
          for (final r in list)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: GestureDetector(
                onTap: () => model.toggleReminder(r.id),
                child: Container(
                  decoration: glass(p, radius: 16),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: r.done ? p.greenText : p.lineStrong, width: 2), color: r.done ? p.greenText : Colors.transparent),
                        child: r.done ? const AkayaIcon('check', size: 12, color: Colors.white, strokeWidth: 3) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title, style: manrope(14, p.text, weight: FontWeight.w800)),
                            Text('${r.priority[0].toUpperCase()}${r.priority.substring(1)} · ${_relIst(r.due)}, ${_fmtIst(r.due)} IST', style: manrope(12, p.text2, weight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 8), child: Text('Quick add', style: comfortaa(16, p.text))),
          for (final q in const [('Take medicine', 'health', 'high'), ('Drink water', 'health', 'normal'), ('Call a client', 'work', 'normal'), ('Pay a bill', 'finance', 'high')])
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: GestureDetector(
                onTap: () {
                  model.addReminder(q.$1, q.$2, priority: q.$3);
                  model.showToast('Reminder added');
                },
                child: Container(
                  decoration: glass(p, radius: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [Expanded(child: Text(q.$1, style: manrope(13.5, p.text, weight: FontWeight.w800))), Text('in 1 hour', style: manrope(11.5, p.text3))]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

