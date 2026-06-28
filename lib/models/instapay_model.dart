import '../core/constants/db_constants.dart';

class InstapayModel {
  final int? id;
  final String name;
  final String accountNumber;
  final double balance;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InstapayModel({
    this.id,
    required this.name,
    required this.accountNumber,
    required this.balance,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  InstapayModel copyWith({
    int? id,
    String? name,
    String? accountNumber,
    double? balance,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InstapayModel(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.instapayId: id,
      DbConstants.instapayName: name,
      DbConstants.instapayAccountNumber: accountNumber,
      DbConstants.instapayBalance: balance,
      DbConstants.instapayNotes: notes,
      DbConstants.instapayCreatedAt: createdAt.toIso8601String(),
      DbConstants.instapayUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory InstapayModel.fromMap(Map<String, dynamic> map) {
    return InstapayModel(
      id: map[DbConstants.instapayId] as int?,
      name: map[DbConstants.instapayName] as String,
      accountNumber: map[DbConstants.instapayAccountNumber] as String,
      balance: (map[DbConstants.instapayBalance] as num).toDouble(),
      notes: map[DbConstants.instapayNotes] as String?,
      createdAt: DateTime.parse(map[DbConstants.instapayCreatedAt] as String),
      updatedAt: DateTime.parse(map[DbConstants.instapayUpdatedAt] as String),
    );
  }

  factory InstapayModel.empty() {
    final now = DateTime.now();
    return InstapayModel(
      name: '',
      accountNumber: '',
      balance: 0.0,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstapayModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
