import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/router/app_routes.dart';
import '../features/auth/presentation/auth_notifier.dart';
import '../features/auth/presentation/auth_widgets.dart';

/// Login screen — terhubung ke AuthNotifier via Riverpod.
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
                    SizedBox(height: availHeight * 0.07),
                    const _LoginHeader(),
                    SizedBox(height: availHeight * 0.03),
                    _LoginCard(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      isLoading: isLoading,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onSubmit: _submit,
                    ),
                    SizedBox(height: availHeight * 0.04),
                    _LoginFooter(isLoading: isLoading),
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
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/LogoParuKuat.png',
                width: 250,
                height: 250,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.health_and_safety,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Selamat Datang\nKembali',
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
            'Silakan masuk untuk melanjutkan\nperjalanan kesehatan paru Anda.',
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
            textInputAction: TextInputAction.done,
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
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Lupa Kata Sandi?',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.textLink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(label: 'Masuk', isLoading: isLoading, onPressed: onSubmit),
        ]
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
