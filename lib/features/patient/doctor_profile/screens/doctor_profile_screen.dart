import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';

class DoctorProfileScreen extends ConsumerWidget {
  final String doctorId;

  const DoctorProfileScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorDetailProvider(doctorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
      ),
      body: doctorAsync.when(
        data: (doctor) {
          if (doctor == null) {
            return const EmptyState(
              icon: Icons.person_off,
              title: 'Doctor not found',
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Doctor Header Card ───
                      AppCard(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColors.primarySurface,
                                  backgroundImage: doctor.photoUrl != null
                                      ? NetworkImage(doctor.photoUrl!)
                                      : null,
                                  child: doctor.photoUrl == null
                                      ? Text(
                                          doctor.name.substring(0, 1),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.base),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(doctor.name,
                                          style: AppTextStyles.h1),
                                      const SizedBox(height: 4),
                                      Text(
                                        doctor.specialty,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (doctor.qualifications != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          doctor.qualifications!,
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.base),
                            const Divider(),
                            const SizedBox(height: AppSpacing.md),
                            // Stats row
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _buildStat(
                                  Icons.star_rounded,
                                  AppFormatters.rating(doctor.rating),
                                  '${doctor.ratingCount} reviews',
                                  AppColors.warning,
                                ),
                                _buildStat(
                                  Icons.work_outline,
                                  '${doctor.experienceYears}+',
                                  'Years Exp.',
                                  AppColors.secondary,
                                ),
                                _buildStat(
                                  Icons.currency_rupee,
                                  AppFormatters.currency(
                                      doctor.consultationFee),
                                  'Per session',
                                  AppColors.success,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            // ─── Book Button (Prominent) ───
                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                label: 'Book Appointment',
                                icon: Icons.calendar_today_rounded,
                                onPressed: () =>
                                    context.push('/patient/book/$doctorId'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ─── About ───
                      if (doctor.bio != null) ...[
                        Text('About', style: AppTextStyles.h2),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          child: Text(
                            doctor.bio!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.7,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // ─── Available Slots ───
                      Text('Available Slots', style: AppTextStyles.h2),
                      const SizedBox(height: AppSpacing.sm),
                      if (doctor.availability.isEmpty)
                        const AppCard(
                          child: Text('No slots available currently'),
                        )
                      else
                        ...doctor.availability.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.md),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: AppTextStyles.labelLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.sm,
                                    children: entry.value.map((slot) {
                                      return ChoiceChip(
                                        label: Text(
                                          '${slot.startTime} - ${slot.endTime}',
                                        ),
                                        selected: false,
                                        onSelected: slot.isBooked
                                            ? null
                                            : (_) {},
                                        backgroundColor:
                                            AppColors.surfaceVariant,
                                        selectedColor:
                                            AppColors.primarySurface,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: AppSpacing.xxl),


                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStat(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
