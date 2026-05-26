import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/router/app_routes.dart';
import '../features/auth/presentation/auth_notifier.dart';
import '../features/auth/presentation/auth_widgets.dart';

/// Register screen — terhubung ke AuthNotifier via Riverpod.
class RegisterParukuat extends ConsumerStatefulWidget {
  const RegisterParukuat({super.key});

  @override
  ConsumerState<RegisterParukuat> createState() => _RegisterParukuatState();
}

class _RegisterParukuatState extends ConsumerState<RegisterParukuat> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _obscurePassword = true;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).register(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          birthDate: _selectedDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    final availHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next is AuthAuthenticated) {
        context.go(AppRoutes.home);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    final isLoading = ref.watch(authNotifierProvider) is AuthLoading;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: availHeight * 0.06),
                    const _RegisterHeader(),
                    SizedBox(height: availHeight * 0.025),
                    _RegisterCard(
                      fullNameController: _fullNameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      phoneController: _phoneController,
                      birthDateController: _birthDateController,
                      obscurePassword: _obscurePassword,
                      isLoading: isLoading,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onPickDate: _pickDate,
                      onSubmit: _submit,
                    ),
                    SizedBox(height: availHeight * 0.035),
                    _RegisterFooter(isLoading: isLoading),
                    SizedBox(height: availHeight * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// HEADER
// ====================================================================
class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/LogoParuKuat.png',
                width: 30,
                height: 30,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.health_and_safety,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 8),
              const Text('ParuKuat', style: AppTextStyles.brandXLarge),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Selamat Datang!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.primary,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.11,
              letterSpacing: -0.90,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: const Text(
            'Silakan daftar untuk melanjutkan\nperjalanan kesehatan paru Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.63,
            ),
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// REGISTER CARD
// ====================================================================
class _RegisterCard extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final TextEditingController birthDateController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  const _RegisterCard({
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.birthDateController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onPickDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: ShapeDecoration(
        color: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
        shadows: const [
          BoxShadow(color: AppColors.shadowPink, blurRadius: 100, offset: Offset(0, 40)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthFieldLabel(label: 'NAMA LENGKAP'),
          const SizedBox(height: 8),
          TextFormField(
            controller: fullNameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.inputText,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
              if (v.trim().length < 2) return 'Nama minimal 2 karakter';
              return null;
            },
            decoration: authInputDecoration(hint: 'Nama Lengkap', icon: Icons.person_outline),
          ),
          const SizedBox(height: 24),

          const AuthFieldLabel(label: 'EMAIL'),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.inputText,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) return 'Format email tidak valid';
              return null;
            },
            decoration: authInputDecoration(hint: 'nama@email.com', icon: Icons.mail_outline),
          ),
          const SizedBox(height: 24),

          const AuthFieldLabel(label: 'KATA SANDI'),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.inputText,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
              if (v.length < 6) return 'Kata sandi minimal 6 karakter';
              return null;
            },
            decoration: authInputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
              suffix: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textIcon,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const AuthFieldLabel(label: 'NO. TELEPON (OPSIONAL)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.inputText,
            decoration: authInputDecoration(hint: '08xxxxxxxx', icon: Icons.phone_outlined),
          ),
          const SizedBox(height: 24),

          const AuthFieldLabel(label: 'TANGGAL LAHIR (OPSIONAL)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: birthDateController,
            readOnly: true,
            onTap: onPickDate,
            style: AppTextStyles.inputText,
            decoration: authInputDecoration(
              hint: 'DD/MM/YYYY',
              icon: Icons.calendar_today_outlined,
              suffix: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.textIcon, size: 24),
                  onPressed: onPickDate,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          AuthPrimaryButton(label: 'Daftar', isLoading: isLoading, onPressed: onSubmit),
          const SizedBox(height: 40),
          const AuthDividerWithText(label: 'ATAU DAFTAR DENGAN'),
          const SizedBox(height: 40),
          const AuthSocialButton(),
        ],
      ),
    );
  }
}

// ====================================================================
// FOOTER
// ====================================================================
class _RegisterFooter extends StatelessWidget {
  final bool isLoading;
  const _RegisterFooter({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () => context.go(AppRoutes.login),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sudah punya akun? ',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
          Text(
            'Masuk',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: isLoading ? AppColors.textHint : AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }
}
