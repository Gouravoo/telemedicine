import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';

class AdminAppointmentsScreen extends ConsumerWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(allAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('All Appointments', style: AppTextStyles.h1),
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          if (appointments.isEmpty) {
            return const EmptyState(
              icon: Icons.event_note,
              title: 'No appointments yet',
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
                    DataColumn(label: Text('Patient')),
                    DataColumn(label: Text('Doctor')),
                    DataColumn(label: Text('Specialty')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: appointments.map((a) {
                    return DataRow(cells: [
                      DataCell(Text(a.patientName)),
                      DataCell(Text(a.doctorName)),
                      DataCell(Text(a.doctorSpecialty)),
                      DataCell(Text(AppFormatters.dateShort(a.date))),
                      DataCell(Text(a.timeSlot)),
                      DataCell(StatusChip(status: a.status.name)),
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
