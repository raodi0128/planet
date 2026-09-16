class Routine {
  final String id;
  final String title;
  final String category;
  final String memo;

  final DateTime startDate;
  final DateTime? endDate;

  final String repeatType;
  final int repeatCount;
  final List<int> repeatDays;

  final bool hasTime;
  final int? startHour;
  final int? startMinute;
  final int? endHour;
  final int? endMinute;

  final bool notification;

  final List<String> completedDates;

  final DateTime createdAt;

  const Routine({
    required this.id,
    required this.title,
    required this.category,
    required this.memo,
    required this.startDate,
    this.endDate,
    required this.repeatType,
    required this.repeatCount,
    required this.repeatDays,
    required this.hasTime,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
    required this.notification,
    required this.completedDates,
    required this.createdAt,
  });

  Routine copyWith({
    String? id,
    String? title,
    String? category,
    String? memo,
    DateTime? startDate,
    DateTime? endDate,
    String? repeatType,
    int? repeatCount,
    List<int>? repeatDays,
    bool? hasTime,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    bool? notification,
    List<String>? completedDates,
    DateTime? createdAt,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      repeatType: repeatType ?? this.repeatType,
      repeatCount: repeatCount ?? this.repeatCount,
      repeatDays: repeatDays ?? List<int>.from(this.repeatDays),
      hasTime: hasTime ?? this.hasTime,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      notification: notification ?? this.notification,
      completedDates:
          completedDates ?? List<String>.from(this.completedDates),
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
      'endDate': endDate?.toIso8601String(),
      'repeatType': repeatType,
      'repeatCount': repeatCount,
      'repeatDays': repeatDays,
      'hasTime': hasTime,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'notification': notification,
      'completedDates': completedDates,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? '개인',
      memo: map['memo']?.toString() ?? '',
      startDate:
          DateTime.tryParse(map['startDate']?.toString() ?? '') ??
              DateTime.now(),
      endDate: map['endDate'] == null
          ? null
          : DateTime.tryParse(map['endDate'].toString()),
      repeatType: map['repeatType']?.toString() ?? 'daily',
      repeatCount: _toInt(map['repeatCount'], 1),
      repeatDays: _toIntList(map['repeatDays']),
      hasTime: map['hasTime'] == true,
      startHour: _nullableInt(map['startHour']),
      startMinute: _nullableInt(map['startMinute']),
      endHour: _nullableInt(map['endHour']),
      endMinute: _nullableInt(map['endMinute']),
      notification: map['notification'] != false,
      completedDates: _toStringList(map['completedDates']),
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static List<int> _toIntList(dynamic value) {
    if (value is! List) return [];

    return value
        .map((item) => int.tryParse(item.toString()))
        .whereType<int>()
        .toList();
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return [];

    return value.map((item) => item.toString()).toList();
  }
}