import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class BalanceCard extends StatefulWidget {
  final double totalBalance;
  final double walletBalance;
  final double instapayBalance;
  final int walletsCount;
  final int instapayCount;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.walletBalance,
    required this.instapayBalance,
    required this.walletsCount,
    required this.instapayCount,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppColors.balanceCardGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 50,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'الرصيد الإجمالي',
                          style: AppTextStyles.bodyMediumLight,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _balanceVisible = !_balanceVisible),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _balanceVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _balanceVisible
                      ? Text(
                          Formatters.currency(widget.totalBalance),
                          key: const ValueKey('visible'),
                          style: AppTextStyles.balanceLarge,
                        )
                      : Text(
                          '••••••••',
                          key: const ValueKey('hidden'),
                          style: AppTextStyles.balanceLarge.copyWith(
                            letterSpacing: 6,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.15),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSubBalance(
                        label: 'المحافظ',
                        value: widget.walletBalance,
                        count: widget.walletsCount,
                        icon: Icons.wallet_rounded,
                        visible: _balanceVisible,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    Expanded(
                      child: _buildSubBalance(
                        label: 'انستاباي',
                        value: widget.instapayBalance,
                        count: widget.instapayCount,
                        icon: Icons.payment_rounded,
                        visible: _balanceVisible,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildSubBalance({
    required String label,
    required double value,
    required int count,
    required IconData icon,
    required bool visible,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodySmallLight),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          visible ? Formatters.compactCurrency(value) : '•••••',
          style: AppTextStyles.balanceSmall.copyWith(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        Text(
          '$count حساب',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
