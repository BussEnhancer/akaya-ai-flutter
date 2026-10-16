import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../icons/icon_paths.dart';

class AkayaIcon extends StatelessWidget {
  const AkayaIcon(
    this.name, {
    super.key,
    this.size = 20,
    this.strokeWidth = 1.9,
    this.color,
    this.fill = false,
  });

  final String name;
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? const Color(0xFF161936);
    final hex = '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final raw = (kIconPaths[name] ?? '').replaceAll('currentColor', hex);
    final svg = '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="${fill ? hex : 'none'}"${fill ? ' fill-opacity="0.22"' : ''} stroke="$hex" stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round">$raw</svg>''';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
