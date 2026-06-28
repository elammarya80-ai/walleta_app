import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  String? _filterType;
  String? _filterStatus;
  DateTime? _filterFrom;
  DateTime? _filterTo;
  String _searchQuery = '';
  String _orderBy = '${DbConstantsRef.txCreatedAt} DESC';

  int _currentPage = 0;
  bool _hasMore = true;
  static const int _pageSize = AppConstants.pageSize;

  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String? get filterType => _filterType;
  String? get filterStatus => _filterStatus;
  DateTime? get filterFrom => _filterFrom;
  DateTime? get filterTo => _filterTo;
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;
  bool get hasActiveFilters =>
      _filterType != null ||
      _filterStatus != null ||
      _filterFrom != null ||
      _filterTo != null ||
      _searchQuery.isNotEmpty;

  Future<void> loadTransactions({bool reset = true}) async {
    if (reset) {
      _currentPage = 0;
      _hasMore = true;
      _transactions = [];
    }
    if (!_hasMore) return;

    if (_currentPage == 0) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getAllTransactions(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        type: _filterType,
        status: _filterStatus,
        from: _filterFrom,
        to: _filterTo,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        orderBy: _orderBy,
      );

      if (reset) {
        _transactions = result;
      } else {
        _transactions.addAll(result);
      }

      _hasMore = result.length == _pageSize;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    await loadTransactions(reset: false);
  }

  Future<void> loadRecentTransactions() async {
    try {
      _recentTransactions = await _service.getRecentTransactions(limit: 10);
      notifyListeners();
    } catch (_) {}
  }

  void setFilter({
    String? type,
    String? status,
    DateTime? from,
    DateTime? to,
    String? search,
    String? orderBy,
  }) {
    _filterType = type;
    _filterStatus = status;
    _filterFrom = from;
    _filterTo = to;
    if (search != null) _searchQuery = search;
    if (orderBy != null) _orderBy = orderBy;
    loadTransactions();
  }

  void clearFilters() {
    _filterType = null;
    _filterStatus = null;
    _filterFrom = null;
    _filterTo = null;
    _searchQuery = '';
    _orderBy = '${DbConstantsRef.txCreatedAt} DESC';
    loadTransactions();
  }

  void search(String query) {
    _searchQuery = query;
    loadTransactions();
  }

  Future<bool> addTransaction(TransactionModel tx) async {
    try {
      await _service.createTransaction(tx);
      await loadTransactions();
      await loadRecentTransactions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(
    TransactionModel oldTx,
    TransactionModel newTx,
  ) async {
    try {
      await _service.updateTransaction(oldTx, newTx);
      await loadTransactions();
      await loadRecentTransactions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(TransactionModel tx) async {
    try {
      await _service.deleteTransaction(tx);
      _transactions.removeWhere((t) => t.id == tx.id);
      _recentTransactions.removeWhere((t) => t.id == tx.id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Reference class to avoid circular import
class DbConstantsRef {
  static const String txCreatedAt = 'created_at';
}
