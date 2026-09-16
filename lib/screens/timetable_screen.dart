import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/subject_storage.dart';
import 'subject_add_screen.dart';
import 'subject_detail_screen.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({
    super.key,
    this.onChanged,
  });

  final VoidCallback? onChanged;

  @override
  State<TimetableScreen> createState() =>
      _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  static const days = [
    '월요일',
    '화요일',
    '수요일',
    '목요일',
    '금요일',
    '토요일',
    '일요일',
  ];

  static const shortDays = [
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];

  int _selectedDay = DateTime.now().weekday - 1;

  bool _weeklyView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: true,

        title: const Text(
          '수업',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _weeklyView = !_weeklyView;
              });
            },
            icon: Icon(
              _weeklyView
                  ? Icons.view_list_rounded
                  : Icons.calendar_view_week_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _addSubject,
        child: const Icon(Icons.add_rounded),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: SubjectStorage.load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final subjects =
              snapshot.data ?? [];

          if (_weeklyView) {
            return _weeklyTimetable(subjects);
          }

          return _dayList(subjects);
        },
      ),
    );
  }

  // =========================================================
  // 요일별 목록
  // =========================================================

  Widget _dayList(
    List<Map<String, dynamic>> subjects,
  ) {
    return Column(
      children: [
        const SizedBox(height: 8),

        _daySelector(),

        const SizedBox(height: 12),

        Expanded(
          child: _subjectsForDay(
            subjects,
            days[_selectedDay],
          ),
        ),
      ],
    );
  }

  Widget _daySelector() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
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
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 11,
                    ),
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 2,
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
                    child: Text(
                      shortDays[index],
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color: selected
                            ? Colors.white
                            : AppColors
                                .textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _subjectsForDay(
    List<Map<String, dynamic>> subjects,
    String day,
  ) {
    final list = subjects
        .where(
          (item) => item['day'] == day,
        )
        .toList()
      ..sort(_sortByTime);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 52,
              color:
                  AppColors.primaryLight,
            ),

            const SizedBox(height: 12),

            Text(
              '$day에 등록된 수업이 없어요.',
              style: const TextStyle(
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        100,
      ),
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '${list.length}개의 수업',
          style: const TextStyle(
            fontSize: 13,
            color:
                AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        ...list.map(
          (item) => _subjectCard(item),
        ),
      ],
    );
  }

  // =========================================================
  // 수업 카드
  // =========================================================

  Widget _subjectCard(
    Map<String, dynamic> item,
  ) {
    final start = _timeText(
      item['startHour'],
      item['startMinute'],
    );

    final end = _timeText(
      item['endHour'],
      item['endMinute'],
    );

    final color =
        _colorFrom(item['color']);

    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),
        padding:
            const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 65,
              decoration:
                  BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(
                  5,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '$start - $end',
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          AppColors
                              .textSecondary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    item['subject']
                        ?.toString() ??
                        '',
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  if (item['classroom']
                          ?.toString()
                          .isNotEmpty ==
                      true)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 4,
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

            const Icon(
              Icons.chevron_right_rounded,
              color:
                  AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 주간 시간표
  // =========================================================

  Widget _weeklyTimetable(
    List<Map<String, dynamic>> subjects,
  ) {
    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        100,
      ),
      children: [
        const Padding(
          padding:
              EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Text(
            '주간 시간표',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _weeklyHeader(),

        const SizedBox(height: 6),

        _weeklyGrid(subjects),
      ],
    );
  }

  Widget _weeklyHeader() {
    return Row(
      children: [
        const SizedBox(
          width: 42,
        ),

        ...List.generate(
          7,
          (index) {
            return Expanded(
              child: Center(
                child: Text(
                  shortDays[index],
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _weeklyGrid(
    List<Map<String, dynamic>> subjects,
  ) {
    const firstHour = 8;
    const lastHour = 20;
    const rowHeight = 65.0;

    return SizedBox(
      height:
          (lastHour - firstHour + 1) *
              rowHeight,

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: List.generate(
                lastHour - firstHour + 1,
                (index) {
                  final hour =
                      firstHour + index;

                  return SizedBox(
                    height: rowHeight,
                    child: Align(
                      alignment:
                          Alignment.topCenter,
                      child: Text(
                        '$hour',
                        style:
                            const TextStyle(
                          fontSize: 10,
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: List.generate(
                7,
                (dayIndex) {
                  final daySubjects =
                      subjects
                          .where(
                            (item) =>
                                item['day'] ==
                                days[dayIndex],
                          )
                          .toList();

                  return Expanded(
                    child: _dayColumn(
                      daySubjects,
                      firstHour,
                      rowHeight,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayColumn(
    List<Map<String, dynamic>> subjects,
    int firstHour,
    double rowHeight,
  ) {
    return Container(
      height: 12 * rowHeight,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: List.generate(
              13,
              (index) {
                return SizedBox(
                  height: rowHeight,
                  child: Container(
                    decoration:
                        BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors
                              .grey
                              .shade200,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          ...subjects.map(
            (subject) {
              final startHour =
                  _toInt(
                subject['startHour'],
              );

              final startMinute =
                  _toInt(
                subject['startMinute'],
              );

              final endHour =
                  _toInt(
                subject['endHour'],
              );

              final endMinute =
                  _toInt(
                subject['endMinute'],
              );

              final startMinutes =
                  (startHour - firstHour) *
                          60 +
                      startMinute;

              final duration =
                  (endHour * 60 +
                          endMinute) -
                      (startHour * 60 +
                          startMinute);

              final top =
                  startMinutes *
                      rowHeight /
                      60;

              final height =
                  duration *
                      rowHeight /
                      60;

              return Positioned(
                top: top,
                left: 2,
                right: 2,
                height:
                    height.clamp(
                  25.0,
                  400.0,
                ),
                child:
                    GestureDetector(
                  onTap: () =>
                      _openDetail(
                    subject,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.all(
                      4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          _colorFrom(
                        subject['color'],
                      ).withOpacity(.8),
                      borderRadius:
                          BorderRadius.circular(
                        6,
                      ),
                    ),
                    child: Text(
                      subject['subject']
                              ?.toString() ??
                          '',
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 9,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 추가 / 상세
  // =========================================================

  Future<void> _addSubject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SubjectAddScreen(),
      ),
    );

    setState(() {});
    widget.onChanged?.call();
  }

  Future<void> _openDetail(
    Map<String, dynamic> item,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SubjectDetailScreen(
          subject: item,
        ),
      ),
    );

    setState(() {});
    widget.onChanged?.call();
  }

  // =========================================================
  // 유틸
  // =========================================================

  int _sortByTime(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final aTotal =
        _toInt(a['startHour']) * 60 +
            _toInt(a['startMinute']);

    final bTotal =
        _toInt(b['startHour']) * 60 +
            _toInt(b['startMinute']);

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

  String _timeText(
    dynamic hour,
    dynamic minute,
  ) {
    return '${_toInt(hour).toString().padLeft(2, '0')}:'
        '${_toInt(minute).toString().padLeft(2, '0')}';
  }

  Color _colorFrom(dynamic value) {
    final number = _toInt(value);

    if (number == 0) {
      return AppColors.primary;
    }

    return Color(number);
  }
}