import 'package:flutter/widgets.dart';
import 'game_mode.dart';

class UserPreferencesState {
  final bool initialized;
  final String? userName;
  final Locale locale;
  final Duration totalPlaytime;
  final Map<GameMode, Duration> modeDurations;
  final int algorithmsExecuted;
  final bool requiresName;

  const UserPreferencesState({
    required this.initialized,
    required this.userName,
    required this.locale,
    required this.totalPlaytime,
    required this.modeDurations,
    required this.algorithmsExecuted,
    required this.requiresName,
  });

  factory UserPreferencesState.initial() => UserPreferencesState(
    initialized: false,
    userName: null,
    locale: const Locale('es'),
    totalPlaytime: Duration.zero,
    modeDurations: {for (final mode in GameMode.values) mode: Duration.zero},
    algorithmsExecuted: 0,
    requiresName: true,
  );

  UserPreferencesState copyWith({
    bool? initialized,
    String? userName,
    Locale? locale,
    Duration? totalPlaytime,
    Map<GameMode, Duration>? modeDurations,
    int? algorithmsExecuted,
    bool? requiresName,
  }) {
    return UserPreferencesState(
      initialized: initialized ?? this.initialized,
      userName: userName ?? this.userName,
      locale: locale ?? this.locale,
      totalPlaytime: totalPlaytime ?? this.totalPlaytime,
      modeDurations: modeDurations ?? this.modeDurations,
      algorithmsExecuted: algorithmsExecuted ?? this.algorithmsExecuted,
      requiresName: requiresName ?? this.requiresName,
    );
  }
}
