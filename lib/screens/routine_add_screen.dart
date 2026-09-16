import 'package:flutter/material.dart';

import '../models/routine.dart';

class RoutineAddScreen extends StatefulWidget {
  const RoutineAddScreen({super.key});

  @override
  State<RoutineAddScreen> createState() => _RoutineAddScreenState();
}

class _RoutineAddScreenState extends State<RoutineAddScreen> {
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();

  String _category = '개인';
  String _repeatType = 'daily';
  int _repeatCount = 3;

  final Set<int> _repeatDays = {};

  bool _hasTime = false;
  bool _notification = true;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final categories = [
    '학교',
    '업무',
    '운동',
    '취미',
    '생활',
    '약속',
    '개인',
    '기타',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required bool start,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start
          ? _startDate
          : (_endDate ?? _startDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (start) {
        _startDate = picked;

        if (_endDate != null &&
            _endDate!.isBefore(picked)) {
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
    final picked = await showTimePicker(
      context: context,
      initialTime: start
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
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

  void _save() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('루틴 이름을 입력해주세요.'),
        ),
      );
      return;
    }

    if (_repeatType == 'specific' &&
        _repeatDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('반복할 요일을 선택해주세요.'),
        ),
      );
      return;
    }

    final routine = Routine(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: _category,
      memo: _memoController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      repeatType: _repeatType,
      repeatCount: _repeatCount,
      repeatDays: _repeatDays.toList()..sort(),
      hasTime: _hasTime,
      startHour: _startTime?.hour,
      startMinute: _startTime?.minute,
      endHour: _endTime?.hour,
      endMinute: _endTime?.minute,
      notification: _notification,
      completedDates: [],
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, routine);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('루틴 추가'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '루틴 이름',
              hintText: '예: 운동하기',
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            '카테고리',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: _category == category,
                onSelected: (_) {
                  setState(() {
                    _category = category;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('시작일'),
            subtitle: Text(
              '${_startDate.year}.${_startDate.month}.${_startDate.day}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(start: true),
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('종료일'),
            subtitle: Text(
              _endDate == null
                  ? '종료일 없음'
                  : '${_endDate!.year}.${_endDate!.month}.${_endDate!.day}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(start: false),
          ),

          const SizedBox(height: 12),

          const Text(
            '반복',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            children: [
              _repeatChip('매일', 'daily'),
              _repeatChip('주 N회', 'weekly'),
              _repeatChip('특정 요일', 'specific'),
              _repeatChip('매월', 'monthly'),
            ],
          ),

          if (_repeatType == 'weekly') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('주'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _repeatCount,
                  items: List.generate(
                    7,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}회'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _repeatCount = value;
                    });
                  },
                ),
              ],
            ),
          ],

          if (_repeatType == 'specific') ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final day = index + 1;
                final labels = [
                  '월',
                  '화',
                  '수',
                  '목',
                  '금',
                  '토',
                  '일',
                ];

                return FilterChip(
                  label: Text(labels[index]),
                  selected: _repeatDays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _repeatDays.add(day);
                      } else {
                        _repeatDays.remove(day);
                      }
                    });
                  },
                );
              }),
            ),
          ],

          const SizedBox(height: 24),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('시간 설정'),
            value: _hasTime,
            onChanged: (value) {
              setState(() {
                _hasTime = value;
              });
            },
          ),

          if (_hasTime) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('시작 시간'),
              trailing: Text(
                _startTime == null
                    ? '선택'
                    : _startTime!.format(context),
              ),
              onTap: () => _pickTime(start: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('종료 시간'),
              trailing: Text(
                _endTime == null
                    ? '선택'
                    : _endTime!.format(context),
              ),
              onTap: () => _pickTime(start: false),
            ),
          ],

          TextField(
            controller: _memoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '메모',
              hintText: '메모를 입력하세요.',
            ),
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('알림'),
            value: _notification,
            onChanged: (value) {
              setState(() {
                _notification = value;
              });
            },
          ),

          const SizedBox(height: 20),

          FilledButton(
            onPressed: _save,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('루틴 만들기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _repeatChip(String text, String value) {
    return ChoiceChip(
      label: Text(text),
      selected: _repeatType == value,
      onSelected: (_) {
        setState(() {
          _repeatType = value;
        });
      },
    );
  }
}