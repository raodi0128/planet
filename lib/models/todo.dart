class Todo {
  final String id;
  final String title;
  final String category;
  final String memo;

  final DateTime date;

  final bool hasTime;
  final int? startHour;
  final int? startMinute;
  final int? endHour;
  final int? endMinute;

  final bool notification;
  final bool completed;

  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    required this.category,
    required this.memo,
    required this.date,
    required this.hasTime,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
    required this.notification,
    required this.completed,
    required this.createdAt,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? category,
    String? memo,
    DateTime? date,
    bool? hasTime,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    bool? notification,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      date: date ?? this.date,
      hasTime: hasTime ?? this.hasTime,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      notification: notification ?? this.notification,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'memo': memo,
      'date': date.toIso8601String(),
      'hasTime': hasTime,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'notification': notification,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? '개인',
      memo: map['memo']?.toString() ?? '',
      date:
          DateTime.tryParse(map['date']?.toString() ?? '') ??
              DateTime.now(),
      hasTime: map['hasTime'] == true,
      startHour: _nullableInt(map['startHour']),
      startMinute: _nullableInt(map['startMinute']),
      endHour: _nullableInt(map['endHour']),
      endMinute: _nullableInt(map['endMinute']),
      notification: map['notification'] != false,
      completed: map['completed'] == true,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}