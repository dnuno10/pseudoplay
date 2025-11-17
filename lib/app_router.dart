import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'views/menu_view.dart';
import 'views/code_editor_view.dart';
import 'views/code_execution_view.dart';
import 'views/blocks_mode_view.dart';
import 'views/desk_check_view.dart';
import 'views/settings_view.dart';

final appRouter = GoRouter(
  initialLocation: '/menu',
  routes: [
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
      path: '/deskcheck',
      builder: (context, state) => const DeskCheckView(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsView(),
    ),
  ],
);
