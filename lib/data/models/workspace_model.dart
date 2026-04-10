class WorkspaceModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkspaceModel({
    required this.id,
    required this.name,
    this.iconCodePoint = 0xf3e5, // CupertinoIcons.person
    this.color = 0xFFD4A574, // AppTheme.primaryAccent
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCodePoint': iconCodePoint,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCodePoint: (json['iconCodePoint'] as int?) ?? 0xf3e5,
      color: (json['color'] as int?) ?? 0xFFD4A574,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  WorkspaceModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
