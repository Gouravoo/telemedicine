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

class DoctorAppointmentsScreen extends ConsumerWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final appointmentsAsync =
        ref.watch(doctorAppointmentsProvider(user?.uid ?? 'doc_1'));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Appointments', style: AppTextStyles.h1),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Completed'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: appointmentsAsync.when(
          data: (appointments) {
            final groups = {
              AppointmentStatus.pending: appointments
                  .where((a) => a.isPending)
                  .toList(),
              AppointmentStatus.accepted: appointments
                  .where((a) => a.isAccepted)
                  .toList(),
              AppointmentStatus.completed: appointments
                  .where((a) => a.isCompleted)
                  .toList(),
              AppointmentStatus.rejected: appointments
                  .where((a) => a.isRejected || a.isCancelled)
                  .toList(),
            };

            return TabBarView(
              children: groups.entries.map((entry) {
                final list = entry.value;
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_note,
                    title: 'No ${entry.key.name} appointments',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, i) =>
                      _buildCard(context, ref, list[i]),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, WidgetRef ref, AppointmentModel a) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.secondarySurface,
                child: Text(
                  a.patientName.isNotEmpty ? a.patientName[0] : 'P',
                  style: const TextStyle(color: AppColors.secondary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.patientName, style: AppTextStyles.subtitle),
                    Text(
                      '${AppFormatters.dateShort(a.date)} • ${a.timeSlot}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              StatusChip(status: a.status.name),
            ],
          ),
          if (a.isPending) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(databaseServiceProvider)
                            .updateAppointmentStatus(
                                a.id, AppointmentStatus.rejected);
                        ref.invalidate(doctorAppointmentsProvider);
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
                        await ref
                            .read(databaseServiceProvider)
                            .updateAppointmentStatus(
                                a.id, AppointmentStatus.accepted);
                        ref.invalidate(doctorAppointmentsProvider);
                      },
                      child: const Text('Accept'),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (a.isAccepted) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.videocam, size: 16),
                      label: const Text('Start Call'),
                      onPressed: () {
                        context.push(
                          '/call/${a.agoraChannelName ?? a.id}',
                          extra: {
                            'callerName': a.doctorName,
                            'calleeName': a.patientName,
                            'isDoctor': true,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(databaseServiceProvider)
                          .updateAppointmentStatus(
                              a.id, AppointmentStatus.completed);
                      ref.invalidate(doctorAppointmentsProvider);
                    },
                    child: const Text('Complete'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
