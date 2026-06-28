import 'package:flutter/material.dart';
import '../models/instapay_model.dart';
import '../services/instapay_service.dart';

class InstapayProvider extends ChangeNotifier {
  final InstapayService _service = InstapayService();

  List<InstapayModel> _accounts = [];
  List<InstapayModel> _filteredAccounts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  double _totalBalance = 0.0;

  List<InstapayModel> get accounts => _filteredAccounts;
  List<InstapayModel> get allAccounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalBalance => _totalBalance;
  int get count => _accounts.length;

  Future<void> loadAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _accounts = await _service.getAllAccounts();
      _totalBalance = _accounts.fold(0, (s, a) => s + a.balance);
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredAccounts = List.from(_accounts);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredAccounts = _accounts.where((a) {
        return a.name.toLowerCase().contains(q) ||
            a.accountNumber.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<bool> addAccount(InstapayModel account) async {
    try {
      final id = await _service.createAccount(account);
      final newAccount = account.copyWith(id: id);
      _accounts.insert(0, newAccount);
      _totalBalance += newAccount.balance;
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAccount(InstapayModel account) async {
    try {
      await _service.updateAccount(account);
      final idx = _accounts.indexWhere((a) => a.id == account.id);
      if (idx != -1) {
        final old = _accounts[idx];
        _totalBalance = _totalBalance - old.balance + account.balance;
        _accounts[idx] = account;
        _applyFilter();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(int id) async {
    try {
      await _service.deleteAccount(id);
      final account = _accounts.firstWhere((a) => a.id == id);
      _totalBalance -= account.balance;
      _accounts.removeWhere((a) => a.id == id);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  InstapayModel? getAccountById(int id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> refreshBalances() async {
    await loadAccounts();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
