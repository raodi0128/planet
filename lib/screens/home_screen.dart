
import 'package:flutter/material.dart';

import '../core/assets/app_assets.dart';
import '../core/theme/app_theme.dart';
import '../models/plan.dart';
import '../services/plan_storage.dart';
import '../services/subject_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.refreshKey,
    this.onClassesTap,
  });

  final int? refreshKey;

  // 홈 → 수업 화면
  final VoidCallback? onClassesTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _days = [
    '월요일',
    '화요일',
    '수요일',
    '목요일',
    '금요일',
    '토요일',
    '일요일',
  ];

  static const _shortDays = [
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];

  int _selectedDay = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();

    final weekday = DateTime.now().weekday;

    _selectedDay =
        weekday >= 1 && weekday <= 7
            ? weekday - 1
            : 0;
  }

  @override
  void didUpdateWidget(
    covariant HomeScreen oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshKey != widget.refreshKey) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        key: ValueKey(widget.refreshKey),
        future: Future.wait([
          SubjectStorage.load(),
          PlanStorage.load(),
        ]),
        builder: (_, snapshot) {
          final subjects =
              snapshot.data?[0]
                      as List<Map<String, dynamic>>? ??
                  [];

          final plans =
              snapshot.data?[1]
                      as List<Plan>? ??
                  [];

          final now = DateTime.now();

          final selectedDate = _dateForSelectedDay(
            now,
            _selectedDay,
          );

          final selectedDayName =
              _days[_selectedDay];

          final classes = subjects
              .where(
                (item) =>
                    item['day'] ==
                    selectedDayName,
              )
              .toList()
            ..sort(_sortByStartTime);

          final selectedPlans = plans
              .where(
                (plan) => _isActiveOn(
                  plan,
                  selectedDate,
                ),
              )
              .toList();

          final dateKey =
              _dateKey(selectedDate);

          final completed =
              selectedPlans.where(
            (plan) =>
                plan.completedDates
                    .contains(dateKey),
          ).length;

          final schedules =
              selectedPlans
                  .where(
                    (plan) =>
                        plan.hasTime,
                  )
                  .toList()
                ..sort(
                  _sortPlansByTime,
                );

          final remaining =
              selectedPlans.where(
            (plan) =>
                !plan.completedDates
                    .contains(dateKey),
          ).toList();

          return SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              95,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _topBar(),

                const SizedBox(height: 24),

                Text(
                  _greeting(now),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _selectedDay ==
                          now.weekday - 1
                      ? '오늘도 내 계획이 빛나길 바라요!'
                      : '${selectedDayName}의 일정을 확인해보세요.',
                  style: const TextStyle(
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 18),

                _weekdaySelector(),

                const SizedBox(height: 18),

                _dateBanner(
                  selectedDate,
                ),

                const SizedBox(height: 24),

                _progress(
                  completed,
                  selectedPlans.length,
                ),

                const SizedBox(height: 24),

                // =====================================================
                // 오늘 수업
                // =====================================================

                _sectionHeader(
                  '오늘 수업',
                  showAll: true,
                ),

                if (classes.isEmpty)
                  _empty(
                    _selectedDay >= 5
                        ? '주말에는 등록된 수업이 없어요.'
                        : '등록된 수업이 없어요.',
                  )
                else
                  ...classes.map(
                    _classCard,
                  ),

                const SizedBox(height: 24),

                // =====================================================
                // 오늘 일정
                // =====================================================

                _sectionHeader(
                  '오늘 일정',
                ),

                if (schedules.isEmpty)
                  _empty(
                    '시간이 지정된 일정이 없어요.',
                  )
                else
                  ...schedules.map(
                    (plan) => _scheduleCard(
                      plan,
                      selectedDate,
                    ),
                  ),

                const SizedBox(height: 24),

                // =====================================================
                // 오늘의 할 일
                // =====================================================

                _sectionHeader(
                  '오늘의 할 일',
                ),

                if (remaining.isEmpty)
                  _empty(
                    '남은 할 일이 없어요.',
                  )
                else
                  ...remaining
                      .take(5)
                      .map(
                        (plan) => _planCard(
                          plan,
                          selectedDate,
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // 상단
  // =========================================================

  Widget _topBar() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'PLANET',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            color: AppColors.navy,
          ),
        ),

        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // 요일 선택
  // =========================================================

  Widget _weekdaySelector() {
    final today =
        DateTime.now().weekday - 1;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: List.generate(
          7,
          (index) {
            final selected =
                index == _selectedDay;

            final isToday =
                index == today;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = index;
                  });
                },
                child: AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  margin:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 2,
                  ),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _shortDays[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                          color: selected
                              ? Colors.white
                              : AppColors
                                  .textSecondary,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Container(
                        width: 5,
                        height: 5,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          color: isToday
                              ? selected
                                  ? Colors.white
                                  : AppColors
                                      .primary
                              : Colors
                                  .transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // 날짜
  // =========================================================

  DateTime _dateForSelectedDay(
    DateTime now,
    int selectedDay,
  ) {
    final currentWeekMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );

    return currentWeekMonday.add(
      Duration(
        days: selectedDay,
      ),
    );
  }

  // =========================================================
  // 인사
  // =========================================================

  String _greeting(DateTime now) {
    if (now.hour < 12) {
      return '좋은 아침이에요. ☀️';
    }

    if (now.hour < 18) {
      return '좋은 오후예요. 🌤️';
    }

    if (now.hour < 22) {
      return '좋은 저녁이에요. 🌙';
    }

    return '오늘도 수고했어요. ✨';
  }

  // =========================================================
  // 날짜 키
  // =========================================================

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // =========================================================
  // 날짜 비교
  // =========================================================

  bool _sameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  // =========================================================
  // 계획 활성 여부
  // =========================================================

  bool _isActiveOn(
    Plan plan,
    DateTime date,
  ) {
    final day = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final start = DateTime(
      plan.startDate.year,
      plan.startDate.month,
      plan.startDate.day,
    );

    if (day.isBefore(start)) {
      return false;
    }

    if (plan.endDate != null) {
      final end = DateTime(
        plan.endDate!.year,
        plan.endDate!.month,
        plan.endDate!.day,
      );

      if (day.isAfter(end)) {
        return false;
      }
    }

    if (!plan.repeatEnabled) {
      return _sameDay(
        plan.startDate,
        date,
      );
    }

    switch (plan.repeatType) {
      case 'daily':
        return true;

      case 'weekly':
        return true;

      case 'specific':
        return plan.repeatDays.contains(
          date.weekday,
        );

      case 'monthly':
        return plan.startDate.day ==
            date.day;

      default:
        return true;
    }
  }

  // =========================================================
  // 정렬
  // =========================================================

  int _sortByStartTime(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final aHour =
        _toInt(a['startHour']);

    final aMinute =
        _toInt(a['startMinute']);

    final bHour =
        _toInt(b['startHour']);

    final bMinute =
        _toInt(b['startMinute']);

    return (aHour * 60 + aMinute)
        .compareTo(
      bHour * 60 + bMinute,
    );
  }

  int _sortPlansByTime(
    Plan a,
    Plan b,
  ) {
    final aTotal =
        (a.startHour ?? 0) * 60 +
            (a.startMinute ?? 0);

    final bTotal =
        (b.startHour ?? 0) * 60 +
            (b.startMinute ?? 0);

    return aTotal.compareTo(bTotal);
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // =========================================================
  // 날짜 배너
  // =========================================================

  Widget _dateBanner(
    DateTime date,
  ) {
    final today =
        DateTime.now();

    final isToday =
        _sameDay(date, today);

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFFE8ECFF),
            Color(0xFFF8F4FF),
          ],
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.year}년 '
                  '${date.month}월 '
                  '${date.day}일 '
                  '${_shortDays[date.weekday - 1]}요일',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  isToday
                      ? '오늘도 차근차근 해봐요! ✨'
                      : '이 날의 일정을 확인해보세요.',
                  style:
                      const TextStyle(
                    color:
                        AppColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Image.asset(
            AppAssets.homePlanet,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
            errorBuilder:
                (_, __, ___) {
              return const Icon(
                Icons.public_rounded,
                size: 46,
                color:
                    AppColors
                        .primaryLight,
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 섹션 제목
  // =========================================================

  Widget _sectionHeader(
    String title, {
    bool showAll = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          if (showAll)
            TextButton(
              onPressed:
                  widget.onClassesTap,
              child: const Text(
                '전체보기',
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // 진행도
  // =========================================================

  Widget _progress(
    int completed,
    int total,
  ) {
    final value = total == 0
        ? 0.0
        : completed / total;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 진행도',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            children: [
              Expanded(
                child:
                    LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  color:
                      AppColors.primary,
                  backgroundColor:
                      AppColors
                          .primaryLight
                          .withOpacity(.25),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Text(
                '${(value * 100).round()}%',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color:
                      AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            '$completed / $total 완료',
            style:
                const TextStyle(
              fontSize: 12,
              color:
                  AppColors
                      .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 빈 상태
  // =========================================================

  Widget _empty(
    String text,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style:
            const TextStyle(
          color:
              AppColors
                  .textSecondary,
        ),
      ),
    );
  }

  // =========================================================
  // 수업 카드
  // =========================================================

  Widget _classCard(
    Map<String, dynamic> item,
  ) {
    final startHour =
        _toInt(item['startHour']);

    final startMinute =
        _toInt(item['startMinute']);

    final endHour =
        _toInt(item['endHour']);

    final endMinute =
        _toInt(item['endMinute']);

    final start =
        '${startHour.toString().padLeft(2, '0')}:'
        '${startMinute.toString().padLeft(2, '0')}';

    final end =
        '${endHour.toString().padLeft(2, '0')}:'
        '${endMinute.toString().padLeft(2, '0')}';

    final colorValue =
        _toInt(item['color']);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 48,
            decoration:
                BoxDecoration(
              color:
                  Color(colorValue),
              borderRadius:
                  BorderRadius.circular(5),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$start - $end',
                  style:
                      const TextStyle(
                    fontSize: 11,
                    color:
                        AppColors
                            .textSecondary,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  item['subject']
                      .toString(),
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                if (item['classroom']
                        ?.toString()
                        .isNotEmpty ==
                    true)
                  Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      top: 3,
                    ),
                    child: Text(
                      item['classroom']
                          .toString(),
                      style:
                          const TextStyle(
                        fontSize: 13,
                        color:
                            AppColors
                                .textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 일정 카드
  // =========================================================

  Widget _scheduleCard(
    Plan plan,
    DateTime date,
  ) {
    final hour =
        (plan.startHour ?? 0)
            .toString()
            .padLeft(2, '0');

    final minute =
        (plan.startMinute ?? 0)
            .toString()
            .padLeft(2, '0');

    final completed =
        plan.completedDates.contains(
      _dateKey(date),
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_rounded,
            color:
                AppColors.primary,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              plan.title,
              style:
                  TextStyle(
                fontWeight:
                    FontWeight.w600,
                decoration: completed
                    ? TextDecoration
                        .lineThrough
                    : null,
              ),
            ),
          ),

          Text(
            '$hour:$minute',
            style:
                const TextStyle(
              color:
                  AppColors
                      .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 할 일 카드
  // =========================================================

  Widget _planCard(
    Plan plan,
    DateTime date,
  ) {
    final completed =
        plan.completedDates.contains(
      _dateKey(date),
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle
                : Icons
                    .radio_button_unchecked,
            color:
                AppColors.primary,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    decoration: completed
                        ? TextDecoration
                            .lineThrough
                        : null,
                    color: completed
                        ? AppColors
                            .textSecondary
                        : AppColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${plan.category}'
                  '${plan.repeatEnabled ? ' · 반복' : ''}',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        AppColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

