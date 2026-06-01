import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/router/app_routes.dart';
import '../features/auth/presentation/auth_notifier.dart';
import '../features/auth/presentation/auth_widgets.dart';

/// Login screen â€” terhubung ke AuthNotifier via Riverpod.
class LoginParukuat extends ConsumerStatefulWidget {
  const LoginParukuat({super.key});

  @override
  ConsumerState<LoginParukuat> createState() => _LoginParukuatState();
}

class _LoginParukuatState extends ConsumerState<LoginParukuat> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
            padding: EdgeInsets.only(bottom: bottomInset + 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    const _LoginHeader(),
                    const SizedBox(height: 32),
                    _LoginCard(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      isLoading: isLoading,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: 24),
                    _LoginFooter(isLoading: isLoading),
                    const SizedBox(height: 32),
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
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo ParuKuat
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/LogoParuKuat.png',
                width: 64,
                height: 64,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.health_and_safety,
                  color: AppColors.primary,
                  size: 56,
                ),
              ),
              const SizedBox(width: 10),
              const Text('ParuKuat', style: AppTextStyles.brandXLarge),
            ],
          ),
        ),
        // Selamat Datang Kembali
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Selamat Datang\nKembali',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayLarge,
          ),
        ),
        // Subtitle
        Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: const Text(
              'Silakan masuk untuk melanjutkan\nperjalanan kesehatan paru Anda.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMediumWeight,
            ),
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// LOGIN CARD
// ====================================================================
class _LoginCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: ShapeDecoration(
        color: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
        shadows: const [
          BoxShadow(color: AppColors.shadowPink, blurRadius: 60, offset: Offset(0, 30)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthFieldLabel(label: 'EMAIL'),
          const SizedBox(height: 6),
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
          const SizedBox(height: 12),
          const AuthFieldLabel(label: 'KATA SANDI'),
          const SizedBox(height: 6),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.inputText,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
              if (v.length < 6) return 'Kata sandi minimal 6 karakter';
              return null;
            },
            decoration: authInputDecoration(
              hint: '',
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
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Lupa Kata Sandi?',
              style: AppTextStyles.captionBold,
            ),
          ),
          const SizedBox(height: 16),

          
          AuthPrimaryButton(label: 'Masuk', isLoading: isLoading, onPressed: onSubmit),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ====================================================================
// FOOTER
// ====================================================================
class _LoginFooter extends StatelessWidget {
  final bool isLoading;
  const _LoginFooter({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () => context.go(AppRoutes.register),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Belum punya akun? ',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
          Text(
            'Daftar',
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
