import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'chrome.dart';
import 'spring.dart';

class MindNode {
  const MindNode(this.label, [this.children = const []]);
  final String label;
  final List<MindNode> children;
}

/// Lecture tree produced by the React mock summariser from `LECTURE` hints.
const lectureMind = MindNode('Linear Algebra – Chapter 3', [
  MindNode('Eigenvalues & eigenvectors', [MindNode('Overview'), MindNode('Stretch factor')]),
  MindNode('Mathematical definition', [MindNode('Av = λv'), MindNode('Same direction')]),
  MindNode('Finding eigenvalues', [MindNode('Characteristic eqn'), MindNode('≤ 2 for 2×2')]),
  MindNode('Worked example', [MindNode('λ = 3 and 1'), MindNode('v = (1,1), (1,−1)')]),
  MindNode('Applications', [MindNode('PCA · PageRank')]),
  MindNode('Key points', [MindNode('Trace · det')]),
]);

const businessMind = MindNode('Q4 launch plan', [
  MindNode('Agenda', [MindNode('Q4 launch')]),
  MindNode('Beta update', [MindNode('61% retention'), MindNode('Onboarding too long')]),
  MindNode('Pricing', [MindNode('₹199 / month'), MindNode('Student 50% off')]),
  MindNode('Launch plan', [MindNode('Razorpay'), MindNode('14 Nov launch')]),
]);

const ideasMind = MindNode('Diwali campaign ideas', [
  MindNode('Campaign ideas', [MindNode('Family videos'), MindNode('Video calls')]),
  MindNode('Regional ads', [MindNode('Hindi + Tamil')]),
]);

const _colors = [
  Color(0xFF0269F8),
  Color(0xFF7625EF),
  Color(0xFF0DABF4),
  Color(0xFF08B36A),
  Color(0xFFE8743B),
  Color(0xFFD94FA0),
];

/// Branching mind map: root, spine, topic edges and idea chips.
/// Tap a topic to fold its ideas. Tap an idea to mark it.
class MindMapView extends StatefulWidget {
  const MindMapView({super.key, required this.root});
  final MindNode root;

  @override
  State<MindMapView> createState() => _MindMapViewState();
}

class _MindMapViewState extends State<MindMapView> {
  final _closed = <int>{};
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final topics = widget.root.children;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: p.brand,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Color(0xCC463CF0), blurRadius: 22, offset: Offset(0, 10), spreadRadius: -12)],
            ),
            child: Text(widget.root.label, textAlign: TextAlign.center, style: comfortaa(13.76, Colors.white)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                top: 0,
                bottom: 16,
                child: SizedBox(
                  width: 2.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x8C7625EF), Color(0x8C0269F8), Color(0x8C0DABF4), Color(0x8C08B36A)],
                        stops: [0, 0.4, 0.7, 1],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < topics.length; i++)
                      SpringReveal(
                        dx: -8,
                        bornAtMs: 0,
                        stiffness: 500,
                        damping: 25,
                        opacityMs: 300,
                        child: _branch(p, i, topics[i], _colors[i % _colors.length]),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _branch(AkayaPalette p, int i, MindNode topic, Color color) {
    final open = !_closed.contains(i);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 18, height: 2.5, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() {
                  if (!_closed.add(i)) _closed.remove(i);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [BoxShadow(color: color, blurRadius: 16, offset: const Offset(0, 8), spreadRadius: -10)],
                  ),
                  child: Text(topic.label, style: manrope(12.48, Colors.white, weight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          if (open && topic.children.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 12, top: 7),
              child: CustomPaint(
                painter: _DashPainter(color.withValues(alpha: 0.45)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      for (final kid in topic.children)
                        SpringReveal(
                          fromScale: 0.9,
                          bornAtMs: 0,
                          stiffness: 550,
                          damping: 30,
                          opacityMs: 300,
                          child: GestureDetector(
                            onTap: () => setState(() => _picked = _picked == kid.label ? null : kid.label),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: _picked == kid.label ? 0.28 : 0.13),
                                borderRadius: BorderRadius.circular(99),
                                border: _picked == kid.label ? Border.all(color: color, width: 1.4) : null,
                              ),
                              child: Text(kid.label, style: manrope(11.2, color, weight: FontWeight.w700)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `border-left: 2px dashed` at 45% of the topic colour.
class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;
    const dash = 3.0;
    const gap = 2.5;
    var y = 0.0;
    while (y < size.height) {
      final end = (y + dash).clamp(0.0, size.height);
      canvas.drawLine(const Offset(1, 0) + Offset(0, y), Offset(1, end), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) => oldDelegate.color != color;
}
