import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final healthTips = ref.watch(healthTipsProvider);
    final appointments = ref.watch(
      patientAppointmentsProvider(user?.uid ?? ''),
    );
    final doctorsAsync = ref.watch(doctorListProvider(const DoctorFilter()));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.name.split(' ').first ?? 'there'} 👋',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text('How are you feeling today?', style: AppTextStyles.h2),
          ],
        ),
        toolbarHeight: 80,
        actions: [
          // Notification bell
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 28),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Recommended Doctors ───
            const SectionHeader(title: 'Recommended Doctors'),
            doctorsAsync.when(
              data: (doctors) {
                if (doctors.isEmpty) return const Text('No doctors found');
                final topDoctors = doctors.take(2).toList();
                return Column(
                  children: topDoctors.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildDoctorCard(context, doc),
                  )).toList(),
                );
              },
              loading: () => const ShimmerLoader(height: 120),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ─── Upcoming Appointment Card ───
            appointments.when(
              data: (list) {
                final upcoming = list.where((a) =>
                    a.date.isAfter(DateTime.now()) &&
                    (a.status.name == 'accepted' || a.status.name == 'pending')).toList();
                if (upcoming.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Upcoming Appointment'),
                    _buildUpcomingCard(context, upcoming.first),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: ShimmerLoader(height: 140),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ─── Health Tips Feed ───
            const SectionHeader(title: 'Health Tips'),
            healthTips.when(
              data: (tips) => Column(
                children: tips
                    .map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildHealthTipCard(context, tip),
                        ))
                    .toList(),
              ),
              loading: () => Column(
                children: List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerLoader(height: 100),
                  ),
                ),
              ),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, dynamic doctor) {
    return AppCard(
      onTap: () => context.push('/patient/doctor/${doctor.id}'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: doctor.photoUrl != null
                ? NetworkImage(doctor.photoUrl!)
                : null,
            child: doctor.photoUrl == null
                ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: AppTextStyles.subtitle),
                Text(doctor.specialty, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      AppFormatters.rating(doctor.rating),
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.currency_rupee, size: 16, color: AppColors.success),
                    Text(
                      AppFormatters.currency(doctor.consultationFee),
                      style: AppTextStyles.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, dynamic appointment) {
    return AppCard(
      onTap: () {},
      child: Row(
        children: [
          // Doctor avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: appointment.doctorPhotoUrl != null
                ? NetworkImage(appointment.doctorPhotoUrl!)
                : null,
            child: appointment.doctorPhotoUrl == null
                ? const Icon(Icons.person, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.doctorName, style: AppTextStyles.subtitle),
                const SizedBox(height: 2),
                Text(
                  appointment.doctorSpecialty,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      AppFormatters.dateWithDay(appointment.date),
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.access_time,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      appointment.timeSlot,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          StatusChip(status: appointment.status.name),
        ],
      ),
    );
  }

  Widget _buildHealthTipCard(BuildContext context, dynamic tip) {
    final categoryColors = {
      'Wellness': AppColors.primary,
      'Prevention': AppColors.secondary,
      'Mental Health': AppColors.info,
      'Nutrition': AppColors.success,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (tip.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (categoryColors[tip.category] ?? AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    tip.category!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          categoryColors[tip.category] ?? AppColors.primary,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                AppFormatters.timeAgo(tip.createdAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(tip.title, style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tip.content,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


