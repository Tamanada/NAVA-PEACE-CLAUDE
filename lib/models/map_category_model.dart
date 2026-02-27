class MapCategoryModel {
  final String id;
  final String name;
  final String icon;
  final bool enabled;
  final DateTime createdAt;

  MapCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.enabled,
    required this.createdAt,
  });

  factory MapCategoryModel.fromJson(Map<String, dynamic> json) {
    return MapCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      enabled: json['enabled'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'enabled': enabled,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
