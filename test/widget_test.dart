import 'package:akaya/widgets/anim_clock.dart';
import 'package:akaya/widgets/spring.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:akaya/app.dart';

void main() {
  test('framer spring matches the 260/20 samples', () {
    expect(framerSpring(0), 0);
    expect(framerSpring(0.05), closeTo(0.227, 0.01));
    expect(framerSpring(0.1), closeTo(0.612, 0.01));
    expect(framerSpring(0.2), closeTo(1.049, 0.01));
    expect(framerSpring(0.5), closeTo(0.993, 0.01));
  });

  test('mulberry32 matches the JS capture seed', () {
    final rng = Mulberry32(1);
    expect(rng.next(), closeTo(0.6270739405881613, 1e-12));
    expect(rng.next(), closeTo(0.002735721180215478, 1e-12));
  });

  testWidgets('signup screen renders', (tester) async {
    await tester.pumpWidget(const AkayaApp());
    await tester.pump();
    expect(find.text('Your intelligent assistant'), findsOneWidget);
  });
}
