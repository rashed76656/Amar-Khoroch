class BudgetModel {
  final String id;
  final String workspaceId;
  final String categoryId;
  final int month; // 1-12
  final int year;
  final double amount;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.workspaceId,
    required this.categoryId,
    required this.month,
    required this.year,
    required this.amount,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'categoryId': categoryId,
        'month': month,
        'year': year,
        'amount': amount,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      workspaceId: (json['workspaceId'] as String?) ?? 'default',
      categoryId: json['categoryId'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      amount: (json['amount'] as num).toDouble(),
      note: (json['note'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  BudgetModel copyWith({
    String? id,
    String? workspaceId,
    String? categoryId,
    int? month,
    int? year,
    double? amount,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Budget(id: $id, categoryId: $categoryId, month: $month/$year, amount: $amount)';
}
