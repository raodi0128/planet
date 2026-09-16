import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';

class CategoryStorage {
  CategoryStorage._();

  static const String _key =
      'plan_categories';

  static Future<List<PlanCategory>> load() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(_key);

    if (raw == null) {
      final defaults =
          _defaultCategories();

      await save(defaults);

      return defaults;
    }

    try {
      final values =
          jsonDecode(raw) as List<dynamic>;

      return values
          .map(
            (value) => PlanCategory.fromMap(
              Map<String, dynamic>.from(
                value as Map,
              ),
            ),
          )
          .toList();
    } catch (_) {
      final defaults =
          _defaultCategories();

      await save(defaults);

      return defaults;
    }
  }

  static Future<void> save(
    List<PlanCategory> categories,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(
        categories
            .map(
              (category) =>
                  category.toMap(),
            )
            .toList(),
      ),
    );
  }

  static List<PlanCategory>
      _defaultCategories() {
    return [
      const PlanCategory(
        id: 'school',
        name: '학교',
        colorValue: 0xFF5B8DEF,
      ),
      const PlanCategory(
        id: 'work',
        name: '업무',
        colorValue: 0xFF9B7EDE,
      ),
      const PlanCategory(
        id: 'health',
        name: '운동',
        colorValue: 0xFF4CAF7D,
      ),
      const PlanCategory(
        id: 'hobby',
        name: '취미',
        colorValue: 0xFFFF9F68,
      ),
      const PlanCategory(
        id: 'life',
        name: '생활',
        colorValue: 0xFF7AA7D9,
      ),
      const PlanCategory(
        id: 'appointment',
        name: '약속',
        colorValue: 0xFFE77D9A,
      ),
      const PlanCategory(
        id: 'development',
        name: '개발',
        colorValue: 0xFF4B9CD3,
      ),
      const PlanCategory(
        id: 'drawing',
        name: '그림',
        colorValue: 0xFFD98BC3,
      ),
      const PlanCategory(
        id: 'music',
        name: '음악',
        colorValue: 0xFF8B7CC8,
      ),
      const PlanCategory(
        id: 'study',
        name: '공부',
        colorValue: 0xFFE0A458,
      ),
      const PlanCategory(
        id: 'personal',
        name: '개인',
        colorValue: 0xFF8E9AAF,
      ),
      const PlanCategory(
        id: 'etc',
        name: '기타',
        colorValue: 0xFF9E9E9E,
      ),
    ];
  }
}