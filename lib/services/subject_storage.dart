import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SubjectStorage {
  SubjectStorage._();
  static const _key = 'subjects';

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final values = jsonDecode(raw) as List<dynamic>;
      return values.map((value) => Map<String, dynamic>.from(value as Map)).toList();
    } on FormatException {
      return [];
    }
  }

  static Future<void> save(List<Map<String, dynamic>> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(subjects));
  }
}
