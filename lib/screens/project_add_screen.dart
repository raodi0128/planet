import 'package:flutter/material.dart';

import '../models/project.dart';

class ProjectAddScreen extends StatefulWidget {
  const ProjectAddScreen({super.key});

  @override
  State<ProjectAddScreen> createState() => _ProjectAddScreenState();
}

class _ProjectAddScreenState extends State<ProjectAddScreen> {
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();
  final _taskController = TextEditingController();

  String _category = '개인';

  DateTime _startDate = DateTime.now();
  DateTime _endDate =
      DateTime.now().add(const Duration(days: 7));

  final List<String> _tasks = [];

  final categories = [
    '학교',
    '업무',
    '운동',
    '취미',
    '생활',
    '개인',
    '기타',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required bool start,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (start) {
        _startDate = picked;

        if (_endDate.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;

        if (_startDate.isAfter(picked)) {
          _startDate = picked;
        }
      }
    });
  }

  void _addTask() {
    final text = _taskController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _tasks.add(text);
      _taskController.clear();
    });
  }

  void _save() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로젝트 이름을 입력해주세요.'),
        ),
      );
      return;
    }

    final project = Project(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: _category,
      memo: _memoController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      tasks: _tasks
          .map(
            (title) => ProjectTask(
              id: DateTime.now()
                  .microsecondsSinceEpoch
                  .toString(),
              title: title,
              completed: false,
              createdAt: DateTime.now(),
            ),
          )
          .toList(),
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, project);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트 추가'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '프로젝트 이름',
              hintText: '예: PLANET 앱 만들기',
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
            title: const Text('마감일'),
            subtitle: Text(
              '${_endDate.year}.${_endDate.month}.${_endDate.day}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(start: false),
          ),

          const SizedBox(height: 20),

          const Text(
            '세부 할 일',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  onSubmitted: (_) => _addTask(),
                  decoration: const InputDecoration(
                    hintText: '예: 하단 메뉴 만들기',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addTask,
                icon: const Icon(Icons.add_circle),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  '세부 할 일을 추가해주세요.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

          ..._tasks.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final task = entry.value;

              return Card(
                child: ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(task),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _tasks.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _memoController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '메모',
              hintText: '프로젝트에 대한 설명',
            ),
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: _save,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('프로젝트 만들기'),
            ),
          ),
        ],
      ),
    );
  }
}