import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/project.dart';

class ProjectStorage {
  ProjectStorage._();

  static const String _key = 'projects';

  static Future<List<Project>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return [];

    try {
      final values = jsonDecode(raw) as List<dynamic>;

      return values
          .map(
            (value) => Project.fromMap(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(
        projects.map((project) => project.toMap()).toList(),
      ),
    );
  }
}