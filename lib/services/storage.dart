import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = "habits";

  static Future<void> saveHabits(List<Map<String, dynamic>> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(habits);
      await prefs.setString(_key, data);
    } catch (e) {
      print("save error: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);

      if (data == null) return [];

      final decoded = jsonDecode(data) as List;

      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print("load error: $e");
      return [];
    }
  }
}