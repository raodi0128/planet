import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/plan.dart';
import '../services/plan_storage.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({
    super.key,
    this.refreshKey,
  });

  final int? refreshKey;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Plan> _plans = [];

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant StatisticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshKey != widget.refreshKey) {
      _load();
    }
  }

  Future<void> _load() async {
    final plans = await PlanStorage.load();

    if (!mounted) return;

    setState(() {
      _plans = plans;
    });
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  bool _completed(Plan plan, DateTime date) {
    return plan.completedDates.contains(_dateKey(date));
  }

  int _daysInMonth(DateTime month) {
    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;
  }

  int _completedThisMonth(Plan plan) {
    return plan.completedDates.where((value) {
      final date = DateTime.tryParse(value);

      if (date == null) return false;

      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month;
    }).length;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _isActiveOn(Plan plan, DateTime date) {
    final start = DateTime(
      plan.startDate.year,
      plan.startDate.month,
      plan.startDate.day,
    );

    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (target.isBefore(start)) {
      return false;
    }

    if (plan.endDate != null) {
      final end = DateTime(
        plan.endDate!.year,
        plan.endDate!.month,
        plan.endDate!.day,
      );

      if (target.isAfter(end)) {
        return false;
      }
    }

    if (!plan.repeatEnabled) {
      return true;
    }

    switch (plan.repeatType) {
      case 'daily':
        return true;

      case 'weekly':
        if (plan.repeatDays.isEmpty) {
          return true;
        }

        return plan.repeatDays.contains(date.weekday);

      case 'specific':
        if (plan.repeatDays.isEmpty) {
          return true;
        }

        return plan.repeatDays.contains(date.weekday);

      case 'monthly':
        return date.day == plan.startDate.day;

      default:
        return true;
    }
  }

  String _repeatText(Plan plan) {
    if (!plan.repeatEnabled) {
      return '반복 없음';
    }

    switch (plan.repeatType) {
      case 'daily':
        return '매일';

      case 'weekly':
        if (plan.repeatCount > 0) {
          return '주 ${plan.repeatCount}회';
        }
        return '매주';

      case 'specific':
        if (plan.repeatDays.isEmpty) {
          return '매주';
        }

        final names = <String>[
          '월',
          '화',
          '수',
          '목',
          '금',
          '토',
          '일',
        ];

        return plan.repeatDays
            .where((day) => day >= 1 && day <= 7)
            .map((day) => names[day - 1])
            .join(' · ');

      case 'monthly':
        return '매월';

      default:
        return '반복';
    }
  }

  List<Plan> get _repeatPlans {
    return _plans.where((plan) => plan.repeatEnabled).toList();
  }

  String _monthTitle() {
    return '${_selectedMonth.year}년 ${_selectedMonth.month}월';
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthCalendar(Plan plan) {
    final days = _daysInMonth(_selectedMonth);

    // DateTime.weekday
    // 월=1 ... 일=7
    final firstDay = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );

    final offset = firstDay.weekday - 1;

    final totalCells =
        ((offset + days + 6) ~/ 7) * 7;

    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: const [
            _WeekdayText('월'),
            _WeekdayText('화'),
            _WeekdayText('수'),
            _WeekdayText('목'),
            _WeekdayText('금'),
            _WeekdayText('토'),
            _WeekdayText('일'),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: totalCells,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            if (index < offset ||
                index >= offset + days) {
              return const SizedBox();
            }

            final day = index - offset + 1;

            final date = DateTime(
              _selectedMonth.year,
              _selectedMonth.month,
              day,
            );

            final active = _isActiveOn(plan, date);
            final completed = _completed(plan, date);
            final isToday = _sameDay(date, today);

            Color backgroundColor;

            if (completed) {
              backgroundColor = AppColors.primary;
            } else if (active) {
              backgroundColor = Colors.grey.shade100;
            } else {
              backgroundColor = Colors.grey.shade50;
            }

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4),
                border: isToday
                    ? Border.all(
                        color: AppColors.primary,
                        width: 1.3,
                      )
                    : null,
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: completed || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: completed
                      ? Colors.white
                      : active
                          ? Colors.black87
                          : Colors.grey.shade400,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _planStatistics(Plan plan) {
    final completedCount = _completedThisMonth(plan);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plan.category,
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            _repeatText(plan),
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                '수행 ',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '$completedCount회',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          _monthCalendar(plan),
        ],
      ),
    );
  }

  Widget _empty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 42,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            '반복 계획이 없어요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '반복 계획을 추가하면\n월간 수행 기록이 표시돼요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repeatPlans = _repeatPlans;

    final totalCompleted = repeatPlans.fold<int>(
      0,
      (sum, plan) => sum + _completedThisMonth(plan),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '통계',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              30,
            ),
            children: [
              Row(
                children: [
                  _summaryCard(
                    '반복 계획',
                    '${repeatPlans.length}개',
                    Icons.repeat_rounded,
                  ),
                  const SizedBox(width: 10),
                  _summaryCard(
                    '이번 달 수행',
                    '$totalCompleted회',
                    Icons.check_circle_outline_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '월간 통계',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                    ),
                  ),

                  Text(
                    _monthTitle(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (repeatPlans.isEmpty)
                _empty()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: repeatPlans.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.76,
                  ),
                  itemBuilder: (context, index) {
                    return _planStatistics(
                      repeatPlans[index],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayText extends StatelessWidget {
  const _WeekdayText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}