import 'package:flutter/material.dart';

import '../models/plan.dart';
import '../services/plan_storage.dart';
import '../services/subject_storage.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    this.refreshKey,
  });

  final int? refreshKey;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  // 0 = 월간 / 1 = 주간 / 2 = 일간
  int _viewType = 0;

  // 주간 화면
  // false = 목록 / true = 시간표
  bool _weeklyTimetable = false;

  List<Plan> _plans = [];
  List<dynamic> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(
    covariant CalendarScreen oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshKey != widget.refreshKey) {
      _loadData();
    }
  }

  // ============================================================
  // 데이터
  // ============================================================

  Future<void> _loadData() async {
    final plans = await PlanStorage.load();
    final subjects = await SubjectStorage.load();

    if (!mounted) return;

    setState(() {
      _plans = plans;
      _subjects = subjects;
    });
  }

  // ============================================================
  // 날짜
  // ============================================================

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  bool _sameDate(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _weekdayName(int weekday) {
    const names = [
      '월요일',
      '화요일',
      '수요일',
      '목요일',
      '금요일',
      '토요일',
      '일요일',
    ];

    return names[weekday - 1];
  }

  String _shortWeekday(int weekday) {
    const names = [
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
      '일',
    ];

    return names[weekday - 1];
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return day.subtract(
      Duration(days: day.weekday - 1),
    );
  }

  DateTime _endOfWeek(DateTime date) {
    return _startOfWeek(date).add(
      const Duration(days: 6),
    );
  }

  String _two(int value) {
    return value.toString().padLeft(2, '0');
  }

  // ============================================================
  // 계획 활성 날짜
  // ============================================================

  bool _isPlanActiveOn(
    Plan plan,
    DateTime date,
  ) {
    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final start = DateTime(
      plan.startDate.year,
      plan.startDate.month,
      plan.startDate.day,
    );

    final end = plan.endDate == null
        ? start
        : DateTime(
            plan.endDate!.year,
            plan.endDate!.month,
            plan.endDate!.day,
          );

    if (target.isBefore(start)) {
      return false;
    }

    if (target.isAfter(end)) {
      return false;
    }

    if (!plan.repeatEnabled) {
      return _sameDate(
        target,
        start,
      );
    }

    switch (plan.repeatType) {
      case 'daily':
        return true;

      case 'weekly':
        return true;

      case 'specific':
        return plan.repeatDays.contains(
          target.weekday,
        );

      case 'monthly':
        return target.day == start.day;

      default:
        return false;
    }
  }

  List<Plan> _plansForDate(
    DateTime date,
  ) {
    return _plans.where(
      (plan) {
        return _isPlanActiveOn(
          plan,
          date,
        );
      },
    ).toList();
  }

  List<Plan> _completedPlansForDate(
    DateTime date,
  ) {
    final key = _dateKey(date);

    return _plans.where(
      (plan) {
        return _isPlanActiveOn(
              plan,
              date,
            ) &&
            plan.completedDates.contains(
              key,
            );
      },
    ).toList();
  }

  // ============================================================
  // 수업
  // ============================================================

  List<dynamic> _subjectsForDate(
    DateTime date,
  ) {
    final weekday = _weekdayName(
      date.weekday,
    );

    return _subjects.where(
      (subject) {
        try {
          return subject.day == weekday;
        } catch (_) {
          return false;
        }
      },
    ).toList();
  }

  String _subjectName(dynamic subject) {
    try {
      return subject.subject.toString();
    } catch (_) {
      return '';
    }
  }

  String _subjectClassroom(dynamic subject) {
    try {
      return subject.classroom.toString();
    } catch (_) {
      return '';
    }
  }

  int? _subjectStartHour(dynamic subject) {
    try {
      return subject.startHour as int?;
    } catch (_) {
      return null;
    }
  }

  int? _subjectStartMinute(dynamic subject) {
    try {
      return subject.startMinute as int?;
    } catch (_) {
      return null;
    }
  }

  int? _subjectEndHour(dynamic subject) {
    try {
      return subject.endHour as int?;
    } catch (_) {
      return null;
    }
  }

  int? _subjectEndMinute(dynamic subject) {
    try {
      return subject.endMinute as int?;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // 기본 화면
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '캘린더',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildViewSelector(),
          Expanded(
            child: IndexedStack(
              index: _viewType,
              children: [
                _buildMonthlyView(),
                _buildWeeklyView(),
                _buildDailyView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 월간 / 주간 / 일간
  // ============================================================

  Widget _buildViewSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        12,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _viewButton('월간', 0),
            _viewButton('주간', 1),
            _viewButton('일간', 2),
          ],
        ),
      ),
    );
  }

  Widget _viewButton(
    String text,
    int index,
  ) {
    final selected = _viewType == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _viewType = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 월간
  // ============================================================

  Widget _buildMonthlyView() {
    final firstDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );

    final lastDay = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    );

    final cells = <Widget>[];

    for (int i = 1; i < firstDay.weekday; i++) {
      cells.add(
        const SizedBox(),
      );
    }

    for (int day = 1; day <= lastDay.day; day++) {
      cells.add(
        _buildMonthDay(
          DateTime(
            _selectedDate.year,
            _selectedDate.month,
            day,
          ),
        ),
      );
    }

    final completed =
        _completedPlansForDate(
      _selectedDate,
    );

    return Column(
      children: [
        _buildMonthHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Row(
            children: List.generate(
              7,
              (index) {
                return Expanded(
                  child: Center(
                    child: Text(
                      _shortWeekday(
                        index + 1,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: index >= 5
                            ? Colors.grey.shade500
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.82,
            children: cells,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildCompletedArea(
            completed,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        14,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                  1,
                );
              });
            },
            icon: const Icon(
              Icons.chevron_left,
            ),
          ),
          Text(
            '${_selectedDate.year}년 ${_selectedDate.month}월',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                  1,
                );
              });
            },
            icon: const Icon(
              Icons.chevron_right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDay(
    DateTime date,
  ) {
    final selected =
        _sameDate(date, _selectedDate);

    final completed =
        _completedPlansForDate(date);

    final hasCompleted =
        completed.isNotEmpty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected
              ? Colors.black.withValues(
                  alpha: 0.06,
                )
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: hasCompleted
                    ? BoxDecoration(
                        color: Colors.yellow
                            .withValues(
                          alpha: 0.45,
                        ),
                        borderRadius:
                            BorderRadius.circular(5),
                      )
                    : null,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (hasCompleted)
              Positioned(
                bottom: 3,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: List.generate(
                    completed.length > 3
                        ? 3
                        : completed.length,
                    (_) {
                      return Container(
                        width: 4,
                        height: 4,
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 1,
                        ),
                        decoration:
                            const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedArea(
    List<Plan> completed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xfffafafa),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDate.month}월 '
            '${_selectedDate.day}일 '
            '${_weekdayName(_selectedDate.weekday)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (completed.isEmpty)
            Text(
              '완료한 일이 없습니다.',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: completed.length,
                itemBuilder: (
                  context,
                  index,
                ) {
                  final plan =
                      completed[index];

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 28,
                          decoration:
                              BoxDecoration(
                            color: Colors.yellow
                                .withValues(
                              alpha: 0.65,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            plan.title,
                            style:
                                const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.check,
                          size: 18,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 주간
  // ============================================================

  Widget _buildWeeklyView() {
    return Column(
      children: [
        _buildWeekHeader(),
        Expanded(
          child: _weeklyTimetable
              ? _buildWeeklyTimetable()
              : _buildWeeklyList(),
        ),
      ],
    );
  }

  // 오른쪽 위에서 목록 / 시간표 전환
  Widget _buildWeekHeader() {
    final start =
        _startOfWeek(_selectedDate);

    final end =
        _endOfWeek(_selectedDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate =
                    _selectedDate.subtract(
                  const Duration(days: 7),
                );
              });
            },
            icon: const Icon(
              Icons.chevron_left,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${start.month}월 '
                  '${((start.day - 1) ~/ 7) + 1}주',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${start.month}/${start.day} ~ '
                  '${end.month}/${end.day}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildWeekViewToggle(),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate =
                    _selectedDate.add(
                  const Duration(days: 7),
                );
              });
            },
            icon: const Icon(
              Icons.chevron_right,
            ),
          ),
        ],
      ),
    );
  }
Widget _buildWeekViewToggle() {
  return GestureDetector(
    onTap: () {
      setState(() {
        _weeklyTimetable = !_weeklyTimetable;
      });
    },
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        _weeklyTimetable
            ? Icons.view_list_rounded
            : Icons.calendar_view_week_rounded,
        size: 20,
        color: Colors.black87,
      ),
    ),
  );
}

  // ============================================================
  // 주간 목록
  // ============================================================

  Widget _buildWeeklyList() {
    final start =
        _startOfWeek(_selectedDate);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        20,
      ),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: 8,
      itemBuilder: (
        context,
        index,
      ) {
        if (index == 0) {
          final end =
              start.add(
            const Duration(days: 6),
          );

          return _buildWeekInfoCard(
            start,
            end,
          );
        }

        final date =
            start.add(
          Duration(days: index - 1),
        );

        return _buildWeekDayCard(
          date,
        );
      },
    );
  }

  Widget _buildWeekInfoCard(
    DateTime start,
    DateTime end,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            '${start.month}월 '
            '${((start.day - 1) ~/ 7) + 1}주',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${start.month}/${start.day} ~ '
            '${end.month}/${end.day}',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.7,
              ),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDayCard(
    DateTime date,
  ) {
    final plans =
        _plansForDate(date);

    final subjects =
        _subjectsForDate(date);

    final total =
        subjects.length + plans.length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          _viewType = 2;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _sameDate(
            date,
            DateTime.now(),
          )
              ? Colors.black.withValues(
                  alpha: 0.04,
                )
              : Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _shortWeekday(
                    date.weekday,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${date.month}/${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (total == 0)
              Text(
                '일정 없음',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              )
            else ...[
              ...subjects.take(2).map(
                (subject) {
                  return _smallEvent(
                    _subjectName(subject),
                    true,
                  );
                },
              ),
              ...plans
                  .take(
                    subjects.length >= 2
                        ? 1
                        : 2,
                  )
                  .map(
                (plan) {
                  return _smallEvent(
                    plan.title,
                    false,
                  );
                },
              ),
              if (total > 3)
                Text(
                  '+${total - 3}개',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _smallEvent(
    String title,
    bool isSubject,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSubject
                  ? Colors.blue
                  : Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 주간 시간표
  // ============================================================

  Widget _buildWeeklyTimetable() {
    final start =
        _startOfWeek(_selectedDate);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.only(
        bottom: 30,
      ),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            children: [
              const SizedBox(
                width: 42,
              ),
              ...List.generate(
                7,
                (index) {
                  final date =
                      start.add(
                    Duration(days: index),
                  );

                  final today = _sameDate(
                    date,
                    DateTime.now(),
                  );

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate =
                              date;
                        });
                      },
                      child: Container(
                        height: 46,
                        decoration:
                            BoxDecoration(
                          color: today
                              ? Colors.black
                                  .withValues(
                                  alpha: 0.06,
                                )
                              : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors
                                  .grey
                                  .shade200,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Text(
                              _shortWeekday(
                                date.weekday,
                              ),
                              style:
                                  const TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              '${date.month}/${date.day}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors
                                    .grey
                                    .shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // 시간 영역
          SizedBox(
            height: 14 * 72,
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 42,
                  child: _buildWeeklyTimeLabels(),
                ),
                ...List.generate(
                  7,
                  (index) {
                    final date =
                        start.add(
                      Duration(days: index),
                    );

                    return Expanded(
                      child:
                          _buildWeeklyDayColumn(
                        date,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTimeLabels() {
    return Column(
      children: List.generate(
        14,
        (index) {
          final hour = index + 8;

          return SizedBox(
            height: 72,
            child: Align(
              alignment:
                  Alignment.topCenter,
              child: Padding(
                padding:
                    const EdgeInsets.only(
                  top: 3,
                ),
                child: Text(
                  '$hour:00',
                  style: TextStyle(
                    fontSize: 8,
                    color:
                        Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyDayColumn(
    DateTime date,
  ) {
    final subjects =
        _subjectsForDate(date);

    final plans =
        _plansForDate(date)
            .where(
              (plan) =>
                  plan.hasTime &&
                  plan.startHour != null &&
                  plan.startMinute != null,
            )
            .toList();

    return SizedBox(
      height: 14 * 72,
      child: Stack(
        children: [
          // 시간선
          ...List.generate(
            14,
            (index) {
              return Positioned(
                top: index * 72,
                left: 0,
                right: 0,
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color:
                            Colors.grey.shade100,
                      ),
                      bottom: BorderSide(
                        color:
                            Colors.grey.shade100,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 수업
          ...subjects.map(
            _buildWeeklySubjectBlock,
          ),

          // 계획
          ...plans.map(
            _buildWeeklyPlanBlock,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySubjectBlock(
    dynamic subject,
  ) {
    final startHour =
        _subjectStartHour(subject);

    final startMinute =
        _subjectStartMinute(subject);

    final endHour =
        _subjectEndHour(subject);

    final endMinute =
        _subjectEndMinute(subject);

    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return const SizedBox();
    }

    final startMinutes =
        startHour * 60 + startMinute;

    final endMinutes =
        endHour * 60 + endMinute;

    final top =
        (startMinutes - 8 * 60) *
            72 /
            60;

    final height =
        ((endMinutes - startMinutes) *
                72 /
                60)
            .clamp(32.0, 500.0);

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(
            alpha: 0.13,
          ),
          borderRadius:
              BorderRadius.circular(6),
          border: Border.all(
            color: Colors.blue.withValues(
              alpha: 0.28,
            ),
          ),
        ),
        child: Text(
          _subjectName(subject),
          maxLines: 4,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyPlanBlock(
    Plan plan,
  ) {
    if (!plan.hasTime ||
        plan.startHour == null ||
        plan.startMinute == null) {
      return const SizedBox();
    }

    final startMinutes =
        plan.startHour! * 60 +
            plan.startMinute!;

    final top =
        (startMinutes - 8 * 60) *
            72 /
            60;

    double height = 52;

    if (plan.endHour != null &&
        plan.endMinute != null) {
      final endMinutes =
          plan.endHour! * 60 +
              plan.endMinute!;

      height =
          ((endMinutes - startMinutes) *
                  72 /
                  60)
              .clamp(30.0, 500.0);
    }

    return Positioned(
      top: top,
      left: 3,
      right: 3,
      height: height,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(
            alpha: 0.13,
          ),
          borderRadius:
              BorderRadius.circular(6),
          border: Border.all(
            color: Colors.grey.withValues(
              alpha: 0.3,
            ),
          ),
        ),
        child: Text(
          plan.title,
          maxLines: 4,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 일간
  // ============================================================

  Widget _buildDailyView() {
    final subjects =
        _subjectsForDate(
      _selectedDate,
    );

    final plans =
        _plansForDate(
      _selectedDate,
    ).where(
      (plan) =>
          plan.hasTime &&
          plan.startHour != null &&
          plan.startMinute != null,
    ).toList();

    return Column(
      children: [
        _buildDayHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 55,
                  child:
                      _buildDailyTimeLabels(),
                ),
                Expanded(
                  child: SizedBox(
                    height: 14 * 70,
                    child: Stack(
                      children: [
                        ...List.generate(
                          14,
                          (index) {
                            return Positioned(
                              top: index * 70,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 70,
                                decoration:
                                    BoxDecoration(
                                  border:
                                      Border(
                                    bottom:
                                        BorderSide(
                                      color: Colors
                                          .grey
                                          .shade200,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        ...subjects.map(
                          _buildDailySubjectBlock,
                        ),
                        ...plans.map(
                          _buildDailyPlanBlock,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        16,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate =
                    _selectedDate.subtract(
                  const Duration(days: 1),
                );
              });
            },
            icon: const Icon(
              Icons.chevron_left,
            ),
          ),
          Column(
            children: [
              Text(
                '${_selectedDate.month}월 '
                '${_selectedDate.day}일',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _weekdayName(
                  _selectedDate.weekday,
                ),
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate =
                    _selectedDate.add(
                  const Duration(days: 1),
                );
              });
            },
            icon: const Icon(
              Icons.chevron_right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTimeLabels() {
    return Column(
      children: List.generate(
        14,
        (index) {
          final hour = index + 8;

          return SizedBox(
            height: 70,
            child: Align(
              alignment:
                  Alignment.topCenter,
              child: Text(
                '$hour:00',
                style: TextStyle(
                  fontSize: 10,
                  color:
                      Colors.grey.shade500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailySubjectBlock(
    dynamic subject,
  ) {
    final startHour =
        _subjectStartHour(subject);

    final startMinute =
        _subjectStartMinute(subject);

    final endHour =
        _subjectEndHour(subject);

    final endMinute =
        _subjectEndMinute(subject);

    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return const SizedBox();
    }

    final startMinutes =
        startHour * 60 + startMinute;

    final endMinutes =
        endHour * 60 + endMinute;

    final top =
        (startMinutes - 8 * 60) *
            70 /
            60;

    final height =
        ((endMinutes - startMinutes) *
                70 /
                60)
            .clamp(35.0, 600.0);

    return Positioned(
      top: top,
      left: 6,
      right: 12,
      height: height,
      child: Container(
        padding:
            const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(
            alpha: 0.12,
          ),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue.withValues(
              alpha: 0.3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '${_two(startHour)}:'
              '${_two(startMinute)}'
              ' - '
              '${_two(endHour)}:'
              '${_two(endMinute)}',
              style: TextStyle(
                fontSize: 10,
                color:
                    Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _subjectName(subject),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (_subjectClassroom(subject)
                .isNotEmpty)
              Text(
                _subjectClassroom(subject),
                style: TextStyle(
                  fontSize: 10,
                  color:
                      Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPlanBlock(
    Plan plan,
  ) {
    if (!plan.hasTime ||
        plan.startHour == null ||
        plan.startMinute == null) {
      return const SizedBox();
    }

    final startMinutes =
        plan.startHour! * 60 +
            plan.startMinute!;

    final top =
        (startMinutes - 8 * 60) *
            70 /
            60;

    double height = 65;

    if (plan.endHour != null &&
        plan.endMinute != null) {
      final endMinutes =
          plan.endHour! * 60 +
              plan.endMinute!;

      height =
          ((endMinutes - startMinutes) *
                  70 /
                  60)
              .clamp(35.0, 600.0);
    }

    return Positioned(
      top: top,
      left: 6,
      right: 12,
      height: height,
      child: Container(
        padding:
            const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(
            alpha: 0.12,
          ),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.withValues(
              alpha: 0.3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '${_two(plan.startHour!)}:'
              '${_two(plan.startMinute!)}',
              style: TextStyle(
                fontSize: 10,
                color:
                    Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              plan.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}