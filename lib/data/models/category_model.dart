class CategoryModel {
  final String id;
  final String workspaceId;
  final String name;
  final int type; // 0=income, 1=expense
  final int iconCodePoint;
  final int color;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.color,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'type': type,
        'iconCodePoint': iconCodePoint,
        'color': color,
        'sortOrder': sortOrder,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      workspaceId: (json['workspaceId'] as String?) ?? 'default',
      name: json['name'] as String,
      type: json['type'] as int,
      iconCodePoint: json['iconCodePoint'] as int,
      color: json['color'] as int,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? workspaceId,
    String? name,
    int? type,
    int? iconCodePoint,
    int? color,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name, type: $type)';
}
