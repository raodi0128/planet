class ProjectTask {
  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;

  const ProjectTask({
    required this.id,
    required this.title,
    required this.completed,
    required this.createdAt,
  });

  ProjectTask copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProjectTask.fromMap(Map<String, dynamic> map) {
    return ProjectTask(
      id: map['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      completed: map['completed'] == true,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}

class Project {
  final String id;
  final String title;
  final String category;
  final String memo;

  final DateTime startDate;
  final DateTime endDate;

  final List<ProjectTask> tasks;

  final DateTime createdAt;

  const Project({
    required this.id,
    required this.title,
    required this.category,
    required this.memo,
    required this.startDate,
    required this.endDate,
    required this.tasks,
    required this.createdAt,
  });

  double get progress {
    if (tasks.isEmpty) return 0;

    final completed =
        tasks.where((task) => task.completed).length;

    return completed / tasks.length;
  }

  int get completedTaskCount {
    return tasks.where((task) => task.completed).length;
  }

  Project copyWith({
    String? id,
    String? title,
    String? category,
    String? memo,
    DateTime? startDate,
    DateTime? endDate,
    List<ProjectTask>? tasks,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tasks: tasks ?? List<ProjectTask>.from(this.tasks),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'memo': memo,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'tasks': tasks.map((task) => task.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    final rawTasks = map['tasks'];

    final tasks = rawTasks is List
        ? rawTasks
            .map(
              (task) => ProjectTask.fromMap(
                Map<String, dynamic>.from(task as Map),
              ),
            )
            .toList()
        : <ProjectTask>[];

    return Project(
      id: map['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? '개인',
      memo: map['memo']?.toString() ?? '',
      startDate:
          DateTime.tryParse(map['startDate']?.toString() ?? '') ??
              DateTime.now(),
      endDate:
          DateTime.tryParse(map['endDate']?.toString() ?? '') ??
              DateTime.now(),
      tasks: tasks,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}