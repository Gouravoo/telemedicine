import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/shared_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodGroup;
  UserRole _selectedRole = UserRole.patient;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        role: _selectedRole,
      );
      ref.read(currentUserProvider.notifier).state = user;
      
      if (mounted) setState(() => _isLoading = false);
      
      if (mounted) {
        switch (user.role) {
          case UserRole.patient:
            context.go('/patient/home');
            break;
          case UserRole.doctor:
            context.go('/doctor/dashboard');
            break;
          case UserRole.admin:
            context.go('/admin/dashboard');
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Registration Failed'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Join AarogyaPlus', style: AppTextStyles.displayMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Create your account to book consultations',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    validator: Validators.name,
                    decoration: const InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    validator: Validators.password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Role Selection
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      hintText: 'Register As',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.patient,
                        child: Text('Patient'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.doctor,
                        child: Text('Doctor'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.admin,
                        child: Text('Admin'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedRole = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.base),
                  TextFormField(
                    controller: _passwordController,
                    validator: Validators.password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Phone Number (optional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Age + Gender row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          validator: Validators.age,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Age',
                            prefixIcon: Icon(Icons.cake_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.base),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            hintText: 'Gender',
                            prefixIcon: Icon(Icons.wc_outlined),
                          ),
                          items: AppConstants.genderOptions
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedGender = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Blood Group
                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    decoration: const InputDecoration(
                      hintText: 'Blood Group (optional)',
                      prefixIcon: Icon(Icons.bloodtype_outlined),
                    ),
                    items: AppConstants.bloodGroups
                        .map((b) => DropdownMenuItem(
                              value: b,
                              child: Text(b),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedBloodGroup = v),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  AppButton(
                    label: 'Create Account',
                    isLoading: _isLoading,
                    onPressed: _register,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
