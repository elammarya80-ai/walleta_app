import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _service = ReportService();

  ReportModel? _report;
  bool _isLoading = false;
  String? _error;
  String _period = AppConstants.periodMonthly;
  DateTime _selectedDate = DateTime.now();

  ReportModel? get report => _report;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get period => _period;
  DateTime get selectedDate => _selectedDate;

  Future<void> loadReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      switch (_period) {
        case AppConstants.periodDaily:
          _report = await _service.generateDailyReport(_selectedDate);
          break;
        case AppConstants.periodWeekly:
          final weekStart = _selectedDate.subtract(
            Duration(days: _selectedDate.weekday % 7),
          );
          _report = await _service.generateWeeklyReport(weekStart);
          break;
        case AppConstants.periodMonthly:
          _report = await _service.generateMonthlyReport(
            _selectedDate.year,
            _selectedDate.month,
          );
          break;
        case AppConstants.periodYearly:
          _report = await _service.generateYearlyReport(_selectedDate.year);
          break;
        default:
          _report = await _service.generateMonthlyReport(
            _selectedDate.year,
            _selectedDate.month,
          );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPeriod(String period) {
    _period = period;
    loadReport();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    loadReport();
  }

  void previousPeriod() {
    switch (_period) {
      case AppConstants.periodDaily:
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        break;
      case AppConstants.periodWeekly:
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case AppConstants.periodMonthly:
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
        break;
      case AppConstants.periodYearly:
        _selectedDate = DateTime(_selectedDate.year - 1);
        break;
    }
    loadReport();
  }

  void nextPeriod() {
    switch (_period) {
      case AppConstants.periodDaily:
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        break;
      case AppConstants.periodWeekly:
        _selectedDate = _selectedDate.add(const Duration(days: 7));
        break;
      case AppConstants.periodMonthly:
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
        break;
      case AppConstants.periodYearly:
        _selectedDate = DateTime(_selectedDate.year + 1);
        break;
    }
    loadReport();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
