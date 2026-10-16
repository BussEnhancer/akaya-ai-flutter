import 'package:flutter/material.dart';

/// Design tokens ported from packages/ui/src/theme/tokens.css.
class AkayaPalette {
  const AkayaPalette.light() : dark = false;
  const AkayaPalette.dark() : dark = true;

  final bool dark;

  Color get bg => dark ? const Color(0xFF0B0A1A) : const Color(0xFFF4F1FC);
  Color get surface => dark ? const Color(0x9E1E1B3E) : const Color(0xD6FFFFFF);
  Color get surfaceSolid => dark ? const Color(0xFF17152E) : const Color(0xFFFFFFFF);
  Color get surface2 => dark ? const Color(0x12FFFFFF) : const Color(0xFFF1EDFB);
  Color get surface3 => dark ? const Color(0x1CFFFFFF) : const Color(0xFFE9E3FA);
  Color get line => dark ? const Color(0x17FFFFFF) : const Color(0x1A503CAA);
  Color get lineStrong => dark ? const Color(0x29FFFFFF) : const Color(0x2E503CAA);
  Color get text => dark ? const Color(0xFFF4F2FF) : const Color(0xFF161936);
  Color get text2 => dark ? const Color(0xFFB0AFD0) : const Color(0xFF62658A);
  Color get text3 => dark ? const Color(0xFF807FA6) : const Color(0xFF9295B2);
  Color get sheet => dark ? const Color(0xFF15132B) : const Color(0xFFFFFFFF);
  Color get navBg => dark ? const Color(0xF516142C) : const Color(0xF5FFFFFF);
  Color get greenText => dark ? const Color(0xFF3EE696) : const Color(0xFF079B52);
  Color get orangeText => dark ? const Color(0xFFFF9A5C) : const Color(0xFFD4612A);
  Color get violetText => dark ? const Color(0xFFB48BFF) : const Color(0xFF7625EF);

  static const blue = Color(0xFF0269F8);
  static const violet = Color(0xFF7625EF);
  static const cyan = Color(0xFF0DABF4);
  static const green = Color(0xFF08DA73);
  static const orange = Color(0xFFE8743B);
  static const pink = Color(0xFFE0458F);

  LinearGradient get brand => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7625EF), Color(0xFF0269F8)],
      );
  LinearGradient get gOrange => const LinearGradient(
        begin: Alignment(-0.6, -0.8),
        end: Alignment(0.8, 0.8),
        colors: [Color(0xFFFF9A5C), Color(0xFFE8743B), Color(0xFFDE6230)],
        stops: [0, 0.6, 1],
      );
  LinearGradient get gradText => LinearGradient(
        colors: dark ? const [Color(0xFF5AA2FF), Color(0xFFB07BFF)] : const [Color(0xFF0269F8), Color(0xFF7625EF)],
      );

  List<BoxShadow> get shadow => [
        BoxShadow(
          color: dark ? const Color(0xBF000000) : const Color(0x4D4632A0),
          blurRadius: 28,
          offset: const Offset(0, 10),
          spreadRadius: -14,
        ),
      ];
  List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: dark ? const Color(0xD9000000) : const Color(0x66462896),
          blurRadius: 40,
          offset: const Offset(0, 20),
          spreadRadius: -18,
        ),
      ];

  BoxDecoration get frameBg => BoxDecoration(
        color: dark ? const Color(0xFF0A0915) : const Color(0xFFF3F1F8),
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.6),
          radius: 1.1,
          colors: dark
              ? const [Color(0xFF241A52), Color(0x000A0915)]
              : const [Color(0xFFECE4FF), Color(0x00F3F1F8)],
        ),
      );

  Color tint(String tone) {
    switch (tone) {
      case 'orange':
        return dark ? const Color(0x2EE8743B) : const Color(0x1FE8743B);
      case 'blue':
        return dark ? const Color(0x2E3C8CFF) : const Color(0x1A0269F8);
      case 'violet':
        return dark ? const Color(0x33965AFF) : const Color(0x1A7625EF);
      case 'green':
        return dark ? const Color(0x2908DA73) : const Color(0x2108DA73);
      case 'cyan':
        return dark ? const Color(0x2E0DABF4) : const Color(0x1F0DABF4);
      case 'pink':
        return const Color(0x1FE0458F);
      case 'red':
        return const Color(0x1FE5484D);
      default:
        return surface2;
    }
  }

  Color toneColor(String tone) {
    switch (tone) {
      case 'orange':
        return orangeText;
      case 'blue':
        return blue;
      case 'violet':
        return dark ? const Color(0xFFB99BFF) : violet;
      case 'green':
        return greenText;
      case 'cyan':
        return cyan;
      case 'pink':
        return pink;
      case 'red':
        return const Color(0xFFE5484D);
      default:
        return text;
    }
  }

  LinearGradient gi(String tone) {
    switch (tone) {
      case 'orange':
        return gOrange;
      case 'violet':
        return const LinearGradient(
          begin: Alignment(-0.6, -0.8),
          end: Alignment(0.7, 0.8),
          colors: [Color(0xFF9A5CFF), Color(0xFF7625EF)],
        );
      case 'blue':
        return const LinearGradient(
          begin: Alignment(-0.6, -0.8),
          end: Alignment(0.7, 0.8),
          colors: [Color(0xFF3D8BFF), Color(0xFF0269F8)],
        );
      case 'cyan':
        return const LinearGradient(
          begin: Alignment(-0.6, -0.8),
          end: Alignment(0.7, 0.8),
          colors: [Color(0xFF45CDFB), Color(0xFF0DABF4)],
        );
      case 'green':
        return const LinearGradient(
          begin: Alignment(-0.6, -0.8),
          end: Alignment(0.7, 0.8),
          colors: [Color(0xFF3EF09A), Color(0xFF08C467)],
        );
      case 'pink':
        return const LinearGradient(
          begin: Alignment(-0.6, -0.8),
          end: Alignment(0.7, 0.8),
          colors: [Color(0xFFFF7FB6), Color(0xFFE0458F)],
        );
      default:
        return brand;
    }
  }
}

TextStyle comfortaa(double size, Color color, {FontWeight weight = FontWeight.w700, double height = 1.15}) {
  return TextStyle(
    fontFamily: 'Comfortaa',
    fontFamilyFallback: const ['Manrope', 'NotoSansDevanagari'],
    fontSize: size,
    height: height,
    color: color,
    fontWeight: weight,
    letterSpacing: -0.3,
    fontVariations: const [FontVariation('wght', 700)],
  );
}

TextStyle manrope(
  double size,
  Color color, {
  FontWeight weight = FontWeight.w600,
  double height = 1.25,
  double letterSpacing = 0,
}) {
  final wght = switch (weight) {
    FontWeight.w800 => 800.0,
    FontWeight.w700 => 700.0,
    FontWeight.w500 => 500.0,
    FontWeight.w400 => 400.0,
    _ => 600.0,
  };
  return TextStyle(
    fontFamily: 'Manrope',
    fontFamilyFallback: const ['NotoSansDevanagari'],
    fontSize: size,
    height: height,
    color: color,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    fontVariations: [FontVariation('wght', wght)],
  );
}

String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 5) return 'Good night';
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  if (h < 21) return 'Good evening';
  return 'Good night';
}

String fmtTime(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $ap';
}

String relDay(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final now = DateTime.now();
  final a = DateTime(now.year, now.month, now.day);
  final b = DateTime(d.year, d.month, d.day);
  final days = a.difference(b).inDays;
  if (days <= 0) return fmtTime(ms);
  if (days == 1) return 'Yesterday';
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  if (days < 7) return names[d.weekday - 1];
  return '${d.day}/${d.month}';
}
