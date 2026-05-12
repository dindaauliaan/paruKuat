import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginParukuat extends StatelessWidget {
  const LoginParukuat({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availHeight = screenHeight - topPadding - bottomPadding;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFC7C7),
              Color(0xFFFFF2F2),
              Color(0xFFFFC7C7),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: availHeight * 0.07),
                  const _Header(),
                  SizedBox(height: availHeight * 0.03),
                  const _LoginCard(),
                  SizedBox(height: availHeight * 0.04),
                  const _Footer(),
                  SizedBox(height: availHeight * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// HEADER
// ==================================================================
class _Header extends StatelessWidget {
  const _Header();

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
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.health_and_safety, color: Color(0xFFCD2C58), size: 30),
              ),
              const SizedBox(width: 8),
              const Text(
                'ParuKuat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFCD2C58),
                  fontSize: 30,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  height: 1.20,
                  letterSpacing: -1.50,
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
              color: Color(0xFFCD2C58),
              fontSize: 36,
              fontFamily: 'Manrope',
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
              color: Color(0xFF3E4949),
              fontSize: 16,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              height: 1.63,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// LOGIN CARD
// ==================================================================
class _LoginCard extends StatelessWidget {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(48),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x1EFF8C8C),
            blurRadius: 100,
            offset: Offset(0, 40),
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _FormFields(),
          SizedBox(height: 40),
          _DividerWithText(),
          SizedBox(height: 40),
          _GoogleButton(),
        ],
      ),
    );
  }
}

// ==================================================================
// FORM FIELDS (Email, Password, Lupa Sandi, Tombol Masuk)
// ==================================================================
class _FormFields extends StatelessWidget {
  const _FormFields();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EmailField(),
        SizedBox(height: 24),
        _PasswordField(),
        SizedBox(height: 16),
        _ForgotPasswordLink(),
        SizedBox(height: 24),
        _LoginButton(),
      ],
    );
  }
}

// ==================================================================
// EMAIL FIELD
// ==================================================================
class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'EMAIL',
            style: TextStyle(
              color: Color(0xFF3E4949),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: 1.10,
            ),
          ),
        ),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'nama@email.com',
            hintStyle: const TextStyle(
              color: Color(0xFFBDC9C8),
              fontSize: 16,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 12),
              child: Icon(Icons.mail_outline, color: Color(0xFF8E9999), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9999),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF3E4949),
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// PASSWORD FIELD
// ==================================================================
class _PasswordField extends StatefulWidget {
  const _PasswordField();

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'KATA SANDI',
            style: TextStyle(
              color: Color(0xFF3E4949),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: 1.10,
            ),
          ),
        ),
        TextFormField(
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(
              color: Color(0xFFBDC9C8),
              fontSize: 16,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 12),
              child: Icon(Icons.lock_outline, color: Color(0xFF8E9999), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF8E9999),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9999),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF3E4949),
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// FORGOT PASSWORD LINK
// ==================================================================
class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Lupa Kata Sandi?',
        style: TextStyle(
          color: Color(0xFF8B4823),
          fontSize: 14,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          height: 1.43,
        ),
      ),
    );
  }
}

// ==================================================================
// LOGIN BUTTON — PINK GRADIENT
// ==================================================================
class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: HomeParukuat(),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.20, -0.91),
            end: Alignment(0.80, 1.91),
            colors: [Color(0xFFD43A64), Color(0xFF9E1B3D)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Masuk',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                height: 1.56,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// DIVIDER: "ATAU MASUK DENGAN"
// ==================================================================
class _DividerWithText extends StatelessWidget {
  const _DividerWithText();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: _DividerLine()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ATAU MASUK DENGAN',
            style: TextStyle(
              color: Color(0xFF6E7979),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: 1.10,
            ),
          ),
        ),
        Expanded(child: _DividerLine()),
      ],
    );
  }
}

// ==================================================================
// GOOGLE BUTTON
// ==================================================================
class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x33BDC9C8),
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
            width: 16,
            height: 16,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.g_mobiledata, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Google',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF181C1D),
              fontSize: 14,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// FOOTER
// ==================================================================
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF3E4949),
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
            height: 1.50,
          ),
        ),
        Text(
          'Daftar',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFCD2C58),
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            height: 1.50,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// REUSABLE HELPERS
// ==================================================================
class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Color(0x4CBDC9C8),
          ),
        ),
      ),
    );
  }
}
