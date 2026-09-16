import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/plan.dart';
import 'schedule_storage.dart';
import 'task_storage.dart';

class PlanStorage {
  PlanStorage._();

  static const String _key = 'plans';
  static const String _migrationKey = 'plans_migrated';

  static Future<List<Plan>> load() async {
    final prefs = await SharedPreferences.getInstance();

    final migrated =
        prefs.getBool(_migrationKey) ?? false;

    if (!migrated) {
      await _migrateOldData();
    }

    final raw = prefs.getString(_key);

    if (raw == null) {
      return [];
    }

    try {
      final values = jsonDecode(raw) as List<dynamic>;

      return values
          .map(
            (value) => Plan.fromMap(
              Map<String, dynamic>.from(
                value as Map,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(
    List<Plan> plans,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(
        plans
            .map(
              (plan) => plan.toMap(),
            )
            .toList(),
      ),
    );

    await prefs.setBool(
      _migrationKey,
      true,
    );
  }

  static Future<void> _migrateOldData() async {
    final prefs =
        await SharedPreferences.getInstance();

    final List<Plan> plans = [];

    // ==================================================
    // 기존 할 일
    // ==================================================

    final tasks =
        await TaskStorage.load();

    for (final task in tasks) {
      final date =
          DateTime.tryParse(
                task['date']?.toString() ?? '',
              ) ??
              DateTime.now();

      final completed =
          task['completed'] == true;

      plans.add(
        Plan(
          id:
              task['id']?.toString() ??
              DateTime.now()
                  .microsecondsSinceEpoch
                  .toString(),

          title:
              task['title']?.toString() ??
              '할 일',

          category:
              task['category']?.toString() ??
              '개인',

          memo: '',

          type: 'todo',

          projectId: null,

          hasDate: true,

          startDate: date,

          endDate: date,

          repeatEnabled: false,

          repeatType: 'none',

          repeatCount: 1,

          repeatDays: [],

          hasTime: false,

          notification: true,

          completedDates:
              completed
                  ? [_dateKey(date)]
                  : [],

          createdAt:
              DateTime.tryParse(
                    task['createdAt']
                            ?.toString() ??
                        '',
                  ) ??
                  DateTime.now(),
        ),
      );
    }

    // ==================================================
    // 기존 일정
    // ==================================================

    final schedules =
        await ScheduleStorage.load();

    for (final schedule in schedules) {
      final date =
          DateTime.tryParse(
                schedule['date']?.toString() ??
                    '',
              ) ??
              DateTime.now();

      plans.add(
        Plan(
          id:
              schedule['id']?.toString() ??
              DateTime.now()
                  .microsecondsSinceEpoch
                  .toString(),

          title:
              schedule['title']?.toString() ??
              '일정',

          category:
              schedule['category']?.toString() ??
              '개인',

          memo:
              schedule['memo']?.toString() ??
              '',

          type: 'todo',

          projectId: null,

          hasDate: true,

          startDate: date,

          endDate: date,

          repeatEnabled: false,

          repeatType: 'none',

          repeatCount: 1,

          repeatDays: [],

          hasTime: true,

          startHour:
              _toInt(
                schedule['startHour'],
              ),

          startMinute:
              _toInt(
                schedule['startMinute'],
              ),

          endHour:
              _toInt(
                schedule['endHour'],
              ),

          endMinute:
              _toInt(
                schedule['endMinute'],
              ),

          notification:
              schedule['notification'] !=
                  false,

          completedDates: [],

          createdAt: DateTime.now(),
        ),
      );
    }

    await prefs.setString(
      _key,
      jsonEncode(
        plans
            .map(
              (plan) => plan.toMap(),
            )
            .toList(),
      ),
    );

    await prefs.setBool(
      _migrationKey,
      true,
    );
  }

  static String _dateKey(
    DateTime date,
  ) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static int? _toInt(
    dynamic value,
  ) {
    if (value is int) return value;

    return int.tryParse(
      value?.toString() ?? '',
    );
  }
}