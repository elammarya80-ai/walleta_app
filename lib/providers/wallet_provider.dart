import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  List<WalletModel> _wallets = [];
  List<WalletModel> _filteredWallets = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  double _totalBalance = 0.0;

  List<WalletModel> get wallets => _filteredWallets;
  List<WalletModel> get allWallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  double get totalBalance => _totalBalance;
  int get count => _wallets.length;

  Future<void> loadWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _wallets = await _service.getAllWallets();
      _totalBalance = _wallets.fold(0, (s, w) => s + w.balance);
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
      _filteredWallets = List.from(_wallets);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredWallets = _wallets.where((w) {
        return w.name.toLowerCase().contains(q) ||
            w.number.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<bool> addWallet(WalletModel wallet) async {
    try {
      final id = await _service.createWallet(wallet);
      final newWallet = wallet.copyWith(id: id);
      _wallets.insert(0, newWallet);
      _totalBalance += newWallet.balance;
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWallet(WalletModel wallet) async {
    try {
      await _service.updateWallet(wallet);
      final idx = _wallets.indexWhere((w) => w.id == wallet.id);
      if (idx != -1) {
        final old = _wallets[idx];
        _totalBalance = _totalBalance - old.balance + wallet.balance;
        _wallets[idx] = wallet;
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

  Future<bool> deleteWallet(int id) async {
    try {
      await _service.deleteWallet(id);
      final wallet = _wallets.firstWhere((w) => w.id == id);
      _totalBalance -= wallet.balance;
      _wallets.removeWhere((w) => w.id == id);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshBalances() async {
    await loadWallets();
  }

  WalletModel? getWalletById(int id) {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
