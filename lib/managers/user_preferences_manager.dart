import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userPreferencesManagerProvider = Provider(
  (ref) => UserPreferencesManager(),
);

class UserPreferencesManager {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Guardar idioma
  Future<void> setIdioma(String value) async {
    await _prefs?.setString("idioma", value);
  }

  String getIdioma() {
    return _prefs?.getString("idioma") ?? "es";
  }

  /// Guardar modo oscuro
  Future<void> setModoOscuro(bool value) async {
    await _prefs?.setBool("dark_mode", value);
  }

  bool getModoOscuro() {
    return _prefs?.getBool("dark_mode") ?? false;
  }
}
