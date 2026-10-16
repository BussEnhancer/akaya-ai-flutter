import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'app.dart';
import 'url_strategy_stub.dart' if (dart.library.js_interop) 'url_strategy_web.dart';
import 'widgets/anim_clock.dart';

void main() {
  configureUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  final q = Uri.base.queryParameters;
  AnimClock.freezeFromQuery(q['anim']);
  runApp(AkayaApp(preview: q['preview'] == '1', themeOverride: q['theme']));
}
