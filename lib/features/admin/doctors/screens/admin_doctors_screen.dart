import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/doctor_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';

class AdminDoctorsScreen extends ConsumerWidget {
  const AdminDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(
      doctorListProvider(const DoctorFilter()),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Doctor Management', style: AppTextStyles.h1),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddDoctorDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Doctor'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(width: AppSpacing.base),
        ],
      ),
      body: doctorsAsync.when(
        data: (doctors) {
          if (doctors.isEmpty) {
            return const EmptyState(
              icon: Icons.medical_services_outlined,
              title: 'No doctors yet',
              subtitle: 'Add your first doctor to get started',
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
                    DataColumn(label: Text('Doctor')),
                    DataColumn(label: Text('Specialty')),
                    DataColumn(label: Text('Experience')),
                    DataColumn(label: Text('Fee')),
                    DataColumn(label: Text('Rating')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: doctors.map((d) {
                    return DataRow(cells: [
                      DataCell(Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primarySurface,
                            backgroundImage: d.photoUrl != null
                                ? NetworkImage(d.photoUrl!)
                                : null,
                            child: d.photoUrl == null
                                ? Text(d.name[0],
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary))
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(d.name),
                        ],
                      )),
                      DataCell(Text(d.specialty)),
                      DataCell(Text('${d.experienceYears} yrs')),
                      DataCell(Text(
                          AppFormatters.currency(d.consultationFee))),
                      DataCell(Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: AppColors.warning),
                          Text(' ${AppFormatters.rating(d.rating)}'),
                        ],
                      )),
                      DataCell(StatusChip(
                        status: d.isActive ? 'accepted' : 'rejected',
                        fontSize: 11,
                      )),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _showEditDoctorDialog(context, ref, d),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: Icon(
                              d.isActive
                                  ? Icons.block
                                  : Icons.check_circle_outline,
                              size: 18,
                              color: d.isActive
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                            onPressed: () async {
                              if (d.isActive) {
                                await ref
                                    .read(databaseServiceProvider)
                                    .deleteDoctor(d.id);
                              } else {
                                await ref
                                    .read(databaseServiceProvider)
                                    .updateDoctor(
                                        d.copyWith(isActive: true));
                              }
                              ref.invalidate(doctorListProvider);
                            },
                            tooltip: d.isActive ? 'Deactivate' : 'Activate',
                          ),
                        ],
                      )),
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

  void _showAddDoctorDialog(BuildContext context, WidgetRef ref) {
    _showDoctorDialog(context, ref, null);
  }

  void _showEditDoctorDialog(BuildContext context, WidgetRef ref, DoctorModel doctor) {
    _showDoctorDialog(context, ref, doctor);
  }

  void _showDoctorDialog(BuildContext context, WidgetRef ref, DoctorModel? doctor) {
    final isEditing = doctor != null;
    final nameController = TextEditingController(text: doctor?.name);
    final emailController = TextEditingController(text: doctor?.email);
    final photoUrlController = TextEditingController(text: doctor?.photoUrl);
    final feeController = TextEditingController(text: doctor?.consultationFee.toString());
    final expController = TextEditingController(text: doctor?.experienceYears.toString());
    final qualController = TextEditingController(text: doctor?.qualifications);
    final bioController = TextEditingController(text: doctor?.bio);
    String? specialty = doctor?.specialty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Doctor' : 'Add New Doctor'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: photoUrlController,
                  decoration: const InputDecoration(hintText: 'Photo URL (Premium Picture)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(hintText: 'Specialty'),
                  value: specialty,
                  items: ref
                      .read(databaseServiceProvider)
                      .getSpecialties()
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => specialty = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qualController,
                  decoration: const InputDecoration(hintText: 'Qualifications (e.g., MBBS, MD)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: feeController,
                        decoration: const InputDecoration(hintText: 'Consultation Fee'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: expController,
                        decoration: const InputDecoration(hintText: 'Experience (years)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(hintText: 'Bio / Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newDoctor = DoctorModel(
                id: isEditing ? doctor.id : 'doc_${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text,
                email: emailController.text,
                photoUrl: photoUrlController.text.isNotEmpty ? photoUrlController.text : null,
                specialty: specialty ?? 'General Physician',
                qualifications: qualController.text,
                consultationFee: double.tryParse(feeController.text) ?? 500,
                experienceYears: int.tryParse(expController.text) ?? 1,
                bio: bioController.text,
                isActive: isEditing ? doctor.isActive : true,
                rating: isEditing ? doctor.rating : 5.0,
                ratingCount: isEditing ? doctor.ratingCount : 0,
                availability: isEditing ? doctor.availability : {},
              );

              final service = ref.read(databaseServiceProvider);
              if (isEditing) {
                await service.updateDoctor(newDoctor);
              } else {
                await service.addDoctor(newDoctor);
              }
              ref.invalidate(doctorListProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(isEditing ? 'Save Changes' : 'Add Doctor'),
          ),
        ],
      ),
    );
  }
}
