import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/auth_screens.dart';
import 'screens/chat_screen.dart';
import 'screens/feature_screens.dart';
import 'screens/home_screen.dart';
import 'screens/rich_screens.dart';
import 'screens/more_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/voice_screen.dart';
import 'state/model.dart';
import 'widgets/chrome.dart';

GoRouter buildAkayaRouter(AppModel model) {
  return GoRouter(
    refreshListenable: model,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      const open = {'/signup', '/login', '/forgot', '/verify-email'};
      if (!model.signedIn) {
        if (open.contains(loc)) return null;
        return '/signup';
      }
      if (!model.onboardingDone) {
        if (loc == '/onboarding' || loc == '/forgot') return null;
        return '/onboarding';
      }
      if (loc == '/' || loc == '/signup' || loc == '/login' || loc == '/verify-email') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(
        path: '/signup',
        builder: (_, s) {
          final step = s.uri.queryParameters['step'];
          return SignUpScreen(phoneTab: step == 'phone' || step == 'otp', startOtp: step == 'otp');
        },
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotScreen()),
      GoRoute(path: '/verify-email', builder: (_, _) => const VerifyScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, s) => OnboardingScreen(start: int.tryParse(s.uri.queryParameters['slide'] ?? '') ?? 0),
      ),
      GoRoute(
        path: '/home',
        builder: (_, s) {
          final q = s.uri.queryParameters;
          return HomeScreen(sheet: q['sheet'], scroll: q['scroll'], focus: q['focus']);
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (_, s) {
          final q = s.uri.queryParameters;
          return ChatScreen(attach: q['attach'] == '1', panel: q['panel']);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, s) {
          final q = s.uri.queryParameters;
          return ChatScreen(id: s.pathParameters['id'], attach: q['attach'] == '1', panel: q['panel']);
        },
      ),
      GoRoute(path: '/voice', builder: (_, _) => const VoiceScreen()),
      GoRoute(path: '/more', builder: (_, s) => MoreScreen(jumpEnd: s.uri.queryParameters['scroll'] == 'bottom')),
      GoRoute(path: '/translate', builder: (_, _) => const TranslateScreen()),
      GoRoute(path: '/future', builder: (_, _) => const FutureScreen()),
      GoRoute(path: '/notes', builder: (_, _) => const NotesScreen()),
      GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
      GoRoute(
        path: '/history',
        builder: (_, s) {
          final q = s.uri.queryParameters;
          return HistoryScreen(
            filter: q['f'],
            query: q['q'],
            openMenu: q['menu'] == '1',
            openDetail: q['detail'] == '1',
            jumpEnd: q['scroll'] == 'bottom',
          );
        },
      ),
      GoRoute(path: '/upgrade', builder: (_, _) => const UpgradeScreen()),
      GoRoute(path: '/vnotes', builder: (_, s) => VoiceNotesScreen(jumpEnd: s.uri.queryParameters['view'] == 'recent')),
      GoRoute(
        path: '/vnotes/rec',
        builder: (_, s) {
          final q = s.uri.queryParameters;
          return RecorderScreen(demo: q['demo'], tab: q['tab'], hold: q['hold'] == '1');
        },
      ),
      GoRoute(
        path: '/vnotes/:id',
        builder: (_, s) {
          final q = s.uri.queryParameters;
          return NoteViewScreen(id: s.pathParameters['id']!, tab: q['tab'], hindi: q['line'] == 'hindi', playing: q['play'] == '1');
        },
      ),
      GoRoute(
        path: '/apps',
        builder: (_, s) {
          final q = s.uri.queryParameters;
          return AppsScreen(category: q['cat'], query: q['q'], appId: q['app'], step: q['step'], jumpEnd: q['scroll'] == 'bottom');
        },
      ),
      GoRoute(path: '/support', builder: (_, _) => const SupportScreen()),
      GoRoute(path: '/travel', builder: (_, _) => const TravelScreen()),
      GoRoute(path: '/shopping', builder: (_, _) => const ShoppingScreen()),
      GoRoute(path: '/earnings', builder: (_, _) => const EarningsScreen()),
      GoRoute(path: '/reminders', builder: (_, _) => const RemindersScreen()),
    ],
  );
}

class AkayaApp extends StatefulWidget {
  const AkayaApp({super.key, this.preview = false, this.themeOverride});
  final bool preview;
  final String? themeOverride;

  @override
  State<AkayaApp> createState() => _AkayaAppState();
}

class _AkayaAppState extends State<AkayaApp> {
  late final AppModel model = AppModel();
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    if (widget.preview) model.enterPreview();
    final t = widget.themeOverride;
    if (t == 'light' || t == 'dark' || t == 'system') model.theme = t!;
    router = buildAkayaRouter(model);
  }

  @override
  void dispose() {
    router.dispose();
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AkayaScope(
      model: model,
      child: MaterialApp.router(
        title: 'Akaya',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF4F1FC),
          fontFamily: 'Manrope',
          splashFactory: NoSplash.splashFactory,
        ),
        routerConfig: router,
        builder: (context, child) => DeviceFrame(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
