import '../core/constants/db_constants.dart';

class WalletModel {
  final int? id;
  final String name;
  final String number;
  final double balance;
  final int color;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    this.id,
    required this.name,
    required this.number,
    required this.balance,
    required this.color,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  WalletModel copyWith({
    int? id,
    String? name,
    String? number,
    double? balance,
    int? color,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.walletId: id,
      DbConstants.walletName: name,
      DbConstants.walletNumber: number,
      DbConstants.walletBalance: balance,
      DbConstants.walletColor: color,
      DbConstants.walletNotes: notes,
      DbConstants.walletCreatedAt: createdAt.toIso8601String(),
      DbConstants.walletUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map[DbConstants.walletId] as int?,
      name: map[DbConstants.walletName] as String,
      number: map[DbConstants.walletNumber] as String,
      balance: (map[DbConstants.walletBalance] as num).toDouble(),
      color: map[DbConstants.walletColor] as int,
      notes: map[DbConstants.walletNotes] as String?,
      createdAt: DateTime.parse(map[DbConstants.walletCreatedAt] as String),
      updatedAt: DateTime.parse(map[DbConstants.walletUpdatedAt] as String),
    );
  }

  factory WalletModel.empty() {
    final now = DateTime.now();
    return WalletModel(
      name: '',
      number: '',
      balance: 0.0,
      color: 0xFF6C63FF,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'WalletModel(id: $id, name: $name, number: $number, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
