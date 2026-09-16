import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TaskStorage {
  TaskStorage._();
  static const _key = 'tasks';

  static Future<List<Map<String, dynamic>>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on FormatException {
      return [];
    }
  }

  static Future<void> save(List<Map<String, dynamic>> tasks) async {
    await (await SharedPreferences.getInstance()).setString(_key, jsonEncode(tasks));
  }
}
