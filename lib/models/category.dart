class PlanCategory {
  final String id;
  final String name;
  final int colorValue;

  const PlanCategory({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  PlanCategory copyWith({
    String? id,
    String? name,
    int? colorValue,
  }) {
    return PlanCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory PlanCategory.fromMap(
    Map<String, dynamic> map,
  ) {
    return PlanCategory(
      id: map['id']?.toString() ??
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      name: map['name']?.toString() ?? '개인',
      colorValue:
          map['colorValue'] is int
              ? map['colorValue'] as int
              : int.tryParse(
                    map['colorValue']?.toString() ?? '',
                  ) ??
                  0xFF9E9E9E,
    );
  }
}