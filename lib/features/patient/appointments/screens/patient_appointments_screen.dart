import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/appointment_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';

class PatientAppointmentsScreen extends ConsumerWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final appointmentsAsync =
        ref.watch(patientAppointmentsProvider(user?.uid ?? ''));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('My Appointments', style: AppTextStyles.h1),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: appointmentsAsync.when(
          data: (appointments) {
            final upcoming = appointments
                .where((a) =>
                    a.status == AppointmentStatus.pending ||
                    a.status == AppointmentStatus.accepted)
                .toList();
            final completed = appointments
                .where((a) => a.status == AppointmentStatus.completed)
                .toList();
            final cancelled = appointments
                .where((a) =>
                    a.status == AppointmentStatus.cancelled ||
                    a.status == AppointmentStatus.rejected)
                .toList();

            return TabBarView(
              children: [
                _buildList(upcoming, 'No upcoming appointments',
                    'Book a consultation to get started'),
                _buildList(completed, 'No completed appointments',
                    'Your consultation history will appear here'),
                _buildList(cancelled, 'No cancelled appointments', null),
              ],
            );
          },
          loading: () => Center(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: 3,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerLoader(height: 110),
              ),
            ),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildList(
      List<AppointmentModel> list, String emptyTitle, String? emptySubtitle) {
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) =>
          _buildAppointmentCard(context, list[index]),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, AppointmentModel appointment) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primarySurface,
                backgroundImage: appointment.doctorPhotoUrl != null
                    ? NetworkImage(appointment.doctorPhotoUrl!)
                    : null,
                child: appointment.doctorPhotoUrl == null
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.doctorName,
                        style: AppTextStyles.subtitle),
                    Text(appointment.doctorSpecialty,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              StatusChip(status: appointment.status.name),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                AppFormatters.dateWithDay(appointment.date),
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(width: AppSpacing.base),
              Icon(Icons.access_time,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(appointment.timeSlot, style: AppTextStyles.bodySmall),
              const Spacer(),
              if (appointment.isAccepted)
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: appointment.isCallEnabled ? () {
                      context.push(
                        '/call/${appointment.agoraChannelName ?? appointment.id}',
                        extra: {
                          'callerName': appointment.patientName,
                          'calleeName': appointment.doctorName,
                          'isDoctor': false,
                        },
                      );
                    } : null,
                    icon: const Icon(Icons.videocam, size: 16),
                    label: const Text('Join Call'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
