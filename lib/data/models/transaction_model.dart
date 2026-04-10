class TransactionModel {
  final String id;
  final String workspaceId;
  final int type; // 0=income, 1=expense, 2=transfer
  final double amount;
  final String accountId;
  final String? toAccountId; // Only for transfers
  final String? categoryId; // Not required for transfers
  final DateTime date;
  final String note;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.workspaceId,
    required this.type,
    required this.amount,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    required this.date,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'type': type,
        'amount': amount,
        'accountId': accountId,
        'toAccountId': toAccountId,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      workspaceId: (json['workspaceId'] as String?) ?? 'default',
      type: json['type'] as int,
      amount: (json['amount'] as num).toDouble(),
      accountId: json['accountId'] as String,
      toAccountId: json['toAccountId'] as String?,
      categoryId: json['categoryId'] as String?,
      date: DateTime.parse(json['date'] as String),
      note: (json['note'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  TransactionModel copyWith({
    String? id,
    String? workspaceId,
    int? type,
    double? amount,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Transaction(id: $id, type: $type, amount: $amount)';
}
