class Plan {
  final String id;
  final String title;
  final String category;
  final String memo;

  // todo = 일반 할 일
  // repeat = 반복
  // someday = 나중에
  final String type;

  // 프로젝트에 연결된 경우 프로젝트 ID
  final String? projectId;

  // 날짜가 있는지 여부
  final bool hasDate;

  final DateTime startDate;
  final DateTime? endDate;

  final bool repeatEnabled;
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

  const Plan({
    required this.id,
    required this.title,
    required this.category,
    required this.memo,
    required this.type,
    this.projectId,
    required this.hasDate,
    required this.startDate,
    this.endDate,
    required this.repeatEnabled,
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

  /// 불렛저널 기호
  String get symbol {
    if (isCompletedToday) {
      return '✓';
    }

    switch (type) {
      case 'repeat':
        return '↻';
      case 'someday':
        return '□';
      default:
        return '○';
    }
  }

  /// 오늘 완료했는지
  bool get isCompletedToday {
    final now = DateTime.now();

    final key =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    return completedDates.contains(key);
  }

  Plan copyWith({
    String? id,
    String? title,
    String? category,
    String? memo,
    String? type,
    String? projectId,
    bool? hasDate,
    DateTime? startDate,
    DateTime? endDate,
    bool? repeatEnabled,
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
    return Plan(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      type: type ?? this.type,
      projectId: projectId ?? this.projectId,
      hasDate: hasDate ?? this.hasDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      repeatEnabled: repeatEnabled ?? this.repeatEnabled,
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
      'type': type,
      'projectId': projectId,
      'hasDate': hasDate,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'repeatEnabled': repeatEnabled,
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

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),

      title: map['title']?.toString() ?? '',

      category:
          map['category']?.toString() ?? '개인',

      memo:
          map['memo']?.toString() ?? '',

      // 기존 데이터는 일반 할 일로 처리
      type:
          map['type']?.toString() ?? 'todo',

      projectId:
          map['projectId']?.toString(),

      // 기존 데이터는 날짜가 있는 것으로 처리
      hasDate:
          map['hasDate'] != false,

      startDate:
          DateTime.tryParse(
                map['startDate']?.toString() ?? '',
              ) ??
              DateTime.now(),

      endDate:
          map['endDate'] == null
              ? null
              : DateTime.tryParse(
                  map['endDate'].toString(),
                ),

      repeatEnabled:
          map['repeatEnabled'] == true,

      repeatType:
          map['repeatType']?.toString() ?? 'none',

      repeatCount:
          _toInt(map['repeatCount'], 1),

      repeatDays:
          _toIntList(map['repeatDays']),

      hasTime:
          map['hasTime'] == true,

      startHour:
          _nullableInt(map['startHour']),

      startMinute:
          _nullableInt(map['startMinute']),

      endHour:
          _nullableInt(map['endHour']),

      endMinute:
          _nullableInt(map['endMinute']),

      notification:
          map['notification'] != false,

      completedDates:
          _toStringList(map['completedDates']),

      createdAt:
          DateTime.tryParse(
                map['createdAt']?.toString() ?? '',
              ) ??
              DateTime.now(),
    );
  }

  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(
      value.toString(),
    );
  }

  static List<int> _toIntList(dynamic value) {
    if (value is! List) return [];

    return value
        .map(
          (item) => int.tryParse(
            item.toString(),
          ),
        )
        .whereType<int>()
        .toList();
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return [];

    return value
        .map(
          (item) => item.toString(),
        )
        .toList();
  }
}