import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../state/model.dart';
import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/chrome.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, this.jumpEnd = false});
  final bool jumpEnd;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    const links = [
      ('search', 'blue', 'Search', '/search'),
      ('history', 'violet', 'History', '/history'),
      ('alarm', 'orange', 'Reminders', '/reminders'),
      ('future', 'blue', 'Future', '/future'),
      ('plane', 'cyan', 'Travel', '/travel'),
      ('bag', 'pink', 'Shopping', '/shopping'),
      ('crown', 'violet', 'Upgrade', '/upgrade'),
      ('help', 'green', 'Support', '/support'),
    ];
    final connected = model.connected.keys.toList();
    return AkayaScreen(
      jumpEnd: jumpEnd,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                AkayaIconButton(icon: 'back', label: 'Back to Home', onTap: () => context.go('/home')),
                const SizedBox(width: 12),
                Text('More & Settings', style: comfortaa(18.4, p.text)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: glass(p),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const AkayaAvatar(size: 54),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.name, style: manrope(16, p.text, weight: FontWeight.w800)),
                        Text(model.contact ?? model.email, style: manrope(12, p.text2, weight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: p.tint('violet'), borderRadius: BorderRadius.circular(99)),
                          child: Text('Free plan', style: manrope(11, p.violetText, weight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: () => context.go('/upgrade'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(gradient: p.brand, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x805028DC), blurRadius: 18, offset: Offset(0, 8), spreadRadius: -8)]),
                child: Row(
                  children: [
                    const AkayaIcon('crown', size: 22, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upgrade Plan', style: manrope(14, Colors.white, weight: FontWeight.w800)),
                          Text('More agents, longer chats, priority Online mode', style: manrope(11.5, Colors.white70, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const AkayaIcon('chev', size: 18, color: Colors.white, strokeWidth: 2.4),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: GestureDetector(
              onTap: () => context.go('/apps'),
              child: Container(
                decoration: glass(p),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Gi(icon: 'apps', tone: 'blue', size: 44, iconSize: 22, radius: 14),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Apps & Integrations', style: manrope(14, p.text, weight: FontWeight.w800)),
                          Text('${connected.length} connected · ${kApps.length} apps', style: manrope(12, p.text2, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    for (final id in connected.take(3)) ...[AppTile(id: id, size: 28), const SizedBox(width: 4)],
                    AkayaIcon('chev', size: 18, color: p.text3, strokeWidth: 2.4),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.86,
              children: [
                for (final l in links)
                  GestureDetector(
                    onTap: () => context.go(l.$4),
                    child: Container(
                      decoration: glass(p, radius: 18),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Gi(icon: l.$1, tone: l.$2, size: 38, iconSize: 19),
                          const SizedBox(height: 6),
                          Text(l.$3, style: manrope(11.5, p.text, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _h(p, 'Appearance'),
          _card(
            p,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Theme', style: manrope(12, p.text2, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Segmented(
                  full: true,
                  value: model.theme,
                  onChanged: model.setTheme,
                  options: [
                    ('light', const Row(mainAxisAlignment: MainAxisAlignment.center, children: [AkayaIcon('sun', size: 14), SizedBox(width: 4), Text('Light')])),
                    ('dark', const Row(mainAxisAlignment: MainAxisAlignment.center, children: [AkayaIcon('moon', size: 14), SizedBox(width: 4), Text('Dark')])),
                    ('system', const Row(mainAxisAlignment: MainAxisAlignment.center, children: [AkayaIcon('monitor', size: 14), SizedBox(width: 4), Text('System')])),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('Text size', style: manrope(12.5, p.text, weight: FontWeight.w700)),
                    const Spacer(),
                    Text('${(model.textSize * 100).round()}%', style: manrope(12, p.text2, weight: FontWeight.w700)),
                  ],
                ),
                Slider(
                  value: model.textSize,
                  min: 0.9,
                  max: 1.2,
                  divisions: 6,
                  activeColor: AkayaPalette.violet,
                  onChanged: model.setTextSize,
                ),
                Text('Aa · This is how text looks across Akaya.', style: manrope(12.5, p.text2, weight: FontWeight.w600)),
              ],
            ),
          ),
          _h(p, 'Akaya AI'),
          _card(
            p,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('AI mode', style: manrope(12, p.text2, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Segmented(
                  full: true,
                  value: model.mode,
                  onChanged: model.setMode,
                  options: const [
                    ('on-device', Row(mainAxisAlignment: MainAxisAlignment.center, children: [AkayaIcon('chip', size: 14), SizedBox(width: 4), Text('On-device')])),
                    ('online', Row(mainAxisAlignment: MainAxisAlignment.center, children: [AkayaIcon('globe', size: 14), SizedBox(width: 4), Text('Online')])),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  model.mode == 'on-device' ? 'Runs on your phone and works without internet.' : 'Uses cloud models for longer, richer answers.',
                  style: manrope(12, p.text3, weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _row(p, 'float', 'orange', 'Floating bubble', 'Show Akaya over other apps', AkayaToggle(on: model.floating, onChanged: model.setFloating)),
                _row(
                  p,
                  'lang',
                  'green',
                  'Language',
                  'Replies, voice and translation default',
                  DropdownButton<String>(
                    value: model.language,
                    underline: const SizedBox.shrink(),
                    style: manrope(12.5, p.text, weight: FontWeight.w700),
                    items: [
                      for (final l in ['English', 'Hindi', 'Tamil', 'Bengali', 'Marathi']) DropdownMenuItem(value: l, child: Text(l)),
                    ],
                    onChanged: (v) {
                      if (v != null) model.setLanguage(v);
                    },
                  ),
                ),
              ],
            ),
          ),
          _h(p, 'Voice'),
          _card(
            p,
            Column(
              children: [
                Row(
                  children: [
                    Text('Voice speed', style: manrope(12.5, p.text, weight: FontWeight.w700)),
                    const Spacer(),
                    Text('${model.voiceSpeed.toStringAsFixed(2)}×', style: manrope(12, p.text2, weight: FontWeight.w700)),
                  ],
                ),
                Slider(value: model.voiceSpeed, min: 0.75, max: 1.5, divisions: 15, activeColor: AkayaPalette.violet, onChanged: model.setVoiceSpeed),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => model.showToast("Hi Priya! This is how I'll sound."),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AkayaIcon('volume', size: 15, color: p.violetText),
                        const SizedBox(width: 6),
                        Text('Test voice', style: manrope(13, p.violetText, weight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _h(p, 'Notifications'),
          _card(
            p,
            Column(
              children: [
                _row(p, 'bell', 'pink', 'Notifications', 'Reminders, briefs and follow-ups', AkayaToggle(on: model.notificationsOn, onChanged: model.setNotifications)),
                _row(
                  p,
                  'alarm',
                  'violet',
                  'Remind me before',
                  'Default for new reminders',
                  DropdownButton<int>(
                    value: model.reminderLead,
                    underline: const SizedBox.shrink(),
                    style: manrope(12.5, p.text, weight: FontWeight.w700),
                    items: [
                      for (final m in [5, 10, 15, 30, 60]) DropdownMenuItem(value: m, child: Text('$m min')),
                    ],
                    onChanged: (v) {
                      if (v != null) model.setReminderLead(v);
                    },
                  ),
                ),
              ],
            ),
          ),
          _h(p, 'Account'),
          _card(
            p,
            Column(
              children: [
                _nav(context, p, 'help', 'green', 'Support', 'FAQs and contact', '/support'),
                _nav(context, p, 'chart', 'blue', 'Earnings', 'Affiliate clicks and commission (sample data)', '/earnings'),
                GestureDetector(
                  onTap: () => _confirm(context, model),
                  child: _row(p, 'logout', 'orange', 'Log out', 'Clears this device and returns to sign up', AkayaIcon('chev', size: 16, color: p.text3)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Akaya · Your intelligent assistant · v0.5.0', textAlign: TextAlign.center, style: manrope(12, p.text3, weight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _h(AkayaPalette p, String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        child: Text(t, style: manrope(13, p.text2, weight: FontWeight.w800)),
      );

  Widget _card(AkayaPalette p, Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(decoration: glass(p), padding: const EdgeInsets.fromLTRB(14, 12, 14, 12), child: child),
      );

  Widget _row(AkayaPalette p, String icon, String tone, String title, String sub, Widget right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Gi(icon: icon, tone: tone, size: 34, iconSize: 17, radius: 11),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: manrope(13.5, p.text, weight: FontWeight.w800)),
                Text(sub, style: manrope(11.5, p.text2, weight: FontWeight.w600)),
              ],
            ),
          ),
          right,
        ],
      ),
    );
  }

  Widget _nav(BuildContext context, AkayaPalette p, String icon, String tone, String title, String sub, String to) {
    return GestureDetector(onTap: () => context.go(to), child: _row(p, icon, tone, title, sub, AkayaIcon('chev', size: 16, color: p.text3)));
  }

  void _confirm(BuildContext context, AppModel model) {
    showAkayaSheet(
      context,
      title: 'Log out?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your sample notes, chats and settings on this device will be reset.', style: manrope(13.4, paletteOf(context).text2, weight: FontWeight.w600, height: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlineButton(label: 'Cancel', onTap: () => Navigator.pop(context))),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'Log out',
                  onTap: () {
                    Navigator.pop(context);
                    model.logout();
                    model.showToast('Logged out');
                    context.go('/signup');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
