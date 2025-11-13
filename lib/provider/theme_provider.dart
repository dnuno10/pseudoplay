import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../managers/user_preferences_manager.dart';

final themeProvider = NotifierProvider<ThemeController, bool>(
  ThemeController.new,
);

class ThemeController extends Notifier<bool> {
  late final UserPreferencesManager _prefs;

  @override
  bool build() {
    _prefs = ref.read(userPreferencesManagerProvider);
    return _prefs.getModoOscuro();
  }

  Future<void> toggle(bool val) async {
    state = val;
    await _prefs.setModoOscuro(val);
  }
}
