import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _ensurePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('LocalStorageService not initialized');
    }
    return prefs;
  }

  String? readString(String key) => _ensurePrefs.getString(key);
  int? readInt(String key) => _ensurePrefs.getInt(key);
  bool? readBool(String key) => _ensurePrefs.getBool(key);

  Future<void> writeString(String key, String value) async {
    await _ensurePrefs.setString(key, value);
  }

  Future<void> writeInt(String key, int value) async {
    await _ensurePrefs.setInt(key, value);
  }

  Future<void> writeBool(String key, bool value) async {
    await _ensurePrefs.setBool(key, value);
  }

  Future<void> remove(String key) async {
    await _ensurePrefs.remove(key);
  }

  Future<void> clear() async {
    await _ensurePrefs.clear();
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await _ensurePrefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? readJson(String key) {
    final raw = _ensurePrefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
