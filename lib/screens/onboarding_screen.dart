import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/model.dart';
import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/chrome.dart';
import 'onboarding_art.dart';

class _Slide {
  const _Slide(this.kick, this.title, this.body, this.tint);
  final String kick;
  final String title;
  final String body;
  final List<Color> tint;
}

const _slides = [
  _Slide('Floating reply', 'Reply on any app,\nin any language', 'Akaya floats over WhatsApp, Gmail and more. Speak Hindi, send polished English in one tap.', [Color(0x73FFAA78), Color(0x8CC8B4FF)]),
  _Slide('Voice reminders', "Just say it.\nI'll remember.", 'Set reminders and follow-ups by voice. Akaya nudges you at the right time, so nothing slips.', [Color(0x8C96C8FF), Color(0x80D2AAFF)]),
  _Slide('99+ languages', 'Talk to anyone in\n99+ languages', 'Translate text, voice and chats instantly, from Hindi and Tamil to Spanish, Japanese and many more.', [Color(0x7378E6BE), Color(0x8CA0C8FF)]),
  _Slide('Future Message', 'Write it now,\nsend it later', 'Schedule wishes, nudges and updates. Akaya sends them right on time.', [Color(0x80FFAAD7), Color(0x8CC8B4FF)]),
  _Slide('AI Agents', 'Agents that handle\nyour daily tasks', 'Create agents that run your routines every day, automatically.', [Color(0x8CAA8CFF), Color(0x8082D2FF)]),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.start = 0});
  final int start;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final _page = PageController(initialPage: widget.start.clamp(0, 4));
  int _i = 0;

  @override
  void initState() {
    super.initState();
    _i = widget.start.clamp(0, 4);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _done() {
    AkayaScope.of(context).finishOnboarding();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final s = _slides[_i];
    final last = _i == _slides.length - 1;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(center: const Alignment(0.7, -0.4), radius: 0.9, colors: [s.tint[0], Colors.transparent]),
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 18, 0),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const AkayaLogo(size: 21),
                    const Spacer(),
                    if (!last)
                      GestureDetector(
                        onTap: _done,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: glass(p, radius: 99),
                          child: Text('Skip', style: manrope(12.8, p.text, weight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _i = i),
                itemBuilder: (context, i) {
                  return Column(
                    children: [
                      Expanded(child: _art(i)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_slides[i].kick.toUpperCase(), style: manrope(10.9, p.orangeText, weight: FontWeight.w800, letterSpacing: 1.4)),
                            const SizedBox(height: 8),
                            Text(_slides[i].title, style: comfortaa(26, p.text, height: 1.22)),
                            const SizedBox(height: 10),
                            Text(_slides[i].body, style: manrope(13.4, p.text2, weight: FontWeight.w600, height: 1.55)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 8, 22, 26),
              child: Row(
                children: [
                  Row(
                    children: [
                      for (var k = 0; k < _slides.length; k++)
                        GestureDetector(
                          onTap: () => _page.animateToPage(k, duration: const Duration(milliseconds: 320), curve: Curves.easeOut),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: k == _i ? 18 : 7,
                            height: 7,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(color: k == _i ? AkayaPalette.orange : p.lineStrong, borderRadius: BorderRadius.circular(9)),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (last) {
                        _done();
                      } else {
                        _page.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
                      }
                    },
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(gradient: p.gOrange, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0xBFE8743B), blurRadius: 20, offset: Offset(0, 10), spreadRadius: -8)]),
                      child: Row(
                        children: [
                          Text(last ? 'Get started' : 'Next', style: manrope(15, Colors.white, weight: FontWeight.w800)),
                          const SizedBox(width: 6),
                          const AkayaIcon('chev', size: 18, color: Colors.white, strokeWidth: 2.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _art(int i) {
    return switch (i) {
      0 => const SlideFloating(),
      1 => const SlideVoice(),
      2 => const SlideTranslate(),
      3 => const SlideFuture(),
      _ => const SlideAgents(),
    };
  }
}
