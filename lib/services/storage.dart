import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = "habits";

  static Future<void> saveHabits(List<Map<String, dynamic>> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedData = jsonEncode(habits);
      await prefs.setString(_key, encodedData);
    } catch (e) {
      // ignore error silently for now
    }
  }

  static Future<List<Map<String, dynamic>>> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);

      if (data == null) return [];

      final List decoded = jsonDecode(data);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }
}