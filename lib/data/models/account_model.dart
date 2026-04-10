class AccountModel {
  final String id;
  final String workspaceId;
  final String name;
  final int type; // 0=cash, 1=bank, 2=mobile_wallet
  final double balance;
  final int sortOrder;
  final bool isArchived;

  AccountModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.sortOrder = 0,
    this.isArchived = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'type': type,
        'balance': balance,
        'sortOrder': sortOrder,
        'isArchived': isArchived,
      };

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      workspaceId: (json['workspaceId'] as String?) ?? 'default',
      name: json['name'] as String,
      type: json['type'] as int,
      balance: (json['balance'] as num).toDouble(),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isArchived: (json['isArchived'] as bool?) ?? false,
    );
  }

  AccountModel copyWith({
    String? id,
    String? workspaceId,
    String? name,
    int? type,
    double? balance,
    int? sortOrder,
    bool? isArchived,
  }) {
    return AccountModel(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Account(id: $id, name: $name, balance: $balance)';
}
