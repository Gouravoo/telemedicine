import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/widgets/shared_widgets.dart';

class AdminPatientsScreen extends ConsumerWidget {
  const AdminPatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(allPatientsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Patient Management', style: AppTextStyles.h1),
      ),
      body: patientsAsync.when(
        data: (patients) {
          if (patients.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'No patients registered',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(AppColors.surfaceVariant),
                  columns: const [
                    DataColumn(label: Text('Patient ID')),
                    DataColumn(label: Text('Age')),
                    DataColumn(label: Text('Gender')),
                    DataColumn(label: Text('Blood Group')),
                  ],
                  rows: patients.map((p) {
                    return DataRow(cells: [
                      DataCell(Text(p.uid)),
                      DataCell(Text('${p.age ?? '-'}')),
                      DataCell(Text(p.gender ?? '-')),
                      DataCell(Text(p.bloodGroup ?? '-')),
                    ]);
                  }).toList(),
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
}
