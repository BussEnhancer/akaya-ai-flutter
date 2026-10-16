/// Shared animation clock. `?anim=<ms>` freezes every loop at that time
/// so a Flutter frame can be compared with React at the same timestamp.
class AnimClock {
  static int? frozenMs;
  static final DateTime _start = DateTime.now();

  static void freezeFromQuery(String? raw) {
    final n = int.tryParse(raw ?? '');
    frozenMs = n;
  }

  static double seconds() {
    final frozen = frozenMs;
    if (frozen != null) return frozen / 1000.0;
    return DateTime.now().difference(_start).inMicroseconds / 1e6;
  }

  /// Milliseconds since the animation origin. Null when the clock is live.
  static int? get ms => frozenMs;
}

/// mulberry32, matching the JS used to stub `Math.random` in frame captures.
class Mulberry32 {
  Mulberry32(int seed) : _a = seed & 0xFFFFFFFF;
  int _a;

  void reseed(int seed) => _a = seed & 0xFFFFFFFF;

  static int _u32(int x) => x & 0xFFFFFFFF;
  static int _shr(int x, int n) => _u32(x) >> n;
  static int _imul(int a, int b) => _u32(_u32(a) * _u32(b));

  double next() {
    _a = _u32(_a + 0x6D2B79F5);
    var t = _imul(_a ^ _shr(_a, 15), 1 | _a);
    t = _u32(t + _imul(t ^ _shr(t, 7), 61 | t) ^ t);
    return _u32(t ^ _shr(t, 14)) / 4294967296.0;
  }
}
