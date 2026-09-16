import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';

class RoutineStorage {
  RoutineStorage._();

  static const String _key = 'routines';

  static Future<List<Routine>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) {
      return [];
    }

    try {
      final values = jsonDecode(raw) as List<dynamic>;

      return values
          .map(
            (value) => Routine.fromMap(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<Routine> routines) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(
        routines.map((routine) => routine.toMap()).toList(),
      ),
    );
  }
}