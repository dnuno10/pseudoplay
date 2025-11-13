import 'package:flutter/material.dart';
import 'views/splash_view.dart';
import 'views/home_view.dart';
import 'views/code_editor_view.dart';
import 'views/code_execution_view.dart';
import 'views/blocks_mode_view.dart';
import 'views/predetermined_algorithms_view.dart';
import 'views/desk_check_view.dart';
import 'package:go_router/go_router.dart';

final appRouter = RouterConfig(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashView()),
    GoRoute(path: '/home', builder: (_, __) => const HomeView()),
    GoRoute(path: '/editor', builder: (_, __) => const CodeEditorView()),
    GoRoute(path: '/execution', builder: (_, __) => const CodeExecutionView()),
    GoRoute(
      path: '/algorithms',
      builder: (_, __) => const PredeterminedAlgorithmsView(),
    ),
    GoRoute(path: '/deskcheck', builder: (_, __) => const DeskCheckView()),
    GoRoute(path: '/blocks', builder: (_, __) => const BlocksModeView()),
  ],
);
