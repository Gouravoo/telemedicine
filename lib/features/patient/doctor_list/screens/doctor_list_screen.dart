import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/doctor_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  String? _selectedSpecialty;
  String _searchQuery = '';
  String _sortBy = 'rating';

  @override
  Widget build(BuildContext context) {
    final filter = DoctorFilter(
      specialty: _selectedSpecialty,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      sortBy: _sortBy,
    );
    final doctors = ref.watch(doctorListProvider(filter));
    final specialties = ref.watch(specialtiesProvider);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Find a Doctor', style: AppTextStyles.h1),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search doctors by name or specialty...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort),
                      tooltip: 'Sort by',
                      onSelected: (v) => setState(() => _sortBy = v),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'rating', child: Text('Rating')),
                        const PopupMenuItem(value: 'experience', child: Text('Experience')),
                        const PopupMenuItem(value: 'fee_low', child: Text('Fee: Low to High')),
                        const PopupMenuItem(value: 'fee_high', child: Text('Fee: High to Low')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Specialty filter chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedSpecialty == null,
                    onSelected: (_) =>
                        setState(() => _selectedSpecialty = null),
                    selectedColor: AppColors.primarySurface,
                    checkmarkColor: AppColors.primary,
                  ),
                ),
                ...specialties.map((s) => Padding(
                      padding:
                          const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(s),
                        selected: _selectedSpecialty == s,
                        onSelected: (_) =>
                            setState(() => _selectedSpecialty = s),
                        selectedColor: AppColors.primarySurface,
                        checkmarkColor: AppColors.primary,
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Doctor list/grid
          Expanded(
            child: doctors.when(
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No doctors found',
                    subtitle: 'Try adjusting your search or filters',
                  );
                }

                if (isWide) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 1024 ? 3 : 2,
                      crossAxisSpacing: AppSpacing.base,
                      mainAxisSpacing: AppSpacing.base,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) =>
                        _buildDoctorCard(context, list[i]),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) =>
                      _buildDoctorCard(context, list[i]),
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base),
                itemCount: 4,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ShimmerLoader(height: 120),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doctor) {
    return AppCard(
      onTap: () => context.push('/patient/doctor/${doctor.id}'),
      child: Row(
        children: [
          // Photo
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: doctor.photoUrl != null
                ? NetworkImage(doctor.photoUrl!)
                : null,
            child: doctor.photoUrl == null
                ? Text(
                    doctor.name.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: AppTextStyles.subtitle),
                const SizedBox(height: 2),
                Text(doctor.specialty, style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningSurface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            AppFormatters.rating(doctor.rating),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Experience
                    Text(
                      '${doctor.experienceYears} yrs exp',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Fee + Book
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(doctor.consultationFee),
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () =>
                      context.push('/patient/doctor/${doctor.id}'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
