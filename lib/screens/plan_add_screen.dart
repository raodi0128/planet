import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/plan.dart';
import '../models/project.dart';
import '../services/category_storage.dart';
import '../services/plan_storage.dart';
import '../services/project_storage.dart';

class PlanAddScreen extends StatefulWidget {
  const PlanAddScreen({
    super.key,
    this.plan,
  });

  final Plan? plan;

  @override
  State<PlanAddScreen> createState() =>
      _PlanAddScreenState();
}

class _PlanAddScreenState
    extends State<PlanAddScreen> {
  final TextEditingController
      _titleController =
      TextEditingController();

  final TextEditingController
      _memoController =
      TextEditingController();

  String _type = 'todo';

  String _category = '개인';

  String? _projectId;

  bool _hasDate = true;

  DateTime _startDate =
      DateTime.now();

  DateTime? _endDate;

  bool _hasTime = false;

  TimeOfDay? _startTime;

  TimeOfDay? _endTime;

  String _repeatType = 'daily';

  int _repeatCount = 1;

  List<int> _repeatDays = [];

  bool _notification = true;

  List<Project> _projects = [];

  List<PlanCategory> _categories = [];

  @override
  void initState() {
    super.initState();

    _loadData();

    final plan = widget.plan;

    if (plan != null) {
      _titleController.text =
          plan.title;

      _memoController.text =
          plan.memo;

      _type =
          plan.type;

      _category =
          plan.category;

      _projectId =
          plan.projectId;

      _hasDate =
          plan.hasDate;

      _startDate =
          plan.startDate;

      _endDate =
          plan.endDate;

      _hasTime =
          plan.hasTime;

      if (plan.startHour != null &&
          plan.startMinute != null) {
        _startTime =
            TimeOfDay(
          hour: plan.startHour!,
          minute:
              plan.startMinute!,
        );
      }

      if (plan.endHour != null &&
          plan.endMinute != null) {
        _endTime =
            TimeOfDay(
          hour: plan.endHour!,
          minute:
              plan.endMinute!,
        );
      }

      _repeatType =
          plan.repeatType == 'none'
              ? 'daily'
              : plan.repeatType;

      _repeatCount =
          plan.repeatCount;

      _repeatDays =
          List<int>.from(
        plan.repeatDays,
      );

      _notification =
          plan.notification;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final projects =
        await ProjectStorage.load();

    final categories =
        await CategoryStorage.load();

    if (!mounted) return;

    setState(() {
      _projects = projects;
      _categories = categories;

      if (_categories.isNotEmpty &&
          !_categories.any(
            (category) =>
                category.name ==
                _category,
          )) {
        _category =
            _categories.first.name;
      }
    });
  }

  Future<void> _pickDate({
    required bool start,
  }) async {
    final picked =
        await showDatePicker(
      context: context,
      initialDate: start
          ? _startDate
          : (_endDate ??
              _startDate),
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (start) {
        _startDate = picked;

        if (_endDate != null &&
            _endDate!.isBefore(
              picked,
            )) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickTime({
    required bool start,
  }) async {
    final picked =
        await showTimePicker(
      context: context,
      initialTime: start
          ? (_startTime ??
              const TimeOfDay(
                hour: 9,
                minute: 0,
              ))
          : (_endTime ??
              const TimeOfDay(
                hour: 10,
                minute: 0,
              )),
    );

    if (picked == null) return;

    setState(() {
      if (start) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save() async {
    final title =
        _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '할 일 이름을 입력해주세요.',
          ),
        ),
      );
      return;
    }

    final existing =
        widget.plan;

    final plan = Plan(
      id: existing?.id ??
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),

      title: title,

      category: _category,

      memo:
          _memoController.text.trim(),

      type: _type,

      projectId: _projectId,

      hasDate: _hasDate,

      startDate: _startDate,

      endDate:
          _hasDate ? _endDate : null,

      repeatEnabled:
          _type == 'repeat',

      repeatType:
          _type == 'repeat'
              ? _repeatType
              : 'none',

      repeatCount:
          _type == 'repeat'
              ? _repeatCount
              : 1,

      repeatDays:
          _type == 'repeat'
              ? _repeatDays
              : [],

      hasTime: _hasTime,

      startHour:
          _hasTime
              ? _startTime?.hour
              : null,

      startMinute:
          _hasTime
              ? _startTime?.minute
              : null,

      endHour:
          _hasTime
              ? _endTime?.hour
              : null,

      endMinute:
          _hasTime
              ? _endTime?.minute
              : null,

      notification:
          _notification,

      completedDates:
          existing?.completedDates ??
          [],

      createdAt:
          existing?.createdAt ??
          DateTime.now(),
    );

    final plans =
        await PlanStorage.load();

    final index =
        plans.indexWhere(
      (item) =>
          item.id == plan.id,
    );

    if (index == -1) {
      plans.add(plan);
    } else {
      plans[index] = plan;
    }

    await PlanStorage.save(plans);

    if (!mounted) return;

    Navigator.pop(
      context,
      true,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plan == null
              ? '계획 추가'
              : '계획 수정',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          children: [
            _buildTypeSelector(),

            const SizedBox(
              height: 24,
            ),

            TextField(
              controller:
                  _titleController,
              decoration:
                  const InputDecoration(
                labelText: '무엇을 할까요?',
                hintText:
                    '예: 운동하기',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            _buildCategory(),

            const SizedBox(
              height: 16,
            ),

            _buildProjectSelector(),

            const SizedBox(
              height: 16,
            ),

            _buildDateOption(),

            if (_hasDate) ...[
              const SizedBox(
                height: 8,
              ),
              _buildDateSection(),
            ],

            const SizedBox(
              height: 8,
            ),

            _buildTimeSection(),

            if (_type == 'repeat') ...[
              const SizedBox(
                height: 8,
              ),
              _buildRepeatSection(),
            ],

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  _memoController,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                labelText: '메모',
                hintText:
                    '필요한 내용을 적어주세요.',
                border:
                    OutlineInputBorder(),
              ),
            ),

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,
              title:
                  const Text('알림'),
              value:
                  _notification,
              onChanged: (value) {
                setState(() {
                  _notification =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            SizedBox(
              height: 52,
              child:
                  ElevatedButton(
                onPressed: _save,
                child: Text(
                  widget.plan == null
                      ? '추가하기'
                      : '저장하기',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _typeButton(
            type: 'todo',
            symbol: '○',
            title: '일반',
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: _typeButton(
            type: 'repeat',
            symbol: '↻',
            title: '반복',
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: _typeButton(
            type: 'someday',
            symbol: '□',
            title: '나중에',
          ),
        ),
      ],
    );
  }

  Widget _typeButton({
    required String type,
    required String symbol,
    required String title,
  }) {
    final selected =
        _type == type;

    return InkWell(
      borderRadius:
          BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _type = type;

          if (type == 'someday') {
            _hasDate = false;
          }

          if (type == 'repeat') {
            _hasDate = true;
          }
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(
                    alpha: 0.10,
                  )
              : Colors.grey.shade100,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context)
                    .colorScheme
                    .primary
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return DropdownButtonFormField<
        String>(
      value:
          _categories.any(
        (category) =>
            category.name ==
            _category,
      )
              ? _category
              : null,
      decoration:
          const InputDecoration(
        labelText: '카테고리',
        border:
            OutlineInputBorder(),
      ),
      items:
          _categories
              .map(
                (category) =>
                    DropdownMenuItem(
                  value:
                      category.name,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration:
                            BoxDecoration(
                          color: Color(
                            category
                                .colorValue,
                          ),
                          shape:
                              BoxShape.circle,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        category.name,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _category = value;
        });
      },
    );
  }

  Widget _buildProjectSelector() {
    return DropdownButtonFormField<
        String?>(
      value: _projectId,
      decoration:
          const InputDecoration(
        labelText: '프로젝트',
        border:
            OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<
            String?>(
          value: null,
          child:
              Text('프로젝트 없음'),
        ),
        ..._projects.map(
          (project) =>
              DropdownMenuItem<
                  String?>(
            value: project.id,
            child:
                Text(project.title),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _projectId = value;
        });
      },
    );
  }

  Widget _buildDateOption() {
    return SwitchListTile(
      contentPadding:
          EdgeInsets.zero,
      title:
          const Text('날짜 지정'),
      subtitle: Text(
        _hasDate
            ? '특정 날짜에 표시'
            : '날짜 없이 저장',
      ),
      value: _hasDate,
      onChanged:
          _type == 'someday'
              ? null
              : (value) {
                  setState(() {
                    _hasDate =
                        value;
                  });
                },
    );
  }

  Widget _buildDateSection() {
    return Column(
      children: [
        ListTile(
          contentPadding:
              EdgeInsets.zero,
          leading:
              const Icon(
            Icons.calendar_today_rounded,
          ),
          title:
              const Text('시작 날짜'),
          subtitle:
              Text(
            _formatDate(
              _startDate,
            ),
          ),
          onTap: () {
            _pickDate(
              start: true,
            );
          },
        ),
        ListTile(
          contentPadding:
              EdgeInsets.zero,
          leading:
              const Icon(
            Icons.event_rounded,
          ),
          title:
              const Text('종료 날짜'),
          subtitle:
              Text(
            _endDate == null
                ? '종료 날짜 없음'
                : _formatDate(
                    _endDate!,
                  ),
          ),
          trailing:
              _endDate == null
                  ? null
                  : IconButton(
                      icon:
                          const Icon(
                        Icons.close,
                      ),
                      onPressed: () {
                        setState(() {
                          _endDate =
                              null;
                        });
                      },
                    ),
          onTap: () {
            _pickDate(
              start: false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      children: [
        SwitchListTile(
          contentPadding:
              EdgeInsets.zero,
          title:
              const Text('시간 지정'),
          value:
              _hasTime,
          onChanged: (value) {
            setState(() {
              _hasTime = value;

              if (value &&
                  _startTime ==
                      null) {
                _startTime =
                    const TimeOfDay(
                  hour: 9,
                  minute: 0,
                );
              }
            });
          },
        ),
        if (_hasTime)
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  title:
                      const Text('시작'),
                  subtitle:
                      Text(
                    _startTime == null
                        ? '시간 선택'
                        : _formatTime(
                            _startTime!,
                          ),
                  ),
                  onTap: () {
                    _pickTime(
                      start: true,
                    );
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  title:
                      const Text('종료'),
                  subtitle:
                      Text(
                    _endTime == null
                        ? '시간 선택'
                        : _formatTime(
                            _endTime!,
                          ),
                  ),
                  onTap: () {
                    _pickTime(
                      start: false,
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRepeatSection() {
    return Column(
      children: [
        DropdownButtonFormField<
            String>(
          value: _repeatType,
          decoration:
              const InputDecoration(
            labelText: '반복 방식',
            border:
                OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'daily',
              child: Text('매일'),
            ),
            DropdownMenuItem(
              value: 'weekly',
              child: Text('매주'),
            ),
            DropdownMenuItem(
              value: 'specific',
              child: Text('특정 요일'),
            ),
            DropdownMenuItem(
              value: 'monthly',
              child: Text('매월'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _repeatType =
                  value;
            });
          },
        ),
        if (_repeatType == 'weekly' ||
            _repeatType == 'specific')
          _buildWeekdaySelector(),
        Row(
          children: [
            const Text('반복 횟수'),
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed:
                  _repeatCount > 1
                      ? () {
                          setState(() {
                            _repeatCount--;
                          });
                        }
                      : null,
              icon:
                  const Icon(
                Icons.remove,
              ),
            ),
            Text(
              '$_repeatCount',
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _repeatCount++;
                });
              },
              icon:
                  const Icon(
                Icons.add,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    const days = [
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
      '일',
    ];

    return Wrap(
      spacing: 8,
      children:
          List.generate(
        days.length,
        (index) {
          final selected =
              _repeatDays
                  .contains(index);

          return FilterChip(
            label:
                Text(days[index]),
            selected:
                selected,
            onSelected: (value) {
              setState(() {
                if (value) {
                  _repeatDays
                      .add(index);
                } else {
                  _repeatDays
                      .remove(index);
                }
              });
            },
          );
        },
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(
    TimeOfDay time,
  ) {
    final hour =
        time.hourOfPeriod == 0
            ? 12
            : time.hourOfPeriod;

    final minute =
        time.minute
            .toString()
            .padLeft(2, '0');

    final period =
        time.period ==
                DayPeriod.am
            ? '오전'
            : '오후';

    return '$period $hour:$minute';
  }
}