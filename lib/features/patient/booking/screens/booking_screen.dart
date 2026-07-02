import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';
import 'package:uuid/uuid.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String doctorId;
  const BookingScreen({super.key, required this.doctorId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? _selectedDay;
  TimeSlot? _selectedSlot;
  bool _isBooking = false;
  bool _booked = false;

  final TextEditingController _reasonController = TextEditingController();
  String _selectedPaymentMethod = 'UPI';
  final List<String> _paymentMethods = ['UPI', 'Credit/Debit Card', 'Pay at Clinic'];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorDetailProvider(widget.doctorId));

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: doctorAsync.when(
        data: (doctor) {
          if (doctor == null) return const Center(child: Text('Doctor not found'));

          if (_booked) return _buildSuccess(context, doctor);

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor summary
                      AppCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primarySurface,
                              backgroundImage: doctor.photoUrl != null
                                  ? NetworkImage(doctor.photoUrl!)
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doctor.name, style: AppTextStyles.subtitle),
                                  Text(doctor.specialty, style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Text(
                              AppFormatters.currency(doctor.consultationFee),
                              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Select day
                      Text('Select Day', style: AppTextStyles.h2),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: doctor.availability.keys.map((day) {
                          final isSelected = _selectedDay == day;
                          return ChoiceChip(
                            label: Text(day),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedDay = day;
                                _selectedSlot = null;
                              });
                            },
                            selectedColor: AppColors.primarySurface,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Select time slot
                      if (_selectedDay != null) ...[
                        Text('Select Time', style: AppTextStyles.h2),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: (doctor.availability[_selectedDay] ?? [])
                              .map((slot) {
                            final isSelected = _selectedSlot == slot;
                            return ChoiceChip(
                              label: Text('${slot.startTime} - ${slot.endTime}'),
                              selected: isSelected,
                              onSelected: slot.isBooked
                                  ? null
                                  : (_) => setState(() => _selectedSlot = slot),
                              selectedColor: AppColors.primarySurface,
                              disabledColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],

                      // Confirm button
                      if (_selectedSlot != null) ...[
                        // ─── Short Form (Reason & Payment) ───
                        Text('Additional Details', style: AppTextStyles.h2),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _reasonController,
                          decoration: InputDecoration(
                            labelText: 'Reason for Visit (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          value: _selectedPaymentMethod,
                          decoration: InputDecoration(
                            labelText: 'Payment Method',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                          ),
                          items: _paymentMethods
                              .map((method) => DropdownMenuItem(
                                    value: method,
                                    child: Text(method),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedPaymentMethod = value);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        AppCard(
                          color: AppColors.primarySurface,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Booking Summary', style: AppTextStyles.labelLarge),
                              const SizedBox(height: AppSpacing.md),
                              _summaryRow('Doctor', doctor.name),
                              _summaryRow('Specialty', doctor.specialty),
                              _summaryRow('Day', _selectedDay!),
                              _summaryRow('Time', '${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}'),
                              _summaryRow('Payment', _selectedPaymentMethod),
                              _summaryRow('Fee', AppFormatters.currency(doctor.consultationFee)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: 'Pay & Confirm Booking',
                          isLoading: _isBooking,
                          icon: Icons.payment_rounded,
                          onPressed: () => _confirmBooking(doctor),
                        ),
                      ],
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

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Future<void> _confirmBooking(DoctorModel doctor) async {
    setState(() => _isBooking = true);
    final user = ref.read(currentUserProvider);
    final firestoreService = ref.read(firestoreServiceProvider);

    final appointment = AppointmentModel(
      id: const Uuid().v4(),
      patientId: user?.uid ?? '',
      doctorId: doctor.id,
      patientName: user?.name ?? '',
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      doctorPhotoUrl: doctor.photoUrl,
      patientPhotoUrl: user?.photoUrl,
      date: _getNextDate(_selectedDay!),
      timeSlot: '${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}',
      status: AppointmentStatus.accepted, // Auto-accept for demo
      agoraChannelName: 'call_${const Uuid().v4().substring(0, 8)}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await firestoreService.createAppointment(appointment);
    ref.invalidate(patientAppointmentsProvider(user?.uid ?? ''));
    ref.invalidate(allAppointmentsProvider);
    
    setState(() {
      _isBooking = false;
      _booked = true;
    });
  }

  DateTime _getNextDate(String dayName) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final targetDay = days.indexOf(dayName) + 1;
    var date = DateTime.now();
    while (date.weekday != targetDay) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  Widget _buildSuccess(BuildContext context, DoctorModel doctor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.successSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Appointment Booked!', style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your appointment with ${doctor.name} has been requested.\nYou will be notified once the doctor confirms.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'View My Appointments',
              onPressed: () => context.go('/patient/appointments'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Back to Home',
              isOutlined: true,
              onPressed: () => context.go('/patient/home'),
            ),
          ],
        ),
      ),
    );
  }
}
