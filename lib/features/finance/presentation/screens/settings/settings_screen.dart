import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/text_styles.dart';

/// Sozlamalar ekrani
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          // Profil bo'limi
          _buildSectionHeader('Profil'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: const Text('Foydalanuvchi'),
                  subtitle: const Text('Profilni tahrirlash'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Profil sahifasi
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLarge),

          // Sozlamalar bo'limi
          _buildSectionHeader('Sozlamalar'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text(AppStrings.currency),
                  subtitle: const Text('O\'zbekiston so\'mi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Valyuta tanlash
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text(AppStrings.language),
                  subtitle: const Text('O\'zbekcha'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Til tanlash
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text(AppStrings.theme),
                  subtitle: const Text('Yorug\' rejim'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // TODO: Dark mode
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLarge),

          // Kategoriyalar bo'limi
          _buildSectionHeader('Ma\'lumotlar'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text(AppStrings.categories),
                  subtitle: const Text('Kategoriyalarni boshqarish'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Kategoriyalar sahifasi
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Zaxira nusxa'),
                  subtitle: const Text('Ma\'lumotlarni saqlash'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showBackupDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Qayta tiklash'),
                  subtitle: const Text('Zaxiradan tiklash'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showRestoreDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLarge),

          // Ma'lumot bo'limi
          _buildSectionHeader('Ma\'lumot'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Ilova haqida'),
                  subtitle: const Text('Versiya 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Maxfiylik siyosati'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Maxfiylik siyosati
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Foydalanish shartlari'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Foydalanish shartlari
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLarge),

          // Xavfli amallar
          _buildSectionHeader('Xavfli amallar'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text(
                'Barcha ma\'lumotlarni o\'chirish',
                style: TextStyle(color: AppColors.error),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.error),
              onTap: () {
                _showDeleteAllDialog(context);
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLarge),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingSmall,
        bottom: AppDimensions.paddingSmall,
      ),
      child: Text(
        title,
        style: AppTextStyles.h4.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Versiya: 1.0.0'),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              'Shaxsiy moliyani boshqarish ilovasi',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            const Text('© 2025 Moliya Menejeri'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zaxira nusxa'),
        content: const Text(
          'Barcha ma\'lumotlaringiz zaxira nusxasi saqlanadi. Davom etasizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Zaxira nusxa yaratish
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zaxira nusxa saqlandi')),
              );
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qayta tiklash'),
        content: const Text(
          'Zaxira nusxadan ma\'lumotlarni tiklaysizmi? Joriy ma\'lumotlar o\'chiriladi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Zaxiradan tiklash
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ma\'lumotlar tiklandi')),
              );
            },
            child: const Text('Tiklash'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xavfli amal!'),
        content: const Text(
          'BARCHA ma\'lumotlar o\'chiriladi va qayta tiklanmaydi. Davom etasizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Barcha ma\'lumotlarni o\'chirish
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Barcha ma\'lumotlar o\'chirildi'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}