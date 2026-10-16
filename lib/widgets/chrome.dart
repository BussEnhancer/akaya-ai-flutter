import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../data/logos.dart';
import '../state/model.dart';
import '../theme/tokens.dart';
import 'akaya_icon.dart';
import 'pearl.dart';

class PaletteScope extends InheritedWidget {
  const PaletteScope({super.key, required this.palette, required super.child});
  final AkayaPalette palette;

  static AkayaPalette of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PaletteScope>()!.palette;
  }

  @override
  bool updateShouldNotify(PaletteScope oldWidget) => oldWidget.palette.dark != palette.dark;
}

AkayaPalette paletteOf(BuildContext context) => PaletteScope.of(context);

class DeviceFrame extends StatelessWidget {
  const DeviceFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final model = AkayaScope.of(context);
    final platformDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final dark = model.theme == 'dark' || (model.theme == 'system' && platformDark);
    final p = dark ? const AkayaPalette.dark() : const AkayaPalette.light();
    return PaletteScope(
      palette: p,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(model.textSize)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final framed = constraints.maxWidth >= 600 && constraints.maxHeight >= 760;
            final clock = Uri.base.queryParameters['clock'];
            final device = Material(
              color: p.bg,
              child: Stack(
                children: [
                  const Positioned.fill(child: _BgFx()),
                  Column(
                    children: [
                      if (framed) _StatusBar(clock: clock) else SizedBox(height: MediaQuery.paddingOf(context).top),
                      Expanded(child: child),
                    ],
                  ),
                  const _ToastHost(),
                ],
              ),
            );
            if (!framed) return ColoredBox(color: p.bg, child: device);
            return DecoratedBox(
              decoration: p.frameBg,
              child: Center(
                child: Container(
                  width: 390,
                  height: 844,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: p.bg,
                    borderRadius: BorderRadius.circular(52),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFF0D0C19), spreadRadius: 10),
                      BoxShadow(color: Color(0xFF2C2A40), spreadRadius: 11.5),
                      BoxShadow(color: Color(0x73301E50), blurRadius: 80, offset: Offset(0, 40)),
                    ],
                  ),
                  child: device,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BgFx extends StatelessWidget {
  const _BgFx();

  @override
  Widget build(BuildContext context) {
    final dark = paletteOf(context).dark;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 120,
            right: -40,
            child: _blob(280, 230, dark ? const Color(0x2EDC50C8) : const Color(0x73FFB4EB)),
          ),
          Positioned(
            top: 140,
            left: -80,
            child: _blob(280, 250, dark ? const Color(0x3D0269F8) : const Color(0x7396C8FF)),
          ),
          Positioned(
            top: 40,
            left: 40,
            right: 40,
            child: _blob(320, 220, dark ? const Color(0x667625EF) : const Color(0x80C8B4FF)),
          ),
        ],
      ),
    );
  }

  Widget _blob(double w, double h, Color c) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [c, c.withValues(alpha: 0)]),
      ),
    );
  }
}

class _StatusBar extends StatefulWidget {
  const _StatusBar({this.clock});
  final String? clock;

  @override
  State<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<_StatusBar> {
  late DateTime _now;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _t = Timer.periodic(const Duration(seconds: 15), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final time = widget.clock ?? '$h:${_now.minute.toString().padLeft(2, '0')}';
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 4, 26, 0),
        child: Row(
          children: [
            Text(time, style: manrope(15, p.text, weight: FontWeight.w700)),
            const Spacer(),
            Icon(Icons.signal_cellular_alt, size: 16, color: p.text),
            const SizedBox(width: 6),
            Icon(Icons.wifi, size: 16, color: p.text),
            const SizedBox(width: 6),
            Container(
              width: 26,
              height: 13,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.text, borderRadius: BorderRadius.circular(4)),
              child: Text('99', style: manrope(9, p.bg, weight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToastHost extends StatelessWidget {
  const _ToastHost();

  @override
  Widget build(BuildContext context) {
    final model = AkayaScope.of(context);
    final p = paletteOf(context);
    final msg = model.toast;
    return Positioned(
      top: 54,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: msg == null ? 0 : 1,
          duration: const Duration(milliseconds: 180),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: p.dark ? const Color(0xFFF4F2FF) : const Color(0xFF1B1838),
                borderRadius: BorderRadius.circular(99),
                boxShadow: const [BoxShadow(color: Color(0x990A0528), blurRadius: 30, offset: Offset(0, 14))],
              ),
              child: Text(msg ?? '', style: manrope(12.8, p.dark ? const Color(0xFF161936) : Colors.white, weight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}

class AkayaScreen extends StatefulWidget {
  const AkayaScreen({super.key, required this.child, this.padding = EdgeInsets.zero, this.scroll = true, this.jumpEnd = false, this.anchor});
  final Widget child;
  final EdgeInsets padding;
  final bool scroll;
  final bool jumpEnd;
  final GlobalKey? anchor;

  @override
  State<AkayaScreen> createState() => _AkayaScreenState();
}

class _AkayaScreenState extends State<AkayaScreen> {
  final _sc = ScrollController();

  @override
  void initState() {
    super.initState();
    _focus();
  }

  @override
  void didUpdateWidget(covariant AkayaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jumpEnd != widget.jumpEnd || oldWidget.anchor != widget.anchor) _focus();
  }

  void _focus() {
    if (!widget.scroll || (!widget.jumpEnd && widget.anchor == null)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _apply(0));
  }

  void _apply(int n) {
    if (!mounted || !_sc.hasClients) return;
    final ctx = widget.anchor?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, alignment: 0.05);
      return;
    }
    if (!widget.jumpEnd) return;
    final max = _sc.position.maxScrollExtent;
    if (max <= 0 && n < 8) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _apply(n + 1));
      return;
    }
    _sc.jumpTo(max);
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.scroll) return Padding(padding: widget.padding, child: widget.child);
    return ListView(
      controller: _sc,
      padding: widget.padding.add(const EdgeInsets.only(bottom: 28)),
      children: [widget.child],
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.sub, this.trailing});
  final String title;
  final String? sub;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          AkayaIconButton(
            label: 'Back',
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            icon: 'back',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: comfortaa(18.4, p.text)),
                if (sub != null) Text(sub!, style: manrope(11.5, p.text2, weight: FontWeight.w600)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AkayaIconButton extends StatelessWidget {
  const AkayaIconButton({super.key, required this.icon, required this.onTap, this.label, this.size = 20});
  final String icon;
  final VoidCallback onTap;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: glass(p, radius: 20),
          child: AkayaIcon(icon, size: size, color: p.text),
        ),
      ),
    );
  }
}

BoxDecoration glass(AkayaPalette p, {double radius = 22}) {
  return BoxDecoration(
    color: p.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: p.line),
    boxShadow: p.shadow,
  );
}

class AkayaLogo extends StatelessWidget {
  const AkayaLogo({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('aka', style: comfortaa(size, p.text)),
        SizedBox(
          width: size * 0.92,
          height: size,
          child: const CustomPaint(painter: _MarkPainter()),
        ),
        Text('a', style: comfortaa(size, p.text)),
      ],
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 40;
    final sy = size.height / 44;
    canvas.scale(sx, sy);
    Paint stroke(Color a, Color b) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(colors: [a, b]).createShader(const Rect.fromLTWH(0, 0, 40, 44));
    canvas.drawPath(Path()..moveTo(6, 9)..quadraticBezierTo(20, 25, 34, 9), stroke(const Color(0xFF0269F8), const Color(0xFF7625EF)));
    canvas.drawPath(Path()..moveTo(6, 39)..quadraticBezierTo(20, 23, 34, 39), stroke(const Color(0xFF08DA73), const Color(0xFF0DABF4)));
    final bars = Paint()
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(15.5, 21.5), const Offset(15.5, 26.5), bars..color = const Color(0xFF1D8CF8));
    canvas.drawLine(const Offset(20, 19.5), const Offset(20, 28.5), bars..color = const Color(0xFF5A4CF2));
    canvas.drawLine(const Offset(24.5, 21.5), const Offset(24.5, 26.5), bars..color = const Color(0xFF1D8CF8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AkayaAvatar extends StatelessWidget {
  const AkayaAvatar({super.key, this.size = 44});
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8743B), Color(0xFFFF9FD0), Color(0xFF7625EF)],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.bg, width: 2), color: const Color(0xFFF6B28D)),
        child: const CustomPaint(painter: _FacePainter()),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  const _FacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 34;
    canvas.scale(s, s);
    canvas.drawCircle(const Offset(17, 13), 7, Paint()..color = const Color(0xFF7A4A2F));
    canvas.drawCircle(const Offset(17, 14.5), 5.6, Paint()..color = const Color(0xFFF2C4A2));
    canvas.drawPath(
      Path()
        ..moveTo(10.5, 13)
        ..cubicTo(11, 8, 14, 6, 17, 6)
        ..cubicTo(20, 6, 23, 8, 23.5, 13)
        ..cubicTo(22, 10.5, 19.5, 9.6, 17, 9.6)
        ..cubicTo(14.5, 9.6, 12, 10.5, 10.5, 13)
        ..close(),
      Paint()..color = const Color(0xFF3A2418),
    );
    canvas.drawPath(
      Path()
        ..moveTo(5, 34)
        ..cubicTo(6.5, 27, 11, 24, 17, 24)
        ..cubicTo(23, 24, 27.5, 27, 29, 34)
        ..close(),
      Paint()..color = const Color(0xFF7625EF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GradText extends StatelessWidget {
  const GradText(this.text, {super.key, this.size = 21, this.head = true});
  final String text;
  final double size;
  final bool head;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final style = head ? comfortaa(size, Colors.white) : manrope(size, Colors.white, weight: FontWeight.w800);
    return ShaderMask(
      shaderCallback: (r) => p.gradText.createShader(r),
      child: Text(text, style: style),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap, this.icon, this.busy = false, this.enabled = true});
  final String label;
  final VoidCallback? onTap;
  final String? icon;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final on = enabled && !busy;
    return GestureDetector(
      onTap: on ? onTap : null,
      child: Opacity(
        opacity: on ? 1 : 0.45,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: paletteOf(context).gOrange,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0xBFE8743B), blurRadius: 24, offset: Offset(0, 12), spreadRadius: -10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              if (icon != null && !busy) ...[AkayaIcon(icon!, size: 16, color: Colors.white, strokeWidth: 2.6), const SizedBox(width: 8)],
              Text(label, style: manrope(14, Colors.white, weight: FontWeight.w800)),
              if (icon == null && !busy) const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, required this.onTap, this.leading});
  final String label;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.surfaceSolid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.lineStrong),
          boxShadow: p.shadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 9)],
            Text(label, style: manrope(14, p.text, weight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class BrandButton extends StatelessWidget {
  const BrandButton({super.key, required this.label, required this.onTap, this.enabled = true, this.icon});
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: paletteOf(context).brand,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0xB35028DC), blurRadius: 24, offset: Offset(0, 12), spreadRadius: -10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[AkayaIcon(icon!, size: 16, color: Colors.white), const SizedBox(width: 8)],
              Text(label, style: manrope(14, Colors.white, weight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class Segmented extends StatelessWidget {
  const Segmented({super.key, required this.value, required this.options, required this.onChanged, this.full = false});
  final String value;
  final List<(String, Widget)> options;
  final ValueChanged<String> onChanged;
  final bool full;

  Widget _segItem(AkayaPalette p, (String, Widget) o, bool full) {
    final on = value == o.$1;
    final item = GestureDetector(
      onTap: () => onChanged(o.$1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: full ? 6 : 12, vertical: full ? 8 : 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          gradient: on ? p.brand : null,
          boxShadow: on ? const [BoxShadow(color: Color(0x990269F8), blurRadius: 12, offset: Offset(0, 4), spreadRadius: -4)] : null,
        ),
        child: IconTheme(
          data: IconThemeData(color: on ? Colors.white : p.text2, size: 14),
          child: DefaultTextStyle(
            style: manrope(11.5, on ? Colors.white : p.text2, weight: FontWeight.w700),
            child: o.$2,
          ),
        ),
      ),
    );
    return full ? Expanded(child: item) : item;
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: p.line),
        boxShadow: p.shadow,
      ),
      child: Row(
        mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final o in options)
            _segItem(p, o, full),
        ],
      ),
    );
  }
}

class AkayaToggle extends StatelessWidget {
  const AkayaToggle({super.key, required this.on, required this.onChanged});
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 28,
        decoration: BoxDecoration(
          color: on ? AkayaPalette.green : p.surface3,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: on ? Colors.transparent : p.line),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 21,
            height: 21,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))]),
          ),
        ),
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  const SectionHead({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
      child: Row(
        children: [
          Text(title, style: comfortaa(16, p.text)),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.fromLTRB(11, 5, 7, 5),
                decoration: BoxDecoration(color: p.tint('orange'), borderRadius: BorderRadius.circular(99)),
                child: Row(
                  children: [
                    Text(action!, style: manrope(11.2, p.orangeText, weight: FontWeight.w700)),
                    AkayaIcon('chev', size: 13, color: p.orangeText, strokeWidth: 2.6),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Gi extends StatelessWidget {
  const Gi({super.key, required this.icon, required this.tone, this.size = 38, this.iconSize = 19, this.radius = 13});
  final String icon;
  final String tone;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: paletteOf(context).gi(tone),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 8), spreadRadius: -8)],
      ),
      child: AkayaIcon(icon, size: iconSize, color: Colors.white, strokeWidth: 2),
    );
  }
}

class AppTile extends StatelessWidget {
  const AppTile({super.key, required this.id, this.size = 44});
  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    AkayaAppInfo? app;
    for (final a in kApps) {
      if (a.id == id) {
        app = a;
        break;
      }
    }
    final logo = kLogos[id];
    final radius = size * 0.28;
    if (logo != null) {
      final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="${logo.vb}">${logo.body}</svg>';
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 0, spreadRadius: 0.4)],
        ),
        child: SvgPicture.string(svg, fit: BoxFit.contain),
      );
    }
    final color = _hex(app?.color ?? '#7625EF');
    final mono = app?.mono ?? '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      child: Text(mono, style: manrope(size * (mono.length >= 3 ? 0.3 : 0.38), app?.darkText == true ? const Color(0xFF1B1530) : Colors.white, weight: FontWeight.w800)),
    );
  }
}

Color _hex(String h) {
  final s = h.replaceAll('#', '');
  return Color(int.parse('FF$s', radix: 16));
}

class AkayaSheet extends StatelessWidget {
  const AkayaSheet({super.key, required this.title, required this.child, required this.onClose});
  final String title;
  final Widget child;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    return Material(
      color: p.dark ? const Color(0x9903020A) : const Color(0x52161232),
      child: GestureDetector(
        onTap: onClose,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.78),
              decoration: BoxDecoration(
                color: p.sheet,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(width: 42, height: 4, decoration: BoxDecoration(color: p.lineStrong, borderRadius: BorderRadius.circular(4))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 8, 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(title, style: comfortaa(18, p.text))),
                        IconButton(onPressed: onClose, icon: AkayaIcon('close', size: 18, color: p.text2)),
                      ],
                    ),
                  ),
                  Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 24), child: child)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WaveBars extends StatefulWidget {
  const WaveBars({super.key, this.color = Colors.white, this.height = 20, this.heights = const [0.45, 0.8, 1, 0.65, 0.9, 0.5]});
  final Color color;
  final double height;
  final List<double> heights;

  @override
  State<WaveBars> createState() => _WaveBarsState();
}

class _WaveBarsState extends State<WaveBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.heights.length; i++)
              Container(
                width: 3,
                height: widget.height * widget.heights[i] * (0.55 + 0.45 * (0.5 + 0.5 * _sin(_c.value + i * 0.14))),
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(3)),
              ),
          ],
        );
      },
    );
  }

  double _sin(double t) {
    final x = (t % 1) * 3.14159 * 2;
    // cheap sine
    final y = x < 3.14159 ? (x / 1.5708) - 1 : 1 - ((x - 3.14159) / 1.5708);
    return y.clamp(-1, 1);
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(size: Size(18, 18), painter: _GooglePainter());
  }
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 18;
    canvas.scale(s, s);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round;
    canvas.drawArc(const Rect.fromLTWH(1.2, 1.2, 15.6, 15.6), -0.4, 1.4, false, paint..color = const Color(0xFFEA4335));
    canvas.drawArc(const Rect.fromLTWH(1.2, 1.2, 15.6, 15.6), 1.1, 1.2, false, paint..color = const Color(0xFFFBBC05));
    canvas.drawArc(const Rect.fromLTWH(1.2, 1.2, 15.6, 15.6), 2.4, 1.1, false, paint..color = const Color(0xFF34A853));
    canvas.drawArc(const Rect.fromLTWH(1.2, 1.2, 15.6, 15.6), 3.6, 1.5, false, paint..color = const Color(0xFF4285F4));
    canvas.drawLine(const Offset(9, 9), const Offset(16.2, 9), Paint()..color = const Color(0xFF4285F4)..strokeWidth = 2.2..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void showAkayaSheet(BuildContext context, {required String title, required Widget child}) {
  final host = context;
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, _, _) => AkayaSheet(title: title, onClose: () => Navigator.pop(context), child: child),
    transitionBuilder: (context, anim, _, child) {
      return PaletteScope(
        palette: paletteOf(host),
        child: SlideTransition(position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)), child: child),
      );
    },
  );
}

PearlMood moodOf(String name) => switch (name) {
      'happy' => PearlMood.happy,
      'listening' => PearlMood.listening,
      'thinking' => PearlMood.thinking,
      'sleeping' => PearlMood.sleeping,
      _ => PearlMood.idle,
    };
