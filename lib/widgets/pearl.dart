import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'anim_clock.dart';

enum PearlMood { idle, happy, listening, thinking, sleeping }

/// Live Akaya pearl, ported from packages/ui/src/lib/pearl.ts + Pearl.tsx.
class Pearl extends StatefulWidget {
  const Pearl({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
    this.cx,
    this.cy,
    this.mood = PearlMood.idle,
    this.scene = false,
    this.glow,
    this.shadow = true,
    this.interactive = false,
    this.onTap,
    this.dark = false,
    this.label = 'Akaya pearl',
    this.gaze,
  });

  final double width;
  final double height;
  final double radius;
  final double? cx;
  final double? cy;
  final PearlMood mood;
  final bool scene;
  final double? glow;
  final bool shadow;
  final bool interactive;
  final VoidCallback? onTap;
  final bool dark;
  final String label;
  /// Overrides the idle gaze, matching React `gaze={{ x, y }}` in −1..1.
  final Offset? gaze;

  @override
  State<Pearl> createState() => _PearlState();
}

class _PearlState extends State<Pearl> with SingleTickerProviderStateMixin {
  late final AnimationController _tick;
  double _tapAt = -10;
  final _rng = Mulberry32(1);
  double _simT = 0;
  double _nextBlink = 1.5;
  double _blinkStart = -10;
  double _listen = 0;
  double _level = 0;

  @override
  void initState() {
    super.initState();
    _tick = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _tick.dispose();
    super.dispose();
  }

  void _resetSim() {
    _rng.reseed(1);
    _simT = 0;
    _nextBlink = 1.5;
    _blinkStart = -10;
    _listen = 0;
    _level = 0;
  }

  /// Steps the React rAF loop at 60Hz so blink / listen match a seeded capture.
  void _sync(bool listening) {
    final target = AnimClock.seconds();
    if (target + 1e-6 < _simT) _resetSim();
    const dt = 1 / 60.0;
    var guard = 0;
    while (_simT + dt <= target + 1e-8 && guard++ < 200000) {
      _simT += dt;
      if (_simT > _nextBlink) {
        _blinkStart = _simT;
        _nextBlink = _simT + 2.4 + _rng.next() * 3.6;
      }
      _listen += ((listening ? 1.0 : 0.0) - _listen) * 0.12;
      final lvl = listening ? 0.3 + 0.25 * math.sin(_simT * 3.1) * math.sin(_simT * 1.7) : 0.0;
      _level += (lvl - _level) * 0.25;
    }
  }

  double _openAt(double t) {
    final bt = (t - _blinkStart) / 0.18;
    if (bt >= 0 && bt < 1) return (1 - 2 * bt).abs();
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final listening = widget.mood == PearlMood.listening;
    return GestureDetector(
      onTap: widget.interactive || widget.onTap != null
          ? () {
              _tapAt = AnimClock.seconds();
              widget.onTap?.call();
            }
          : null,
      child: AnimatedBuilder(
        animation: _tick,
        builder: (context, _) {
          _sync(listening);
          final t = AnimClock.seconds();
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _PearlPainter(
              t: t,
              tapAt: _tapAt,
              open: _openAt(t),
              listen: _listen,
              level: _level,
              radius: widget.radius,
              cx: widget.cx ?? widget.width / 2,
              cy: widget.cy ?? widget.height / 2,
              mood: widget.mood,
              scene: widget.scene,
              glow: widget.glow,
              shadow: widget.shadow,
              dark: widget.dark,
              gaze: widget.gaze,
            ),
          );
        },
      ),
    );
  }
}

class _PearlPainter extends CustomPainter {
  _PearlPainter({
    required this.t,
    required this.tapAt,
    required this.open,
    required this.listen,
    required this.level,
    required this.radius,
    required this.cx,
    required this.cy,
    required this.mood,
    required this.scene,
    required this.glow,
    required this.shadow,
    required this.dark,
    this.gaze,
  });

  final double t;
  final double tapAt;
  final double open;
  final double listen;
  final double level;
  final double radius;
  final double cx;
  final double cy;
  final PearlMood mood;
  final bool scene;
  final double? glow;
  final bool shadow;
  final bool dark;
  final Offset? gaze;

  @override
  void paint(Canvas canvas, Size size) {
    final sleeping = mood == PearlMood.sleeping;
    final float = sleeping ? 0.0 : math.sin(t * 1.5) * radius * 0.035;
    final breathe = sleeping ? 1 + 0.025 * math.sin(t * 1.4) : 1.0;
    final age = t - tapAt;
    final squash = age > 0 && age < 1 ? math.exp(-age * 6) * math.sin(age * 22) : 0.0;
    final happy = mood == PearlMood.happy || (age > 0 && age < 1.4);
    var gx = gaze?.dx ?? 0.32 * math.sin(t * 0.31) * math.sin(t * 0.17 + 1);
    var gy = gaze?.dy ?? 0.12 * math.sin(t * 0.23) + 0.05;
    var lid = 0.0;
    var lidA = 0.0;
    if (mood == PearlMood.thinking) {
      gx = -0.35 + 0.15 * math.sin(t * 0.8);
      gy = -0.45;
      lid = 0.38;
      lidA = 0.6;
    }
    final cyF = cy + float;

    if (scene) {
      _ring(canvas, cx, cy, radius, -0.3, 1.62, 0.34, 1, false);
      _ring(canvas, cx, cy, radius, 0.38, 1.42, 0.27, 0.6, false);
      _minis(canvas, cx, cyF, radius, false);
    }
    _drawPearl(
      canvas,
      cx,
      cyF,
      radius,
      t * 0.6 + 3,
      sleeping ? 1 : open,
      sleeping,
      happy,
      listen,
      level.abs(),
      (1 + 0.1 * squash) / math.sqrt(breathe),
      (1 - 0.12 * squash) * breathe,
      gx,
      gy,
      lid,
      lidA,
      (glow ?? (scene ? (dark ? 0.6 : 0.5) : 0.35)) * (sleeping ? 0.6 : 1),
      shadow,
      false,
    );
    if (scene) {
      _ring(canvas, cx, cy, radius, -0.3, 1.62, 0.34, 1, true);
      _ring(canvas, cx, cy, radius, 0.38, 1.42, 0.27, 0.6, true);
      _minis(canvas, cx, cyF, radius, true);
      const stars = [
        [-1.55, -0.15, 0.07],
        [1.6, -0.45, 0.055],
        [1.05, -1.1, 0.045],
        [-1.15, -1.05, 0.04],
        [1.3, 1.0, 0.045],
      ];
      for (var i = 0; i < stars.length; i++) {
        final s = stars[i];
        _star(canvas, cx + s[0] * radius, cy + s[1] * radius, s[2] * radius, 0.45 + 0.45 * math.sin(t * 2 + i * 1.7));
      }
    }
    if (sleeping) {
      final zt = (t * 0.5) % 1;
      final tp = TextPainter(
        text: TextSpan(
          text: 'z',
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: radius * 0.28,
            fontWeight: FontWeight.w700,
            color: (dark ? const Color(0xCCDCD2FF) : const Color(0xB35A46B4)).withValues(alpha: 1 - zt),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx + radius * (0.85 + zt * 0.3), cy - radius * (0.7 + zt * 0.4)));
    }
  }

  void _minis(Canvas canvas, double cx, double cy, double r, bool front) {
    const minis = [
      [3.6, 1.5, 0.5, -0.3, 0.13, 0.16],
      [5.4, 1.25, 0.75, 0.38, 0.085, -0.12],
      [0.6, 1.42, 0.42, -0.3, 0.15, 0.16],
      [2.1, 1.2, 0.6, 0.38, 0.07, -0.12],
    ];
    for (var i = 0; i < minis.length; i++) {
      final m = minis[i];
      final a = m[0] + t * m[5];
      final isFront = math.sin(a) > 0;
      if (isFront != front) continue;
      final x0 = math.cos(a) * m[1] * r;
      final y0 = math.sin(a) * m[2] * r;
      final x = cx + x0 * math.cos(m[3]) - y0 * math.sin(m[3]);
      final y = cy + x0 * math.sin(m[3]) + y0 * math.cos(m[3]);
      _drawPearl(canvas, x, y, m[4] * r * (front ? 1.08 : 0.92), t + i, 1, false, false, 0, 0, 1, 1, 0, 0, 0, 0, 0.12, false, true);
    }
  }

  Path _super(double rx, double ry) {
    const n = 2.08;
    const m = 72;
    final path = Path();
    for (var i = 0; i <= m; i++) {
      final th = (i / m) * math.pi * 2;
      final co = math.cos(th);
      final si = math.sin(th);
      final e = 2 / n;
      final x = rx * co.sign * math.pow(co.abs(), e);
      final y = ry * si.sign * math.pow(si.abs(), e);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _blurLayer(Canvas canvas, double sigma, Rect bounds, void Function() draw) {
    final pad = sigma * 3;
    canvas.saveLayer(
      bounds.inflate(pad),
      Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal),
    );
    draw();
    canvas.restore();
  }

  /// Thin-film bezier bands. Stroke alphas already include ~0.55; film is 0.25.
  void _filmBands(Canvas canvas, double rx, double ry, double t) {
    const film = 0.25;
    final bands = <(List<double>, List<double>, List<double>, List<double>, Color, double)>[
      ([-0.85, -0.1], [-0.4, -0.75], [0.35, -0.55], [0.8, 0.05], Color.fromRGBO(255, 120, 215, 0.55), 0.16),
      ([-0.75, 0.45], [-0.2, 0.05], [0.3, 0.55], [0.75, 0.6], Color.fromRGBO(90, 210, 255, 0.55), 0.14),
      ([-0.3, 0.85], [0.1, 0.55], [0.55, 0.2], [0.85, -0.3], Color.fromRGBO(170, 120, 255, 0.45), 0.12),
    ];
    final bounds = Rect.fromLTRB(-rx * 1.5, -ry * 1.5, rx * 1.5, ry * 1.5);
    _blurLayer(canvas, rx * 0.07, bounds, () {
      for (var i = 0; i < bands.length; i++) {
        final b = bands[i];
        final d = math.sin(t * 0.6 + i) * 0.05;
        final path = Path()
          ..moveTo(b.$1[0] * rx, (b.$1[1] + d) * ry)
          ..cubicTo(b.$2[0] * rx, (b.$2[1] - d) * ry, b.$3[0] * rx, (b.$3[1] + d) * ry, b.$4[0] * rx, b.$4[1] * ry);
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = rx * b.$6
            ..color = b.$5.withValues(alpha: b.$5.a * film),
        );
      }
    });
  }

  void _blob(Canvas canvas, double rx, double ry, double x, double y, double r, Color color, double a) {
    final center = Offset(x * rx, y * ry);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        r * rx,
        [color.withValues(alpha: a), color.withValues(alpha: 0)],
        [0, 1],
      );
    canvas.drawRect(Rect.fromCircle(center: Offset.zero, radius: rx * 2), paint);
  }

  void _drawPearl(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double t,
    double open,
    bool closed,
    bool happy,
    double listen,
    double level,
    double sx,
    double sy,
    double gx,
    double gy,
    double lid,
    double lidA,
    double glowAmt,
    bool shadow,
    bool noEyes,
  ) {
    final rx = r;
    final ry = r * 0.97;
    canvas.save();
    canvas.translate(cx, cy);

    final ga = glowAmt + listen * 0.45 + level * 0.25;
    if (ga > 0.01) {
      final gr = rx * (1.75 + listen * 0.35 + level * 0.25);
      final glowCenter = Offset(0, ry * 0.05);
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          glowCenter,
          gr,
          [
            Color.fromRGBO(170, 150, 255, (ga * 0.8).clamp(0, 1)),
            Color.fromRGBO(120, 190, 255, (ga * 0.35).clamp(0, 1)),
            const Color.fromRGBO(120, 190, 255, 0),
          ],
          [0, 0.45, 1],
          TileMode.clamp,
          null,
          glowCenter,
          rx * 0.3,
        )
        ..blendMode = dark ? BlendMode.screen : BlendMode.srcOver;
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: gr * 2, height: gr * 2), paint);
    }

    if (listen > 0.01) {
      for (var i = 0; i < 3; i++) {
        final ph = (t * 0.85 + i / 3) % 1;
        final k = 1.06 + ph * (0.7 + level * 0.45);
        canvas.drawPath(
          _super(rx * k, ry * k),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rx * (0.022 + level * 0.03)
            ..color = Color.fromRGBO(190, 170, 255, ((1 - ph) * (0.35 + level * 0.55) * listen).clamp(0.0, 1.0)),
        );
      }
    }

    if (shadow) {
      canvas.save();
      canvas.translate(0, ry * 1.12);
      canvas.scale(1, 0.22);
      final sw = rx * 0.9;
      canvas.drawCircle(
        Offset.zero,
        sw,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset.zero,
            sw,
            [const Color(0x47141432), const Color(0x00141432)],
          ),
      );
      canvas.restore();
    }

    final piv = ry * 0.85;
    canvas.translate(0, piv);
    canvas.scale(sx, sy);
    canvas.translate(0, -piv);

    canvas.save();
    canvas.clipPath(_super(rx, ry));
    final body = Rect.fromLTRB(-rx * 1.3, -rx * 1.3, rx * 1.3, rx * 1.3);
    canvas.drawRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD7C6FF), Color(0xFFBBA2FF), Color(0xFFB08CFF)],
          stops: [0, 0.5, 1],
        ).createShader(Rect.fromLTRB(-rx, -ry, rx, ry)),
    );
    final swv = math.sin(t * 0.7) * 0.07;
    final sw2 = math.cos(t * 0.55) * 0.06;
    _blob(canvas, rx, ry, -0.22 + swv, 0.12 + sw2, 0.72, const Color.fromRGBO(60, 185, 255, 1), 0.92);
    _blob(canvas, rx, ry, -0.72, 0.28, 0.5, const Color.fromRGBO(90, 120, 255, 1), 0.55);
    _blob(canvas, rx, ry, 0.56 + sw2, -0.42, 0.56, const Color.fromRGBO(255, 95, 200, 1), 0.88);
    _blob(canvas, rx, ry, 0.58, 0.55 - swv, 0.56, const Color.fromRGBO(220, 80, 255, 1), 0.8);
    _blob(canvas, rx, ry, 0.02, 0.84, 0.5, const Color.fromRGBO(150, 100, 255, 1), 0.55);
    _blob(canvas, rx, ry, -0.58, 0.72, 0.36, const Color.fromRGBO(255, 150, 220, 1), 0.5);
    _blob(canvas, rx, ry, 0.12, -0.12 - swv, 0.36, const Color.fromRGBO(235, 225, 255, 1), 0.35);
    _blob(canvas, rx, ry, -0.48, -0.55, 0.3, const Color.fromRGBO(255, 255, 255, 1), 0.5);

    _filmBands(canvas, rx, ry, t);
    // Conic film at globalAlpha 0.5, composited with soft-light. The layer
    // colour is white so only the alpha (0.5) modulates the sweep.
    canvas.saveLayer(
      body,
      Paint()
        ..color = const Color(0x80FFFFFF)
        ..blendMode = BlendMode.softLight,
    );
    canvas.drawRect(
      body,
      Paint()
        ..shader = ui.Gradient.sweep(
          Offset(-rx * 0.08, -ry * 0.05),
          const [
            Color(0xFF7FE3FF),
            Color(0xFFA77BFF),
            Color(0xFFFF79D2),
            Color(0xFF6F9CFF),
            Color(0xFFC2FFF0),
            Color(0xFF7FE3FF),
          ],
          const [0, 0.18, 0.4, 0.6, 0.8, 1],
          TileMode.clamp,
          t * 0.3,
          t * 0.3 + math.pi * 2,
        ),
    );
    canvas.restore();

    canvas.drawRect(
      body,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(-rx * 0.35, -ry * 0.45),
          rx * 1.8,
          const [Color(0x29FFFFFF), Color(0x00785ADC), Color(0x385032BE)],
          const [0, 0.55, 1],
        ),
    );
    canvas.drawRect(
      body,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          rx * 1.02,
          const [Color(0x00FFFFFF), Color(0x59FFE1FA), Color(0xD9FFFFFF)],
          const [0, 0.75, 1],
          TileMode.clamp,
          null,
          // Skia rejects a conical gradient whose center and focal are both zero.
          const Offset(0.02, 0),
          rx * 0.78,
        ),
    );
    _blurLayer(canvas, rx * 0.05, body, () {
      canvas.drawPath(
        _super(rx, ry),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = rx * 0.1
          ..color = const Color(0x73FFFFFF),
      );
    });
    _blurLayer(canvas, rx * 0.045, body, () {
      canvas.save();
      canvas.translate(-rx * 0.3, -ry * 0.42);
      canvas.rotate(-0.5);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 0.9, height: ry * 0.52),
        Paint()..color = const Color(0x24FFFFFF),
      );
      canvas.restore();
    });
    canvas.save();
    canvas.translate(-0.42 * rx, -0.55 * ry);
    canvas.rotate(-0.6);
    canvas.scale(1, 0.42);
    final specR = 0.27 * rx;
    canvas.drawCircle(
      Offset.zero,
      specR,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          specR,
          const [Color(0xFAFFFFFF), Color(0xD9FFFFFF), Color(0x00FFFFFF)],
          const [0, 0.7, 1],
        ),
    );
    canvas.restore();
    canvas.restore();

    canvas.drawPath(
      _super(rx, ry),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, rx * 0.012)
        ..color = const Color(0x8CFFFFFF),
    );

    if (!noEyes) {
      final es = 1 + listen * 0.1;
      for (final side in [-1.0, 1.0]) {
        final yaw = side * 0.29 + gx * 0.36;
        final pitch = -0.06 + gy * 0.3;
        final x = rx * 0.96 * math.sin(yaw);
        final y = ry * 0.96 * math.sin(pitch);
        final w = rx * 0.3 * es * math.pow(math.cos(yaw).abs(), 0.7);
        final h = rx * 0.36 * es * math.pow(math.cos(pitch).abs(), 0.7);
        canvas.save();
        canvas.translate(x, y);
        if (closed || happy) {
          final path = Path();
          if (closed) {
            path.moveTo(-w * 0.52, -h * 0.02);
            path.quadraticBezierTo(0, h * 0.42, w * 0.52, -h * 0.02);
          } else {
            path.moveTo(-w * 0.52, h * 0.12);
            path.quadraticBezierTo(0, -h * 0.62, w * 0.52, h * 0.12);
          }
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = w * (happy && !closed ? 0.3 : 0.26)
              ..color = const Color(0xFF08080D),
          );
        } else {
          final hh = math.max(h * open, h * 0.08);
          if (lid > 0) {
            final ly = -hh / 2 + lid * hh;
            final inner = -side;
            final path = Path()
              ..moveTo(-w, ly + lidA * inner * w * 0.5)
              ..lineTo(w, ly - lidA * inner * w * 0.5)
              ..lineTo(w, hh)
              ..lineTo(-w, hh)
              ..close();
            canvas.clipPath(path);
          }
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: w, height: hh),
            Paint()
              ..shader = ui.Gradient.radial(
                Offset(-w * 0.15, -hh * 0.2),
                math.max(w, hh) * 0.62,
                const [Color(0xFF3B3B4A), Color(0xFF111117), Color(0xFF020203)],
                const [0, 0.55, 1],
              ),
          );
          if (open > 0.35) {
            canvas.drawOval(
              Rect.fromCenter(center: Offset(-w * 0.14, -hh * 0.22), width: w * 0.4, height: w * 0.48 * open),
              Paint()..color = const Color(0xE6FFFFFF),
            );
          }
        }
        canvas.restore();
      }
    }
    canvas.restore();
  }

  void _ring(Canvas canvas, double cx, double cy, double r, double rot, double a, double b, double alpha, bool front) {
    canvas.save();
    canvas.translate(cx, cy + r * 0.05);
    canvas.rotate(rot + 0.03 * math.sin(t * 0.4));
    final rect = Rect.fromCenter(center: Offset.zero, width: a * r * 2, height: b * r * 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.022
      ..shader = LinearGradient(
        colors: [
          Color.fromRGBO(150, 200, 255, 0.15 * alpha),
          Color.fromRGBO(255, 255, 255, 0.95 * alpha),
          Color.fromRGBO(205, 170, 255, 0.8 * alpha),
          Color.fromRGBO(140, 215, 255, 0.25 * alpha),
        ],
        stops: const [0, 0.35, 0.6, 1],
      ).createShader(rect);
    canvas.drawArc(rect, front ? 0 : math.pi, math.pi, false, paint);
    canvas.restore();
  }

  void _star(Canvas canvas, double x, double y, double r, double a) {
    final path = Path()..moveTo(r, 0);
    for (var i = 1; i <= 4; i++) {
      final an = (i * math.pi) / 2;
      final m = an - math.pi / 4;
      path.quadraticBezierTo(math.cos(m) * r * 0.18, math.sin(m) * r * 0.18, math.cos(an) * r, math.sin(an) * r);
    }
    canvas.save();
    canvas.translate(x, y);
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: a));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PearlPainter oldDelegate) => true;
}
