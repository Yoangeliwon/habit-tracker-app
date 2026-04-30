import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = "habits";

  static Future<void> saveHabits(List<Map<String, dynamic>> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(habits));
  }

  static Future<List<Map<String, dynamic>>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}