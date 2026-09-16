import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoAddScreen extends StatefulWidget {
  const TodoAddScreen({super.key});

  @override
  State<TodoAddScreen> createState() => _TodoAddScreenState();
}

class _TodoAddScreenState extends State<TodoAddScreen> {
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();

  String _category = '개인';

  DateTime _date = DateTime.now();

  bool _hasTime = false;
  bool _notification = true;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _date = picked;
    });
  }

  Future<void> _pickTime({
    required bool start,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
          content: Text('할 일 이름을 입력해주세요.'),
        ),
      );
      return;
    }

    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: _category,
      memo: _memoController.text.trim(),
      date: _date,
      hasTime: _hasTime,
      startHour: _startTime?.hour,
      startMinute: _startTime?.minute,
      endHour: _endTime?.hour,
      endMinute: _endTime?.minute,
      notification: _notification,
      completed: false,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, todo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 추가'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '할 일',
              hintText: '예: 교수님께 메일 보내기',
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
            title: const Text('날짜'),
            subtitle: Text(
              '${_date.year}.${_date.month}.${_date.day}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),

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
              child: Text('할 일 만들기'),
            ),
          ),
        ],
      ),
    );
  }
}