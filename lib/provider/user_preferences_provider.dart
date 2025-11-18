import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_mode.dart';
import '../models/user_preferences_state.dart';
import '../services/local_storage_service.dart';

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>(
      (ref) => UserPreferencesNotifier(LocalStorageService.instance),
    );

class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  UserPreferencesNotifier(this._storage)
    : super(UserPreferencesState.initial());

  static const _keyUserName = 'user_name';
  static const _keyLocale = 'locale_code';
  static const _keyPlaytime = 'playtime_seconds';
  static const _keyModeTimes = 'playtime_modes';
  static const _keyAlgorithms = 'algorithms_executed';

  final LocalStorageService _storage;

  GameMode? _activeMode;
  DateTime? _sessionStart;
  Completer<void>? _initCompleter;

  Future<void> initialize() async {
    if (state.initialized) return;
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }

    _initCompleter = Completer<void>();
    await _storage.init();

    final name = _storage.readString(_keyUserName);
    final localeRaw = _storage.readString(_keyLocale) ?? 'es';
    final totalSeconds = _storage.readInt(_keyPlaytime) ?? 0;
    final modeJson = _storage.readJson(_keyModeTimes) ?? {};
    final algorithms = _storage.readInt(_keyAlgorithms) ?? 0;

    final locale = Locale(localeRaw);

    final modeDurations = {
      for (final mode in GameMode.values)
        mode: Duration(seconds: (modeJson[mode.storageKey] as int?) ?? 0),
    };

    state = state.copyWith(
      initialized: true,
      userName: name,
      locale: locale,
      totalPlaytime: Duration(seconds: totalSeconds),
      modeDurations: modeDurations,
      algorithmsExecuted: algorithms,
      requiresName: name == null || name.isEmpty,
    );

    _initCompleter?.complete();
    _initCompleter = null;
  }

  Future<void> setUserName(String name) async {
    final trimmed = name.trim();
    await _storage.writeString(_keyUserName, trimmed);
    state = state.copyWith(userName: trimmed, requiresName: false);
  }

  Future<void> setLocale(Locale locale) async {
    await _storage.writeString(_keyLocale, locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> incrementAlgorithms() async {
    final updated = state.algorithmsExecuted + 1;
    await _storage.writeInt(_keyAlgorithms, updated);
    state = state.copyWith(algorithmsExecuted: updated);
  }

  void startSession(GameMode mode) {
    _closeSession();
    _activeMode = mode;
    _sessionStart = DateTime.now();
  }

  Future<void> stopSession(GameMode mode) async {
    if (_activeMode != mode) return;
    await _closeSession();
  }

  Future<void> _closeSession() async {
    if (_activeMode == null || _sessionStart == null) return;
    final elapsed = DateTime.now().difference(_sessionStart!);
    if (elapsed.inMilliseconds <= 0) {
      _activeMode = null;
      _sessionStart = null;
      return;
    }

    final newTotal = state.totalPlaytime + elapsed;
    final updatedModes = Map<GameMode, Duration>.from(state.modeDurations);
    final previous = updatedModes[_activeMode!] ?? Duration.zero;
    updatedModes[_activeMode!] = previous + elapsed;

    await _storage.writeInt(_keyPlaytime, newTotal.inSeconds);
    await _storage.writeJson(_keyModeTimes, {
      for (final entry in updatedModes.entries)
        entry.key.storageKey: entry.value.inSeconds,
    });

    state = state.copyWith(
      totalPlaytime: newTotal,
      modeDurations: updatedModes,
    );

    _activeMode = null;
    _sessionStart = null;
  }

  Future<void> clearAll() async {
    _activeMode = null;
    _sessionStart = null;
    await _storage.clear();
    state = UserPreferencesState.initial();
  }
}
