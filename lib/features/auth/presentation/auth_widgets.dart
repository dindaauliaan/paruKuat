import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

// ====================================================================
// Shared auth UI widgets — dipakai oleh login_page dan register_page.
// Dipisah ke file ini karena private class (_X) tidak bisa di-export.
// ====================================================================

// ====================================================================
// FIELD LABEL — uppercase kecil di atas input
// ====================================================================
class AuthFieldLabel extends StatelessWidget {
  final String label;
  const AuthFieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label, style: AppTextStyles.labelSmall),
    );
  }
}

// ====================================================================
// INPUT DECORATION — shared style semua TextFormField auth
// ====================================================================
InputDecoration authInputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.inputHint,
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 16, right: 12),
      child: Icon(icon, color: AppColors.textIcon, size: 20),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9999),
      borderSide: BorderSide.none,
    ),
    errorStyle: const TextStyle(
      fontFamily: 'Manrope',
      fontSize: 12,
      color: AppColors.primary,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9999),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9999),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}

// ====================================================================
// DIVIDER LINE
// ====================================================================
class AuthDividerLine extends StatelessWidget {
  const AuthDividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
    );
  }
}

// ====================================================================
// DIVIDER WITH TEXT — "ATAU MASUK DENGAN" / "ATAU DAFTAR DENGAN"
// ====================================================================
class AuthDividerWithText extends StatelessWidget {
  final String label;
  const AuthDividerWithText({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: AuthDividerLine()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(label, style: AppTextStyles.labelDivider),
        ),
        const Expanded(child: AuthDividerLine()),
      ],
    );
  }
}

// ====================================================================
// PRIMARY AUTH BUTTON — gradient, loading state
// ====================================================================
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ShapeDecoration(
          gradient: isLoading
              ? const LinearGradient(
                  colors: [Color(0xFFE8A0B0), Color(0xFFC47090)],
                )
              : AppColors.primaryButtonGradient,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: AppTextStyles.buttonPrimary),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}
