// storage_helper.dart

import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static SharedPreferences? _prefs;
  static final Map<String, dynamic> _memoryStorage = {};
  static bool _useMemoryStorage = false;

  // Initialize SharedPreferences once
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _useMemoryStorage = false;
    } catch (e) {
      print('SharedPreferences initialization failed: $e');
      _useMemoryStorage = true;
    }
  }

  static Future<void> setBool(String key, bool value) async {
    if (_useMemoryStorage || _prefs == null) {
      _memoryStorage[key] = value;
      return;
    }
    
    try {
      await _prefs!.setBool(key, value);
    } catch (e) {
      print('SharedPreferences setBool failed: $e');
      _memoryStorage[key] = value;
    }
  }

  static Future<void> setString(String key, String value) async {
    if (_useMemoryStorage || _prefs == null) {
      _memoryStorage[key] = value;
      return;
    }
    
    try {
      await _prefs!.setString(key, value);
    } catch (e) {
      print('SharedPreferences setString failed: $e');
      _memoryStorage[key] = value;
    }
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    if (_useMemoryStorage || _prefs == null) {
      return _memoryStorage[key] as bool? ?? defaultValue;
    }
    
    try {
      return _prefs!.getBool(key) ?? defaultValue;
    } catch (e) {
      print('SharedPreferences getBool failed: $e');
      return _memoryStorage[key] as bool? ?? defaultValue;
    }
  }

  static Future<String?> getString(String key) async {
    if (_useMemoryStorage || _prefs == null) {
      return _memoryStorage[key] as String?;
    }
    
    try {
      return _prefs!.getString(key);
    } catch (e) {
      print('SharedPreferences getString failed: $e');
      return _memoryStorage[key] as String?;
    }
  }

  static Future<void> remove(String key) async {
    if (_useMemoryStorage || _prefs == null) {
      _memoryStorage.remove(key);
      return;
    }
    
    try {
      await _prefs!.remove(key);
    } catch (e) {
      print('SharedPreferences remove failed: $e');
      _memoryStorage.remove(key);
    }
  }

  static Future<void> clear() async {
    if (_useMemoryStorage || _prefs == null) {
      _memoryStorage.clear();
      return;
    }
    
    try {
      await _prefs!.clear();
    } catch (e) {
      print('SharedPreferences clear failed: $e');
      _memoryStorage.clear();
    }
  }
}