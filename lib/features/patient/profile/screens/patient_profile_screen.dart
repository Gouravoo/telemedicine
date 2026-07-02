import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/shared_widgets.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile', style: AppTextStyles.h1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Profile header
                AppCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primarySurface,
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? Text(
                                user?.name.substring(0, 1) ?? 'U',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(user?.name ?? 'User', style: AppTextStyles.h2),
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.bodySmall,
                      ),
                      if (user?.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(user!.phone!, style: AppTextStyles.bodySmall),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Menu items
                _menuItem(Icons.person_outline, 'Edit Profile', () {}),
                _menuItem(Icons.folder_outlined, 'My Reports', () {}),
                _menuItem(Icons.receipt_long_outlined, 'Prescriptions', () {}),
                _menuItem(Icons.notifications_outlined, 'Notifications', () {}),
                _menuItem(Icons.help_outline, 'Help & Support', () {}),
                _menuItem(Icons.info_outline, 'About AarogyaPlus', () {}),
                const SizedBox(height: AppSpacing.xl),

                // Logout
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
            Expanded(
              child: Text(label, style: AppTextStyles.bodyLarge),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
