import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/shared_widgets.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(allAppointmentsProvider);
    final patientsAsync = ref.watch(allPatientsProvider);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Panel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text('Dashboard', style: AppTextStyles.h2),
          ],
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              ref.read(currentUserProvider.notifier).state = null;
              context.go('/login');
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Cards
            GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: isWide ? 2 : 1.6,
              children: [
                _kpiCard('Total Doctors', '6', Icons.medical_services,
                    AppColors.secondary, AppColors.secondarySurface),
                _kpiCard(
                    'Total Patients',
                    patientsAsync.when(
                      data: (p) => '${p.length}',
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.people,
                    AppColors.primary,
                    AppColors.primarySurface),
                _kpiCard(
                    'Appointments Today',
                    appointmentsAsync.when(
                      data: (a) =>
                          '${a.where((x) => x.date.day == DateTime.now().day).length}',
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.calendar_today,
                    AppColors.warning,
                    AppColors.warningSurface),
                _kpiCard('Revenue', '₹0', Icons.currency_rupee,
                    AppColors.success, AppColors.successSurface),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Quick actions
            Text('Quick Actions', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _actionCard(context, 'Add Doctor', Icons.person_add,
                    AppColors.secondary, () => context.go('/admin/doctors')),
                _actionCard(context, 'View Appointments', Icons.event_note,
                    AppColors.primary, () => context.go('/admin/appointments')),
                _actionCard(context, 'Manage Patients', Icons.people,
                    AppColors.warning, () => context.go('/admin/patients')),
                _actionCard(context, 'Health Tips', Icons.lightbulb,
                    AppColors.success, () => context.go('/admin/health-tips')),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Recent appointments
            const SectionHeader(title: 'Recent Appointments'),
            appointmentsAsync.when(
              data: (appointments) {
                final recent = appointments.take(5).toList();
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                          AppColors.surfaceVariant),
                      columns: const [
                        DataColumn(label: Text('Patient')),
                        DataColumn(label: Text('Doctor')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: recent.map((a) {
                        return DataRow(cells: [
                          DataCell(Text(a.patientName)),
                          DataCell(Text(a.doctorName)),
                          DataCell(Text(a.timeSlot)),
                          DataCell(StatusChip(status: a.status.name)),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const ShimmerLoader(height: 200),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(
      String label, String value, IconData icon, Color color, Color bgColor) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(value, style: AppTextStyles.h1.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return SizedBox(
      width: 160,
      child: AppCard(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.labelMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
