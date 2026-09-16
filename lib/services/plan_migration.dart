import 'package:shared_preferences/shared_preferences.dart';

import '../models/plan.dart';
import '../models/routine.dart';
import '../models/todo.dart';
import 'plan_storage.dart';
import 'routine_storage.dart';
import 'todo_storage.dart';

class PlanMigration {
  PlanMigration._();

  static const String _migrationKey = 'planet_v2_migrated';

  static Future<void> migrate() async {
    final prefs = await SharedPreferences.getInstance();

    // 이미 이전 작업을 했다면 다시 하지 않음.
    final migrated = prefs.getBool(_migrationKey) ?? false;

    if (migrated) {
      return;
    }

    // 기존 계획 불러오기
    final oldPlans = await PlanStorage.load();

    if (oldPlans.isEmpty) {
      await prefs.setBool(_migrationKey, true);
      return;
    }

    // 현재 새 데이터
    final routines = await RoutineStorage.load();
    final todos = await TodoStorage.load();

    // 중복 방지용 ID
    final routineIds =
        routines.map((routine) => routine.id).toSet();

    final todoIds =
        todos.map((todo) => todo.id).toSet();

    for (final plan in oldPlans) {
      // 반복 계획 → 루틴
      if (plan.repeatEnabled) {
        if (routineIds.contains(plan.id)) {
          continue;
        }

        routines.add(
          Routine(
            id: plan.id,
            title: plan.title,
            category: plan.category,
            memo: plan.memo,
            startDate: plan.startDate,
            endDate: plan.endDate,
            repeatType: plan.repeatType,
            repeatCount: plan.repeatCount,
            repeatDays: List<int>.from(
              plan.repeatDays,
            ),
            hasTime: plan.hasTime,
            startHour: plan.startHour,
            startMinute: plan.startMinute,
            endHour: plan.endHour,
            endMinute: plan.endMinute,
            notification: plan.notification,
            completedDates: List<String>.from(
              plan.completedDates,
            ),
            createdAt: plan.createdAt,
          ),
        );

        routineIds.add(plan.id);
      }

      // 반복이 없는 계획 → 할 일
      else {
        if (todoIds.contains(plan.id)) {
          continue;
        }

        todos.add(
          Todo(
            id: plan.id,
            title: plan.title,
            category: plan.category,
            memo: plan.memo,
            date: plan.startDate,
            hasTime: plan.hasTime,
            startHour: plan.startHour,
            startMinute: plan.startMinute,
            endHour: plan.endHour,
            endMinute: plan.endMinute,
            notification: plan.notification,
            completed:
                plan.completedDates.contains(
              _dateKey(plan.startDate),
            ),
            createdAt: plan.createdAt,
          ),
        );

        todoIds.add(plan.id);
      }
    }

    // 새 저장소에 저장
    await RoutineStorage.save(routines);
    await TodoStorage.save(todos);

    // 마이그레이션 완료 표시
    await prefs.setBool(
      _migrationKey,
      true,
    );
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}