import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../theme/app_colors.dart';

class Helpers {
  Helpers._();

  static Color getTransactionColor(String type) {
    switch (type) {
      case AppConstants.txTransfer:
        return AppColors.transferColor;
      case AppConstants.txWithdraw:
        return AppColors.withdrawColor;
      case AppConstants.txDeposit:
        return AppColors.depositColor;
      default:
        return AppColors.primary;
    }
  }

  static IconData getTransactionIcon(String type) {
    switch (type) {
      case AppConstants.txTransfer:
        return Icons.swap_horiz_rounded;
      case AppConstants.txWithdraw:
        return Icons.arrow_upward_rounded;
      case AppConstants.txDeposit:
        return Icons.arrow_downward_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return AppColors.success;
      case AppConstants.statusPending:
        return AppColors.warning;
      case AppConstants.statusFailed:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return Icons.check_circle_rounded;
      case AppConstants.statusPending:
        return Icons.hourglass_empty_rounded;
      case AppConstants.statusFailed:
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  static IconData getSourceIcon(String source) {
    switch (source) {
      case AppConstants.sourceWallet:
        return Icons.account_balance_wallet_rounded;
      case AppConstants.sourceInstapay:
        return Icons.payment_rounded;
      case AppConstants.sourceCash:
        return Icons.money_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }

  static double parseAmount(String value) {
    return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
  }

  static List<Color> getWalletGradient(int colorValue) {
    final base = Color(colorValue);
    return [
      base,
      Color.lerp(base, Colors.black, 0.3) ?? base,
    ];
  }
}
