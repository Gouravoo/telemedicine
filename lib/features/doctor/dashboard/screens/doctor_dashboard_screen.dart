import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/appointment_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    // In a real app, doctorId would come from the user's linked doctor profile
    final appointmentsAsync =
        ref.watch(doctorAppointmentsProvider(user?.uid ?? 'doc_1'));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_greeting()},',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(user?.name ?? 'Doctor', style: AppTextStyles.h2),
          ],
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          final pending = appointments
              .where((a) => a.status == AppointmentStatus.pending)
              .toList();
          final todayAccepted = appointments
              .where((a) =>
                  a.status == AppointmentStatus.accepted &&
                  a.date.day == DateTime.now().day)
              .toList();
          final completed = appointments
              .where((a) => a.status == AppointmentStatus.completed)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats cards
                _buildStatsRow(
                  pending.length,
                  todayAccepted.length,
                  completed,
                  appointments.length,
                  context,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Pending requests
                if (pending.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Pending Requests (${pending.length})',
                  ),
                  ...pending.map((a) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildRequestCard(context, ref, a),
                      )),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Today's appointments
                const SectionHeader(title: "Today's Schedule"),
                if (todayAccepted.isEmpty)
                  const AppCard(
                    child: EmptyState(
                      icon: Icons.event_available,
                      title: 'No appointments today',
                      subtitle: 'Enjoy your free time!',
                    ),
                  )
                else
                  ...todayAccepted.map((a) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildScheduleCard(context, a),
                      )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatsRow(
    int pending,
    int today,
    int completed,
    int total,
    BuildContext context,
  ) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final stats = [
      _StatItem('Pending', '$pending', Icons.pending_actions,
          AppColors.warning, AppColors.warningSurface),
      _StatItem("Today", '$today', Icons.today,
          AppColors.secondary, AppColors.secondarySurface),
      _StatItem('Completed', '$completed', Icons.check_circle_outline,
          AppColors.success, AppColors.successSurface),
      _StatItem('Total', '$total', Icons.bar_chart,
          AppColors.primary, AppColors.primarySurface),
    ];

    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: isWide ? 2.2 : 1.8,
      children: stats.map((s) {
        return AppCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: s.bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(s.icon, color: s.color, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    s.value,
                    style: AppTextStyles.h1.copyWith(color: s.color),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(s.label, style: AppTextStyles.caption),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, WidgetRef ref, AppointmentModel appointment) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.secondarySurface,
                backgroundImage: appointment.patientPhotoUrl != null
                    ? NetworkImage(appointment.patientPhotoUrl!)
                    : null,
                child: appointment.patientPhotoUrl == null
                    ? Text(
                        appointment.patientName.isNotEmpty
                            ? appointment.patientName[0]
                            : 'P',
                        style: const TextStyle(color: AppColors.secondary),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName,
                        style: AppTextStyles.subtitle),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          AppFormatters.dateShort(appointment.date),
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 8),
                        Text(appointment.timeSlot,
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () async {
                      final service = ref.read(databaseServiceProvider);
                      await service.updateAppointmentStatus(
                        appointment.id,
                        AppointmentStatus.rejected,
                      );
                      ref.invalidate(
                          doctorAppointmentsProvider);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () async {
                      final service = ref.read(databaseServiceProvider);
                      await service.updateAppointmentStatus(
                        appointment.id,
                        AppointmentStatus.accepted,
                      );
                      ref.invalidate(
                          doctorAppointmentsProvider);
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
      BuildContext context, AppointmentModel appointment) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.patientName,
                    style: AppTextStyles.subtitle),
                Text(appointment.timeSlot,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/call/${appointment.agoraChannelName ?? appointment.id}',
                  extra: {
                    'callerName': appointment.doctorName,
                    'calleeName': appointment.patientName,
                    'isDoctor': true,
                  },
                );
              },
              icon: const Icon(Icons.videocam, size: 16),
              label: const Text('Start Call'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontSize: 12),
                backgroundColor: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  _StatItem(this.label, this.value, this.icon, this.color, this.bgColor);
}
