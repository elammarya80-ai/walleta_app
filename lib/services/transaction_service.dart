import '../core/constants/app_constants.dart';
import '../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import 'wallet_service.dart';
import 'instapay_service.dart';
import 'package:sqflite/sqflite.dart';

class TransactionService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final WalletService _walletService = WalletService();
  final InstapayService _instapayService = InstapayService();

  Future<int> createTransaction(TransactionModel tx) async {
    final now = DateTime.now();
    final model = tx.copyWith(createdAt: now, updatedAt: now);

    return await _db.transaction((txn) async {
      final id = await txn.insert(
        DbConstants.tableTransactions,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (model.status == AppConstants.statusCompleted) {
        await _applyBalanceChanges(txn, model);
      }

      return id;
    });
  }

  Future<void> _applyBalanceChanges(
    Transaction txn,
    TransactionModel model,
  ) async {
    final now = DateTime.now().toIso8601String();

    Future<void> adjustWallet(int id, double delta) async {
      await txn.rawUpdate(
        '''UPDATE ${DbConstants.tableWallets}
           SET ${DbConstants.walletBalance} = ${DbConstants.walletBalance} + ?,
               ${DbConstants.walletUpdatedAt} = ?
           WHERE ${DbConstants.walletId} = ?''',
        [delta, now, id],
      );
    }

    Future<void> adjustInstapay(int id, double delta) async {
      await txn.rawUpdate(
        '''UPDATE ${DbConstants.tableInstapay}
           SET ${DbConstants.instapayBalance} = ${DbConstants.instapayBalance} + ?,
               ${DbConstants.instapayUpdatedAt} = ?
           WHERE ${DbConstants.instapayId} = ?''',
        [delta, now, id],
      );
    }

    switch (model.type) {
      case AppConstants.txDeposit:
        // Money comes IN to source account
        if (model.sourceType == AppConstants.sourceWallet && model.sourceId != null) {
          await adjustWallet(model.sourceId!, model.amount);
        } else if (model.sourceType == AppConstants.sourceInstapay && model.sourceId != null) {
          await adjustInstapay(model.sourceId!, model.amount);
        }
        break;

      case AppConstants.txWithdraw:
        // Money goes OUT from source account
        if (model.sourceType == AppConstants.sourceWallet && model.sourceId != null) {
          await adjustWallet(model.sourceId!, -model.amount);
        } else if (model.sourceType == AppConstants.sourceInstapay && model.sourceId != null) {
          await adjustInstapay(model.sourceId!, -model.amount);
        }
        break;

      case AppConstants.txTransfer:
        // Money goes OUT from source, IN to destination
        if (model.sourceType == AppConstants.sourceWallet && model.sourceId != null) {
          await adjustWallet(model.sourceId!, -model.amount);
        } else if (model.sourceType == AppConstants.sourceInstapay && model.sourceId != null) {
          await adjustInstapay(model.sourceId!, -model.amount);
        }
        if (model.destType == AppConstants.sourceWallet && model.destId != null) {
          await adjustWallet(model.destId!, model.amount);
        } else if (model.destType == AppConstants.sourceInstapay && model.destId != null) {
          await adjustInstapay(model.destId!, model.amount);
        }
        break;
    }
  }

  Future<void> _reverseBalanceChanges(TransactionModel model) async {
    // Reverse the original transaction
    final reversed = model.copyWith(
      type: _reverseType(model.type),
    );
    await _db.transaction((txn) async {
      await _applyBalanceChanges(txn, reversed);
    });
  }

  String _reverseType(String type) {
    switch (type) {
      case AppConstants.txDeposit:
        return AppConstants.txWithdraw;
      case AppConstants.txWithdraw:
        return AppConstants.txDeposit;
      case AppConstants.txTransfer:
        // For transfer reversal we swap source/dest in the model
        return AppConstants.txTransfer;
      default:
        return type;
    }
  }

  Future<List<TransactionModel>> getAllTransactions({
    int? limit,
    int? offset,
    String? type,
    String? status,
    DateTime? from,
    DateTime? to,
    String? searchQuery,
    String orderBy = 'created_at DESC',
  }) async {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (type != null) {
      conditions.add('${DbConstants.txType} = ?');
      args.add(type);
    }
    if (status != null) {
      conditions.add('${DbConstants.txStatus} = ?');
      args.add(status);
    }
    if (from != null) {
      conditions.add('${DbConstants.txCreatedAt} >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('${DbConstants.txCreatedAt} <= ?');
      args.add(to.toIso8601String());
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      conditions.add(
        '(${DbConstants.txClientName} LIKE ? OR ${DbConstants.txClientNumber} LIKE ? OR ${DbConstants.txNotes} LIKE ?)',
      );
      args.addAll(['%$searchQuery%', '%$searchQuery%', '%$searchQuery%']);
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final maps = await _db.query(
      DbConstants.tableTransactions,
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final maps = await _db.query(
      DbConstants.tableTransactions,
      where: '${DbConstants.txId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    return await getAllTransactions(
      limit: limit,
      orderBy: '${DbConstants.txCreatedAt} DESC',
    );
  }

  Future<List<TransactionModel>> getTransactionsBySourceId(
    int sourceId,
    String sourceType,
  ) async {
    final maps = await _db.query(
      DbConstants.tableTransactions,
      where:
          '(${DbConstants.txSourceId} = ? AND ${DbConstants.txSourceType} = ?) OR (${DbConstants.txDestId} = ? AND ${DbConstants.txDestType} = ?)',
      whereArgs: [sourceId, sourceType, sourceId, sourceType],
      orderBy: '${DbConstants.txCreatedAt} DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<int> updateTransaction(
    TransactionModel oldTx,
    TransactionModel newTx,
  ) async {
    return await _db.transaction((txn) async {
      // Reverse old balance changes if completed
      if (oldTx.status == AppConstants.statusCompleted) {
        await _reverseOldTx(txn, oldTx);
      }

      final updated = newTx.copyWith(updatedAt: DateTime.now());
      final result = await txn.update(
        DbConstants.tableTransactions,
        updated.toMap(),
        where: '${DbConstants.txId} = ?',
        whereArgs: [oldTx.id],
      );

      // Apply new balance changes if completed
      if (newTx.status == AppConstants.statusCompleted) {
        await _applyBalanceChanges(txn, updated);
      }

      return result;
    });
  }

  Future<void> _reverseOldTx(Transaction txn, TransactionModel model) async {
    final now = DateTime.now().toIso8601String();

    Future<void> adjustWallet(int id, double delta) => txn.rawUpdate(
          '''UPDATE ${DbConstants.tableWallets}
             SET ${DbConstants.walletBalance} = ${DbConstants.walletBalance} + ?,
                 ${DbConstants.walletUpdatedAt} = ?
             WHERE ${DbConstants.walletId} = ?''',
          [delta, now, id],
        );

    Future<void> adjustInstapay(int id, double delta) => txn.rawUpdate(
          '''UPDATE ${DbConstants.tableInstapay}
             SET ${DbConstants.instapayBalance} = ${DbConstants.instapayBalance} + ?,
                 ${DbConstants.instapayUpdatedAt} = ?
             WHERE ${DbConstants.instapayId} = ?''',
          [delta, now, id],
        );

    switch (model.type) {
      case AppConstants.txDeposit:
        if (model.sourceType == AppConstants.sourceWallet && model.sourceId != null) {
          await adjustWallet(model.sourceId!, -model.amount);
        } else if (model.sourceType == AppConstants.sourceInstapay && model.sourceId != null) {
          await adjustInstapay(model.sourceId!, -model.amount);
        }
        break;
      case AppConstants.txWithdraw:
        if (model.sourceType == AppConstants.sourceWallet && model.sourceId != null) {
          await adjustWallet(model.sourceId!, model.amount);
        } else if (model.sourceType == AppConstants.sourceInstapay && model.sourceId != null) {
          await adjustInstapay(model.sourceId!, model.amount);
        }
        break;
      case AppConstants.txTransfer:
        if (model.sourceType == AppConstants.sourceWallet && model.sourceId != null) {
          await adjustWallet(model.sourceId!, model.amount);
        } else if (model.sourceType == AppConstants.sourceInstapay && model.sourceId != null) {
          await adjustInstapay(model.sourceId!, model.amount);
        }
        if (model.destType == AppConstants.sourceWallet && model.destId != null) {
          await adjustWallet(model.destId!, -model.amount);
        } else if (model.destType == AppConstants.sourceInstapay && model.destId != null) {
          await adjustInstapay(model.destId!, -model.amount);
        }
        break;
    }
  }

  Future<int> deleteTransaction(TransactionModel tx) async {
    return await _db.transaction((txn) async {
      if (tx.status == AppConstants.statusCompleted) {
        await _reverseOldTx(txn, tx);
      }
      return await txn.delete(
        DbConstants.tableTransactions,
        where: '${DbConstants.txId} = ?',
        whereArgs: [tx.id],
      );
    });
  }

  Future<int> getTransactionsCount({String? type, DateTime? from, DateTime? to}) async {
    final conditions = <String>[];
    final args = <dynamic>[];
    if (type != null) {
      conditions.add('${DbConstants.txType} = ?');
      args.add(type);
    }
    if (from != null) {
      conditions.add('${DbConstants.txCreatedAt} >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('${DbConstants.txCreatedAt} <= ?');
      args.add(to.toIso8601String());
    }
    return await _db.count(
      DbConstants.tableTransactions,
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
    );
  }

  Future<double> getTotalAmount({String? type, DateTime? from, DateTime? to}) async {
    final conditions = <String>[];
    final args = <dynamic>[];
    if (type != null) {
      conditions.add('${DbConstants.txType} = ?');
      args.add(type);
    }
    if (from != null) {
      conditions.add('${DbConstants.txCreatedAt} >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('${DbConstants.txCreatedAt} <= ?');
      args.add(to.toIso8601String());
    }
    return await _db.sum(
      DbConstants.tableTransactions,
      DbConstants.txAmount,
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
    );
  }

  Future<double> getTotalProfit({DateTime? from, DateTime? to}) async {
    final conditions = <String>[];
    final args = <dynamic>[];
    if (from != null) {
      conditions.add('${DbConstants.txCreatedAt} >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('${DbConstants.txCreatedAt} <= ?');
      args.add(to.toIso8601String());
    }
    return await _db.sum(
      DbConstants.tableTransactions,
      DbConstants.txProfit,
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
    );
  }
}
