import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/anim_clock.dart';
import '../widgets/chrome.dart';
import '../widgets/pearl.dart';
import '../widgets/spring.dart';

/// Timeline matching React `useStages(marks, loopMs)`.
class StageBox extends StatefulWidget {
  const StageBox({super.key, required this.marks, required this.loopMs, required this.builder});
  final List<int> marks;
  final int loopMs;
  final Widget Function(int stage) builder;

  @override
  State<StageBox> createState() => _StageBoxState();
}

class _StageBoxState extends State<StageBox> {
  int _stage = 0;
  final _timers = <Timer>[];

  int _stageAt(int ms) {
    final t = ms % widget.loopMs;
    var s = 0;
    for (var i = 0; i < widget.marks.length; i++) {
      if (t >= widget.marks[i]) s = i + 1;
    }
    return s;
  }

  @override
  void initState() {
    super.initState();
    if (AnimClock.ms != null) return;
    _run();
  }

  void _run() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    if (!mounted) return;
    if (_stage != 0) {
      setState(() => _stage = 0);
    } else {
      _stage = 0;
    }
    for (var i = 0; i < widget.marks.length; i++) {
      final n = i + 1;
      _timers.add(Timer(Duration(milliseconds: widget.marks[i]), () {
        if (mounted) setState(() => _stage = n);
      }));
    }
    _timers.add(Timer(Duration(milliseconds: widget.loopMs), _run));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frozen = AnimClock.ms;
    if (frozen == null) return widget.builder(_stage);
    final ms = frozen % widget.loopMs;
    return StageClock(ms: ms, child: widget.builder(_stageAt(frozen)));
  }
}

class TypedLine extends StatefulWidget {
  const TypedLine({super.key, required this.text, required this.run, this.cps = 32, this.bornAtMs = 0, required this.style});
  final String text;
  final bool run;
  final double cps;
  final int bornAtMs;
  final TextStyle style;

  @override
  State<TypedLine> createState() => _TypedLineState();
}

class _TypedLineState extends State<TypedLine> {
  int _n = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(TypedLine old) {
    super.didUpdateWidget(old);
    if (old.run != widget.run || old.text != widget.text) _sync();
  }

  void _sync() {
    _t?.cancel();
    if (!widget.run) {
      setState(() => _n = 0);
      return;
    }
    _n = 0;
    _t = Timer.periodic(Duration(milliseconds: (1000 / widget.cps).round()), (t) {
      if (!mounted) return;
      setState(() => _n++);
      if (_n >= widget.text.length) t.cancel();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clock = StageClock.maybeOf(context);
    final n = clock == null
        ? _n
        : (!widget.run
            ? 0
            : ((clock - widget.bornAtMs) * widget.cps / 1000).floor().clamp(0, widget.text.length));
    final shown = widget.run ? widget.text.substring(0, n.clamp(0, widget.text.length)) : '';
    return Text.rich(TextSpan(children: [
      TextSpan(text: shown, style: widget.style),
      if (widget.run && n < widget.text.length) const TextSpan(text: '▍', style: TextStyle(color: Color(0xFFE8743B))),
    ]));
  }
}

class SlideFloating extends StatelessWidget {
  const SlideFloating({super.key});

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return StageBox(
      marks: const [350, 900, 1600, 3300, 3900],
      loopMs: 7600,
      builder: (s) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: const Alignment(0, -0.15),
              child: SpringReveal(
                dy: 40,
                bornAtMs: 0,
                child: Container(
                  width: 280,
                  decoration: glass(p, radius: 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: Row(children: [
                          AkayaIcon('back', size: 16, color: p.text2),
                          const SizedBox(width: 8),
                          CircleAvatar(radius: 14, backgroundColor: const Color(0xFF25D366), child: Text('R', style: manrope(12, Colors.white, weight: FontWeight.w800))),
                          const SizedBox(width: 8),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Rahul', style: manrope(13, p.text, weight: FontWeight.w800)),
                            Text('online', style: manrope(10, p.greenText, weight: FontWeight.w700)),
                          ])),
                          AkayaIcon('dots', size: 16, color: p.text3),
                        ]),
                      ),
                      if (s >= 1)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SpringReveal(
                            fromScale: 0.8,
                            bornAtMs: 350,
                            stiffness: 550,
                            damping: 30,
                            opacityMs: 300,
                            child: Container(
                            margin: const EdgeInsets.fromLTRB(12, 0, 48, 8),
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                            decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(14)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text("Can we move tomorrow's call to 4 PM?", style: manrope(12.5, p.text, weight: FontWeight.w600)),
                              Text('10:42', style: manrope(9, p.text3)),
                            ]),
                          ),
                          ),
                        ),
                      if (s >= 2 && s < 5)
                        SpringReveal(
                          fromScale: 0.6,
                          bornAtMs: 900,
                          child: Container(
                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: p.tint('violet'), borderRadius: BorderRadius.circular(99)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            AkayaIcon('mic', size: 13, color: p.violetText),
                            const SizedBox(width: 6),
                            WaveBars(color: p.violetText, height: 16, heights: const [0.4, 0.8, 1, 0.7, 0.5]),
                            const SizedBox(width: 6),
                            Text('हाँ, 4 बजे ठीक है', style: manrope(12, p.text, weight: FontWeight.w700)),
                          ]),
                        ),
                        ),
                      if (s >= 5)
                        Align(
                          alignment: Alignment.centerRight,
                          child: SpringReveal(
                            dx: 40,
                            bornAtMs: 3900,
                            child: Container(
                            margin: const EdgeInsets.fromLTRB(48, 0, 12, 8),
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                            decoration: BoxDecoration(gradient: p.brand, borderRadius: BorderRadius.circular(14)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text('Sure, 4 PM works for me. Talk then!', style: manrope(12.5, Colors.white, weight: FontWeight.w600)),
                              Text('10:43 ✓✓', style: manrope(9, Colors.white70)),
                            ]),
                          ),
                          ),
                        ),
                      if (s >= 3 && s < 5)
                        SpringReveal(
                          dy: 30,
                          bornAtMs: 1600,
                          child: Container(
                          margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: p.surfaceSolid, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              _tag(p, 'DRAFT', 'violet'),
                              const SizedBox(width: 6),
                              SpringReveal(
                                fromScale: 0,
                                fromOpacity: 1,
                                delay: const Duration(milliseconds: 300),
                                bornAtMs: 1600,
                                child: _tag(p, 'HINDI → ENGLISH', 'green'),
                              ),
                            ]),
                            const SizedBox(height: 6),
                            TypedLine(text: 'Sure, 4 PM works for me. Talk then!', run: s >= 3, cps: 30, bornAtMs: 1600, style: manrope(13, p.text, weight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Spacer(),
                              Text('Edit', style: manrope(12, p.text2, weight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              Builder(builder: (context) {
                                final now = StageClock.maybeOf(context);
                                final scale = s == 4 && now != null ? keyframeScale((now - 3300).toDouble()) : 1.0;
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(gradient: p.gOrange, borderRadius: BorderRadius.circular(12)),
                                    child: Row(children: [Text('Send', style: manrope(12, Colors.white, weight: FontWeight.w800)), const SizedBox(width: 4), const AkayaIcon('send', size: 13, color: Colors.white)]),
                                  ),
                                );
                              }),
                            ]),
                          ]),
                        ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (s == 4) ...[
              const Positioned(
                right: 36,
                bottom: 118,
                child: LinearReveal(bornAtMs: 3300, dx: 60, dy: 60, ms: 350, child: _Finger()),
              ),
              const Positioned(
                right: 28,
                bottom: 108,
                child: EaseReveal(
                  bornAtMs: 3300,
                  delayMs: 300,
                  ms: 600,
                  fromScale: 0.3,
                  toScale: 1.6,
                  fromOpacity: 0.9,
                  toOpacity: 0,
                  child: _Ripple(),
                ),
              ),
            ],
            Positioned(
              right: 8,
              bottom: 28,
              child: SpringReveal(
                dx: 120,
                fromOpacity: 1,
                delay: const Duration(milliseconds: 200),
                bornAtMs: 0,
                child: Pearl(
                  width: 96,
                  height: 96,
                  radius: 30,
                  shadow: false,
                  mood: s >= 5 ? PearlMood.happy : (s >= 3 ? PearlMood.thinking : PearlMood.idle),
                  gaze: const Offset(-0.7, 0.25),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 18,
              child: Wrap(spacing: 6, children: [
                _chip(p, 'float', 'Floating on'),
                _chip(p, 'chat', 'WhatsApp', color: const Color(0xFF25D366)),
                _chip(p, 'mail', 'Gmail', color: AkayaPalette.blue),
              ]),
            ),
          ],
        );
      },
    );
  }

  Widget _tag(AkayaPalette p, String t, String tone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: p.tint(tone), borderRadius: BorderRadius.circular(99)),
      child: Text(t, style: manrope(9, tone == 'green' ? p.greenText : AkayaPalette.violet, weight: FontWeight.w800, letterSpacing: 0.4)),
    );
  }

  Widget _chip(AkayaPalette p, String icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: glass(p, radius: 99),
      child: Row(mainAxisSize: MainAxisSize.min, children: [AkayaIcon(icon, size: 12, color: color ?? p.text), const SizedBox(width: 4), Text(label, style: manrope(11, color ?? p.text, weight: FontWeight.w700))]),
    );
  }
}

class _Finger extends StatelessWidget {
  const _Finger();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(34, 40), painter: _FingerPainter());
  }
}

class _FingerPainter extends CustomPainter {
  static final _path = Path()
    ..moveTo(10, 4.5)
    ..relativeCubicTo(0, -2, 3.4, -2, 3.4, 0)
    ..relativeLineTo(0, 13)
    ..relativeLineTo(2.2, -1)
    ..relativeCubicTo(1.4, -0.6, 2.8, 0.2, 3, 1.4)
    ..relativeLineTo(0.2, 0.6)
    ..relativeLineTo(1.6, -0.6)
    ..relativeCubicTo(1.3, -0.4, 2.7, 0.4, 2.9, 1.5)
    ..relativeLineTo(1.7, -0.5)
    ..relativeCubicTo(1.4, -0.3, 2.8, 0.6, 2.8, 2)
    ..relativeLineTo(0, 7.6)
    ..relativeCubicTo(0, 6, -4, 10, -10, 10)
    ..relativeLineTo(-1.2, 0)
    ..relativeCubicTo(-3.3, 0, -5.7, -1.4, -7.6, -4)
    ..lineTo(3.4, 25.6)
    ..relativeCubicTo(-1, -1.5, 0.7, -3.4, 2.4, -2.4)
    ..lineTo(10, 26)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_path, Paint()..color = Colors.white);
    canvas.drawPath(
      _path,
      Paint()
        ..color = const Color(0xFF2A2B45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Ripple extends StatelessWidget {
  const _Ripple();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE8743B), width: 2),
      ),
    );
  }
}

class SlideVoice extends StatelessWidget {
  const SlideVoice({super.key});

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return StageBox(
      marks: const [200, 2300, 2800, 3300],
      loopMs: 8000,
      builder: (s) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pearl(width: 200, height: 150, radius: 48, mood: s < 2 ? PearlMood.listening : PearlMood.happy, scene: false),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(12),
              decoration: glass(p, radius: 16),
              child: SpringReveal(
                dy: -10,
                fromOpacity: 0,
                bornAtMs: 200,
                stiffness: 500,
                damping: 25,
                opacityMs: 300,
                child: TypedLine(
                  text: '"Remind me to call Rahul at 5, and follow up with Neha tomorrow"',
                  run: s >= 1,
                  cps: 34,
                  bornAtMs: 200,
                  style: manrope(13, p.text, weight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            WaveBars(color: p.violetText, height: 28, heights: const [0.3, 0.6, 0.9, 0.5, 1, 0.4, 0.8, 0.55, 0.95, 0.35, 0.7, 1, 0.45, 0.85, 0.5, 0.75, 0.4]),
            if (s >= 2)
              SpringReveal(
                dy: -40,
                fromRotate: -6,
                toRotate: -1.5,
                bornAtMs: 2300,
                child: _res(p, 'alarm', 'orange', 'Call Rahul', 'Today · 5:00 PM', 'Reminder set', p.greenText),
              ),
            if (s >= 3)
              SpringReveal(
                dy: -40,
                fromRotate: 6,
                toRotate: 1.2,
                bornAtMs: 2800,
                child: _res(p, 'follow', 'green', 'Follow up with Neha', 'Tomorrow · 10:00 AM', 'Follow-up', AkayaPalette.blue),
              ),
          ],
        );
      },
    );
  }

  Widget _res(AkayaPalette p, String icon, String tone, String title, String sub, String tag, Color tagColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: glass(p, radius: 16),
      child: Row(children: [
        Gi(icon: icon, tone: tone, size: 36, iconSize: 18),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: manrope(13, p.text, weight: FontWeight.w800)), Text(sub, style: manrope(11, p.text2))])),
        Text(tag, style: manrope(11, tagColor, weight: FontWeight.w800)),
      ]),
    );
  }
}

class SlideTranslate extends StatefulWidget {
  const SlideTranslate({super.key});
  @override
  State<SlideTranslate> createState() => _SlideTranslateState();
}

class _SlideTranslateState extends State<SlideTranslate> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();

  static const _chips = [('नमस्ते', 'Hindi'), ('Hola', 'Español'), ('こんにちは', '日本語'), ('வணக்கம்', 'Tamil'), ('Bonjour', 'Français'), ('مرحبا', 'Arabic')];
  static const _pairs = [
    ('आप कैसे हैं? चलो कल मिलते हैं।', "How are you? Let's meet tomorrow."),
    ('¿Dónde está la estación de metro?', 'Where is the metro station?'),
    ('மிக்க நன்றி!', 'Thank you so much!'),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = AnimClock.seconds();
        final pair = _pairs[(t / 3.2).floor() % _pairs.length];
        final showEn = t % 3.2 > 1.2;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Pearl(width: 220, height: 160, radius: 46, scene: true, gaze: Offset(math.cos(t * 0.35) * 0.6, math.sin(t * 0.35) * 0.2)),
                  for (var i = 0; i < _chips.length; i++)
                    _orbit(p, t, i, _chips[i].$1, _chips[i].$2),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(12),
              decoration: glass(p, radius: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _pill(p, showEn ? 'Detected' : 'Hindi'),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('⇄')),
                  _pill(p, 'English'),
                  const Spacer(),
                  AkayaIcon('mic', size: 15, color: p.text3),
                ]),
                const SizedBox(height: 8),
                Text(pair.$1, style: manrope(13, p.text, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(showEn ? pair.$2 : '· · ·', style: manrope(13, p.greenText, weight: FontWeight.w700)),
              ]),
            ),
          ],
        );
      },
    );
  }

  Widget _orbit(AkayaPalette p, double t, int i, String word, String label) {
    final a = t * 0.35 + (i / _chips.length) * math.pi * 2;
    final x = math.cos(a) * 110;
    final y = math.sin(a) * 62;
    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: glass(p, radius: 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [Text(word, style: manrope(12, p.text, weight: FontWeight.w800)), Text(label, style: manrope(9, p.text3))]),
      ),
    );
  }

  Widget _pill(AkayaPalette p, String t) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(99)), child: Text(t, style: manrope(11, p.text, weight: FontWeight.w700)));
  }
}

class SlideFuture extends StatelessWidget {
  const SlideFuture({super.key});

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return StageBox(
      marks: const [200, 2600, 3200, 3900],
      loopMs: 8200,
      builder: (s) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Pearl(width: 88, height: 88, radius: 28, mood: s >= 4 ? PearlMood.happy : PearlMood.idle, gaze: const Offset(0.5, 0.3), shadow: false),
              const SizedBox(width: 8),
              SpringReveal(
                fromScale: 0.6,
                delay: const Duration(milliseconds: 300),
                bornAtMs: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: glass(p, radius: 14),
                  child: Text(s >= 4 ? 'Scheduled! ✓' : "I'll send it at midnight", style: manrope(12.5, p.text, weight: FontWeight.w800)),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            SpringReveal(
              dy: 30,
              bornAtMs: 0,
              child: Container(
              width: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: glass(p, radius: 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(radius: 14, backgroundColor: p.tint('pink'), child: Text('N', style: manrope(12, AkayaPalette.pink, weight: FontWeight.w800))),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TO', style: manrope(9, p.text3, weight: FontWeight.w800)), Text('Neha', style: manrope(13, p.text, weight: FontWeight.w800))])),
                  Text('Future Message', style: manrope(10, p.orangeText, weight: FontWeight.w800)),
                ]),
                const SizedBox(height: 8),
                TypedLine(text: 'Happy birthday, Neha! Wishing you a year full of laughter and big wins 🎉', run: s >= 1, cps: 36, bornAtMs: 200, style: manrope(13, p.text, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _when(p, 'cal', 'DATE', s >= 2 ? 'Fri, 9 Oct' : 'Pick date')),
                  const SizedBox(width: 8),
                  Expanded(child: _when(p, 'clock', 'TIME', s >= 2 ? '12:00 AM' : 'Pick time')),
                ]),
                const SizedBox(height: 8),
                Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: p.gOrange, borderRadius: BorderRadius.circular(12)),
                  child: Text(s >= 4 ? 'Scheduled · sends in 14 h' : 'Schedule send', style: manrope(13, Colors.white, weight: FontWeight.w800)),
                ),
              ]),
            ),
            ),
          ],
        );
      },
    );
  }

  Widget _when(AkayaPalette p, String icon, String k, String v) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [AkayaIcon(icon, size: 16, color: p.text2), const SizedBox(width: 6), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k, style: manrope(9, p.text3, weight: FontWeight.w800)), Text(v, style: manrope(12, p.text, weight: FontWeight.w800))])]),
    );
  }
}

class SlideAgents extends StatelessWidget {
  const SlideAgents({super.key});

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    const steps = [('clock', 'blue', 'Every day at 8:00 AM', 'Trigger'), ('mail', 'violet', 'Check mails & calendar', 'Gmail · Calendar'), ('spark', 'orange', 'Send me a 1-min brief', 'Voice + text')];
    const chips = [('alarm', 'orange', 'Bill reminders'), ('follow', 'green', 'Follow-up nudges'), ('note', 'cyan', 'Daily notes'), ('chat', 'violet', 'Auto-reply drafts')];
    return StageBox(
      marks: const [500, 1000, 1500, 2000, 2700],
      loopMs: 9000,
      builder: (s) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pearl(width: 100, height: 90, radius: 32, mood: s >= 4 ? PearlMood.happy : PearlMood.idle, gaze: const Offset(0.6, 0.35), shadow: false),
            SpringReveal(
              dx: 40,
              bornAtMs: 0,
              child: Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: glass(p, radius: 18),
              child: Column(children: [
                Row(children: [
                  const Gi(icon: 'agent', tone: 'violet', size: 32, iconSize: 16, radius: 11),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Morning brief', style: manrope(13.5, p.text, weight: FontWeight.w800)), Text(s >= 1 ? '● Active' : '● Paused', style: manrope(11, s >= 1 ? p.greenText : p.text3, weight: FontWeight.w700))])),
                  AkayaToggle(on: s >= 1, onChanged: (_) {}),
                ]),
                const SizedBox(height: 8),
                for (var i = 0; i < steps.length; i++)
                  Opacity(
                    opacity: s >= i + 2 ? 1 : 0.45,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [Gi(icon: steps[i].$1, tone: steps[i].$2, size: 30, iconSize: 15, radius: 10), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(steps[i].$3, style: manrope(12.5, p.text, weight: FontWeight.w800)), Text(steps[i].$4, style: manrope(11, p.text2))])]),
                    ),
                  ),
              ]),
            ),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
              for (var i = 0; i < chips.length; i++)
                SpringReveal(
                  dy: 20,
                  delay: Duration(milliseconds: 800 + i * 120),
                  bornAtMs: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: glass(p, radius: 12),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      AkayaIcon(chips[i].$1, size: 14, color: p.text),
                      const SizedBox(width: 4),
                      Text(chips[i].$3, style: manrope(11.5, p.text, weight: FontWeight.w700)),
                    ]),
                  ),
                ),
            ]),
            if (s >= 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [AkayaIcon('chip', size: 13, color: p.greenText), const SizedBox(width: 4), Text('Offline mode: on-device AI works without internet', style: manrope(11.5, p.text, weight: FontWeight.w700))]),
              ),
          ],
        );
      },
    );
  }
}
