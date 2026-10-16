import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'anim_clock.dart';

/// Position on the loop, supplied by [StageBox] when `?anim=` freezes time.
class StageClock extends InheritedWidget {
  const StageClock({super.key, required this.ms, required super.child});

  /// Milliseconds since the start of the current loop.
  final int ms;

  static int? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StageClock>()?.ms;
  }

  @override
  bool updateShouldNotify(StageClock oldWidget) => oldWidget.ms != ms;
}

/// Underdamped spring used by Framer Motion (`stiffness`, `damping`, `mass: 1`, `v0: 0`).
/// Position is 0 at t=0 and settles on 1, with the same overshoot as React.
double framerSpring(double seconds, {double stiffness = 260, double damping = 20, double mass = 1}) {
  if (seconds <= 0) return 0;
  final w = math.sqrt(stiffness / mass);
  final z = damping / (2 * math.sqrt(stiffness * mass));
  if (z >= 1) {
    // Overdamped / critical: not used by the onboarding springs.
    return 1 - math.exp(-w * seconds) * (1 + w * seconds);
  }
  final wd = w * math.sqrt(1 - z * z);
  final env = math.exp(-z * w * seconds);
  final a = (z * w) / wd;
  return 1 - env * (a * math.sin(wd * seconds) + math.cos(wd * seconds));
}

/// Long enough for the 260/20 spring to sit on 1 (it is visually settled by ~0.68s).
const kFramerSpringSeconds = 1.2;

/// Cubic used by Framer's default opacity tween (`[0.25, 0.1, 0.35, 1]`, 300ms).
const kFramerOpacity = Cubic(0.25, 0.1, 0.35, 1);

/// Framer's `easeOut` (`cubic-bezier(0, 0, 0.58, 1)`).
const kFramerEaseOut = Cubic(0, 0, 0.58, 1);

/// Reveals [child] with a Framer Motion spring.
///
/// [bornAtMs] is when the element mounts on the stage timeline (a `useStages` mark).
/// [opacityMs] follows Framer's default opacity tween instead of the spring
/// (scale/x still use the spring). That split is what an omitted `transition` does.
class SpringReveal extends StatefulWidget {
  const SpringReveal({
    super.key,
    required this.child,
    this.dx = 0,
    this.dy = 0,
    this.fromScale = 1,
    this.fromOpacity = 0,
    this.delay = Duration.zero,
    this.bornAtMs = 0,
    this.fromRotate = 0,
    this.toRotate = 0,
    this.stiffness = 260,
    this.damping = 20,
    this.opacityMs,
  });

  final Widget child;
  final double dx;
  final double dy;
  final double fromScale;
  final double fromOpacity;
  final Duration delay;
  final int bornAtMs;
  final double fromRotate;
  final double toRotate;
  final double stiffness;
  final double damping;

  /// When set, opacity eases over this many milliseconds instead of the spring.
  final int? opacityMs;

  @override
  State<SpringReveal> createState() => _SpringRevealState();
}

class _SpringRevealState extends State<SpringReveal> with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    if (AnimClock.ms != null) return;
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: (kFramerSpringSeconds * 1000).round()));
    if (widget.delay == Duration.zero) {
      _c!.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _c?.forward();
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  double _springAt(double seconds) => framerSpring(seconds, stiffness: widget.stiffness, damping: widget.damping);

  @override
  Widget build(BuildContext context) {
    final frozen = StageClock.maybeOf(context) ?? AnimClock.ms;
    if (frozen != null) {
      final elapsed = (frozen - widget.bornAtMs - widget.delay.inMilliseconds) / 1000.0;
      return _paint(_springAt(elapsed), elapsed);
    }
    return AnimatedBuilder(
      animation: _c!,
      builder: (context, _) {
        final elapsed = (_c!.value * kFramerSpringSeconds);
        return _paint(_springAt(elapsed), elapsed);
      },
    );
  }

  Widget _paint(double p, double elapsedSec) {
    final opacityT = widget.opacityMs == null
        ? p
        : kFramerOpacity.transform((elapsedSec / (widget.opacityMs! / 1000)).clamp(0.0, 1.0));
    final opacity = (widget.fromOpacity + (1 - widget.fromOpacity) * opacityT).clamp(0.0, 1.0);
    final rot = (widget.fromRotate + (widget.toRotate - widget.fromRotate) * p) * math.pi / 180;
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(widget.dx * (1 - p), widget.dy * (1 - p)),
        child: Transform.rotate(
          angle: rot,
          child: Transform.scale(
            scale: widget.fromScale + (1 - widget.fromScale) * p,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Linear move used for the onboarding finger (350ms, no spring).
class LinearReveal extends StatefulWidget {
  const LinearReveal({
    super.key,
    required this.child,
    required this.bornAtMs,
    this.dx = 0,
    this.dy = 0,
    this.ms = 350,
  });

  final Widget child;
  final int bornAtMs;
  final double dx;
  final double dy;
  final int ms;

  @override
  State<LinearReveal> createState() => _LinearRevealState();
}

class _LinearRevealState extends State<LinearReveal> with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    if (AnimClock.ms != null) return;
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: widget.ms))..forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frozen = StageClock.maybeOf(context) ?? AnimClock.ms;
    if (frozen != null) return _paint(((frozen - widget.bornAtMs) / widget.ms).clamp(0.0, 1.0));
    return AnimatedBuilder(animation: _c!, builder: (_, _) => _paint(_c!.value));
  }

  Widget _paint(double p) {
    return Opacity(
      opacity: p.clamp(0.0, 1.0),
      child: Transform.translate(offset: Offset(widget.dx * (1 - p), widget.dy * (1 - p)), child: widget.child),
    );
  }
}

/// Delayed ease-out used for the send-button press and the tap ripple.
class EaseReveal extends StatefulWidget {
  const EaseReveal({
    super.key,
    required this.child,
    required this.bornAtMs,
    this.delayMs = 0,
    this.ms = 350,
    this.fromScale = 1,
    this.toScale = 1,
    this.fromOpacity = 1,
    this.toOpacity = 1,
  });

  final Widget child;
  final int bornAtMs;
  final int delayMs;
  final int ms;
  final double fromScale;
  final double toScale;
  final double fromOpacity;
  final double toOpacity;

  @override
  State<EaseReveal> createState() => _EaseRevealState();
}

class _EaseRevealState extends State<EaseReveal> with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    if (AnimClock.ms != null) return;
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: widget.delayMs + widget.ms))..forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  double _u(double elapsedMs) {
    final x = ((elapsedMs - widget.delayMs) / widget.ms).clamp(0.0, 1.0);
    if (elapsedMs < widget.delayMs) return 0;
    return kFramerEaseOut.transform(x);
  }

  @override
  Widget build(BuildContext context) {
    final frozen = StageClock.maybeOf(context) ?? AnimClock.ms;
    if (frozen != null) return _paint(_u((frozen - widget.bornAtMs).toDouble()));
    return AnimatedBuilder(
      animation: _c!,
      builder: (_, _) => _paint(_u(_c!.value * (widget.delayMs + widget.ms))),
    );
  }

  Widget _paint(double u) {
    final opacity = (widget.fromOpacity + (widget.toOpacity - widget.fromOpacity) * u).clamp(0.0, 1.0);
    final scale = widget.fromScale + (widget.toScale - widget.fromScale) * u;
    return Opacity(opacity: opacity, child: Transform.scale(scale: scale, child: widget.child));
  }
}

/// `animate={{ scale: [1, 0.9, 1] }}` with a delay, sampled like Framer keyframes.
double keyframeScale(double elapsedMs, {double delay = 250, double duration = 350}) {
  if (elapsedMs <= delay) return 1;
  final u = ((elapsedMs - delay) / duration).clamp(0.0, 1.0);
  final eased = kFramerEaseOut.transform(u);
  const keys = [1.0, 0.9, 1.0];
  final x = eased * (keys.length - 1);
  final i = x.floor().clamp(0, keys.length - 2);
  final f = x - i;
  return keys[i] + (keys[i + 1] - keys[i]) * f;
}
