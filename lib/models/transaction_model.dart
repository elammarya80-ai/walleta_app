import '../core/constants/app_constants.dart';
import '../core/constants/db_constants.dart';

class TransactionModel {
  final int? id;
  final String type;
  final String sourceType;
  final int? sourceId;
  final String? destType;
  final int? destId;
  final double amount;
  final double commission;
  final double profit;
  final String? clientName;
  final String? clientNumber;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Non-persisted display fields
  final String? sourceName;
  final String? destName;

  TransactionModel({
    this.id,
    required this.type,
    required this.sourceType,
    this.sourceId,
    this.destType,
    this.destId,
    required this.amount,
    required this.commission,
    required this.profit,
    this.clientName,
    this.clientNumber,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.sourceName,
    this.destName,
  });

  TransactionModel copyWith({
    int? id,
    String? type,
    String? sourceType,
    int? sourceId,
    String? destType,
    int? destId,
    double? amount,
    double? commission,
    double? profit,
    String? clientName,
    String? clientNumber,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceName,
    String? destName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      destType: destType ?? this.destType,
      destId: destId ?? this.destId,
      amount: amount ?? this.amount,
      commission: commission ?? this.commission,
      profit: profit ?? this.profit,
      clientName: clientName ?? this.clientName,
      clientNumber: clientNumber ?? this.clientNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceName: sourceName ?? this.sourceName,
      destName: destName ?? this.destName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.txId: id,
      DbConstants.txType: type,
      DbConstants.txSourceType: sourceType,
      DbConstants.txSourceId: sourceId,
      DbConstants.txDestType: destType,
      DbConstants.txDestId: destId,
      DbConstants.txAmount: amount,
      DbConstants.txCommission: commission,
      DbConstants.txProfit: profit,
      DbConstants.txClientName: clientName,
      DbConstants.txClientNumber: clientNumber,
      DbConstants.txNotes: notes,
      DbConstants.txStatus: status,
      DbConstants.txCreatedAt: createdAt.toIso8601String(),
      DbConstants.txUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[DbConstants.txId] as int?,
      type: map[DbConstants.txType] as String,
      sourceType: map[DbConstants.txSourceType] as String,
      sourceId: map[DbConstants.txSourceId] as int?,
      destType: map[DbConstants.txDestType] as String?,
      destId: map[DbConstants.txDestId] as int?,
      amount: (map[DbConstants.txAmount] as num).toDouble(),
      commission: (map[DbConstants.txCommission] as num).toDouble(),
      profit: (map[DbConstants.txProfit] as num).toDouble(),
      clientName: map[DbConstants.txClientName] as String?,
      clientNumber: map[DbConstants.txClientNumber] as String?,
      notes: map[DbConstants.txNotes] as String?,
      status: map[DbConstants.txStatus] as String,
      createdAt: DateTime.parse(map[DbConstants.txCreatedAt] as String),
      updatedAt: DateTime.parse(map[DbConstants.txUpdatedAt] as String),
    );
  }

  factory TransactionModel.empty() {
    final now = DateTime.now();
    return TransactionModel(
      type: AppConstants.txTransfer,
      sourceType: AppConstants.sourceWallet,
      amount: 0.0,
      commission: 0.0,
      profit: 0.0,
      status: AppConstants.statusCompleted,
      createdAt: now,
      updatedAt: now,
    );
  }

  String get typeAr => AppConstants.getTransactionTypeAr(type);
  String get statusAr => AppConstants.getStatusAr(status);
  String get sourceTypeAr => AppConstants.getSourceAr(sourceType);
  String get destTypeAr => destType != null ? AppConstants.getSourceAr(destType!) : '';

  bool get isTransfer => type == AppConstants.txTransfer;
  bool get isWithdraw => type == AppConstants.txWithdraw;
  bool get isDeposit => type == AppConstants.txDeposit;
  bool get isCompleted => status == AppConstants.statusCompleted;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
