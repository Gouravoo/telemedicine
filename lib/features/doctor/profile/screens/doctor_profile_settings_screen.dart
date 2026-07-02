import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/shared_widgets.dart';

class DoctorProfileSettingsScreen extends ConsumerWidget {
  const DoctorProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile & Settings', style: AppTextStyles.h1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                AppCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.secondarySurface,
                        child: Text(
                          user?.name.substring(0, 1) ?? 'D',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(user?.name ?? 'Doctor', style: AppTextStyles.h2),
                      Text(user?.email ?? '', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _menuItem(Icons.person_outline, 'Edit Profile', () {}),
                _menuItem(Icons.schedule, 'Availability Settings', () {}),
                _menuItem(Icons.notifications_outlined, 'Notifications', () {}),
                _menuItem(Icons.help_outline, 'Help & Support', () {}),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Sign Out',
                  icon: Icons.logout,
                  backgroundColor: AppColors.error,
                  onPressed: () {
                    ref.read(authServiceProvider).signOut();
                    ref.read(currentUserProvider.notifier).state = null;
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
