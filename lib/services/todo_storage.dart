import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoStorage {
  TodoStorage._();

  static const String _key = 'todos';

  static Future<List<Todo>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) {
      return [];
    }

    try {
      final values = jsonDecode(raw) as List<dynamic>;

      return values
          .map(
            (value) => Todo.fromMap(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(
        todos.map((todo) => todo.toMap()).toList(),
      ),
    );
  }
}