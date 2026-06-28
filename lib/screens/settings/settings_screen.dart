import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../services/backup_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../core/extensions/extensions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        title: Text(
          'الإعدادات',
          style: AppTextStyles.headlineMedium.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('المظهر', isDark),
          _buildCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: AppColors.primary,
                title: 'الوضع الليلي',
                subtitle: settings.isDark ? 'مُفعّل' : 'غير مُفعّل',
                trailing: Switch(
                  value: settings.isDark,
                  onChanged: (_) => settings.toggleTheme(),
                  activeColor: AppColors.primary,
                ),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCard(
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.palette_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Text('لون التطبيق',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isDark ? Colors.white : null,
                            )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppConstants.walletColors.map((colorVal) {
                        final isSelected =
                            settings.primaryColor.value == colorVal;
                        return GestureDetector(
                          onTap: () =>
                              settings.setPrimaryColor(Color(colorVal)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(colorVal),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(colorVal).withOpacity(0.4),
                                  blurRadius: isSelected ? 12 : 4,
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionHeader('النسخ الاحتياطي', isDark),
          _buildCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.backup_rounded,
                iconColor: AppColors.success,
                title: 'إنشاء نسخة احتياطية',
                subtitle: 'حفظ البيانات على الجهاز ومشاركتها',
                trailing: _isBackingUp
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16),
                isDark: isDark,
                onTap: _createBackup,
              ),
              _divider(isDark),
              _SettingsTile(
                icon: Icons.restore_rounded,
                iconColor: AppColors.info,
                title: 'استعادة نسخة احتياطية',
                subtitle: 'استيراد بيانات من نسخة سابقة',
                trailing: _isRestoring
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16),
                isDark: isDark,
                onTap: _restoreBackup,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionHeader('عن التطبيق', isDark),
          _buildCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                title: 'اسم التطبيق',
                subtitle: AppConstants.appName,
                isDark: isDark,
              ),
              _divider(isDark),
              _SettingsTile(
                icon: Icons.new_releases_outlined,
                iconColor: AppColors.accent,
                title: 'الإصدار',
                subtitle: AppConstants.appVersion,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.borderDark : AppColors.border,
    );
  }

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    try {
      await _backupService.shareBackup();
      if (mounted) context.showSnackBar('تم إنشاء النسخة الاحتياطية بنجاح');
    } catch (e) {
      if (mounted) {
        context.showSnackBar('فشل إنشاء النسخة الاحتياطية', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreBackup() async {
    final confirm = await context.showConfirmDialog(
      title: 'استعادة نسخة احتياطية',
      content:
          'سيتم استبدال جميع البيانات الحالية بالنسخة الاحتياطية. هل أنت متأكد؟',
      confirmText: 'استعادة',
      isDestructive: true,
    );
    if (confirm != true || !mounted) return;

    setState(() => _isRestoring = true);
    try {
      final path = await _backupService.pickBackupFile();
      if (path == null) {
        setState(() => _isRestoring = false);
        return;
      }
      await _backupService.restoreBackup(path);
      if (mounted) {
        context.showSnackBar('تمت الاستعادة بنجاح، أعد تشغيل التطبيق');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('فشلت الاستعادة: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: trailing,
    );
  }
}
