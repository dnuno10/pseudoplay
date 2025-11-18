import 'package:go_router/go_router.dart';

import 'views/menu_view.dart';
import 'views/code_editor_view.dart';
import 'views/code_execution_view.dart';
import 'views/blocks_mode_view.dart';
import 'views/desk_check_view.dart';
import 'views/settings_view.dart';
import 'views/flashcards_view.dart';
import 'views/splash_screen_view.dart';
import 'views/terms_view.dart';
import 'views/privacy_view.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreenView(),
    ),
    GoRoute(path: '/menu', builder: (context, state) => const MenuView()),
    GoRoute(
      path: '/editor',
      builder: (context, state) => const CodeEditorView(),
    ),
    GoRoute(
      path: '/execution',
      builder: (context, state) => const CodeExecutionView(),
    ),
    GoRoute(
      path: '/blocks',
      builder: (context, state) => const BlocksModeView(),
    ),
    GoRoute(
      path: '/flashcards',
      builder: (context, state) => const FlashcardsView(),
    ),
    GoRoute(
      path: '/deskcheck',
      builder: (context, state) => const DeskCheckView(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsView(),
    ),
    GoRoute(path: '/terms', builder: (context, state) => const TermsView()),
    GoRoute(path: '/privacy', builder: (context, state) => const PrivacyView()),
  ],
);
