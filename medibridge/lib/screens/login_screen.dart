import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _signInKey = GlobalKey<FormState>();
  final _signUpKey = GlobalKey<FormState>();

  final _emailSignIn = TextEditingController();
  final _passSignIn = TextEditingController();
  final _nameSignUp = TextEditingController();
  final _emailSignUp = TextEditingController();
  final _passSignUp = TextEditingController();
  final _passConfirm = TextEditingController();

  bool _obscureSignIn = true;
  bool _obscureSignUp = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailSignIn.dispose();
    _passSignIn.dispose();
    _nameSignUp.dispose();
    _emailSignUp.dispose();
    _passSignUp.dispose();
    _passConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          _GridBg(isDark: isDark),
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  isDark ? AppTheme.accentGlow : AppTheme.lAccentGlow,
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  _LogoHeader(isDark: isDark)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.15, end: 0),
                  const SizedBox(height: 36),
                  _AuthCard(
                    isDark: isDark,
                    tabs: _tabs,
                    child: Column(
                      children: [
                        _TabBar(tabs: _tabs, isDark: isDark),
                        const SizedBox(height: 24),
                        if (auth.error != null)
                          _ErrorBanner(
                            message: auth.error!,
                            isDark: isDark,
                            onClose: () =>
                                context.read<AuthProvider>().clearError(),
                          ).animate().fadeIn(duration: 250.ms),
                        if (auth.error != null) const SizedBox(height: 12),
                        if (_tabs.index == 0)
                          _SignInForm(
                            formKey: _signInKey,
                            emailCtrl: _emailSignIn,
                            passCtrl: _passSignIn,
                            obscure: _obscureSignIn,
                            onToggleObscure: () => setState(
                                () => _obscureSignIn = !_obscureSignIn),
                            isDark: isDark,
                          ).animate().fadeIn(duration: 300.ms)
                        else
                          _SignUpForm(
                            formKey: _signUpKey,
                            nameCtrl: _nameSignUp,
                            emailCtrl: _emailSignUp,
                            passCtrl: _passSignUp,
                            confirmCtrl: _passConfirm,
                            obscurePass: _obscureSignUp,
                            obscureConfirm: _obscureConfirm,
                            onTogglePass: () => setState(
                                () => _obscureSignUp = !_obscureSignUp),
                            onToggleConfirm: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            isDark: isDark,
                          ).animate().fadeIn(duration: 300.ms),
                        const SizedBox(height: 20),
                        _PrimaryButton(
                          label:
                              _tabs.index == 0 ? 'Sign In' : 'Create Account',
                          loading: auth.isLoading,
                          isDark: isDark,
                          onTap: _tabs.index == 0
                              ? () => _handleSignIn(context)
                              : () => _handleSignUp(context),
                        ),
                        if (_tabs.index == 0) ...[
                          const SizedBox(height: 16),
                          _ForgotPassword(
                              isDark: isDark,
                              onTap: () => _handleForgot(context)),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
                  const SizedBox(height: 32),
                  Text(
                    'Your data is encrypted and stored securely.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    if (!(_signInKey.currentState?.validate() ?? false)) return;
    await context.read<AuthProvider>().signIn(
          email: _emailSignIn.text.trim(),
          password: _passSignIn.text,
        );
  }

  Future<void> _handleSignUp(BuildContext context) async {
    if (!(_signUpKey.currentState?.validate() ?? false)) return;
    await context.read<AuthProvider>().signUp(
          email: _emailSignUp.text.trim(),
          password: _passSignUp.text,
          fullName: _nameSignUp.text.trim(),
        );
  }

  Future<void> _handleForgot(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset Password',
                style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary)),
            const SizedBox(height: 8),
            Text(
              'Contact your administrator or use the Change Password option in Settings.',
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color:
                      isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LogoHeader extends StatelessWidget {
  final bool isDark;
  const _LogoHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final accG = isDark ? AppTheme.accentGlow : AppTheme.lAccentGlow;
    final txtP = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final txtS = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('MediBridge',
            style: GoogleFonts.dmSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: txtP,
                letterSpacing: -0.5)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
              color: accG, borderRadius: BorderRadius.circular(5)),
          child: Text('AI',
              style: GoogleFonts.dmSans(
                  fontSize: 11, fontWeight: FontWeight.w700, color: acc)),
        ),
      ]),
      const SizedBox(height: 6),
      Text('Medical Interpreter',
          style: GoogleFonts.dmSans(fontSize: 14, color: txtS)),
    ]);
  }
}

class _AuthCard extends StatelessWidget {
  final bool isDark;
  final TabController tabs;
  final Widget child;
  const _AuthCard(
      {required this.isDark, required this.tabs, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? AppTheme.divider : AppTheme.lDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController tabs;
  final bool isDark;
  const _TabBar({required this.tabs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final surf = isDark ? AppTheme.bgSurface : AppTheme.lBgSurface;
    final txtM = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        _Tab(
            label: 'Sign In',
            isActive: tabs.index == 0,
            acc: acc,
            txtM: txtM,
            onTap: () => tabs.animateTo(0)),
        _Tab(
            label: 'Sign Up',
            isActive: tabs.index == 1,
            acc: acc,
            txtM: txtM,
            onTap: () => tabs.animateTo(1)),
      ]),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color acc;
  final Color txtM;
  final VoidCallback onTap;
  const _Tab(
      {required this.label,
      required this.isActive,
      required this.acc,
      required this.txtM,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? acc.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive ? Border.all(color: acc.withOpacity(0.35)) : null,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? acc : txtM)),
        ),
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool isDark;

  const _SignInForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(children: [
        _InputField(
          controller: emailCtrl,
          label: 'Email',
          hint: 'your@email.com',
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your email';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _InputField(
          controller: passCtrl,
          label: 'Password',
          hint: '••••••••',
          obscure: obscure,
          isDark: isDark,
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                size: 18,
                color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted),
            onPressed: onToggleObscure,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter your password';
            return null;
          },
        ),
      ]),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool obscurePass;
  final bool obscureConfirm;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;
  final bool isDark;

  const _SignUpForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.obscurePass,
    required this.obscureConfirm,
    required this.onTogglePass,
    required this.onToggleConfirm,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(children: [
        _InputField(
          controller: nameCtrl,
          label: 'Full Name',
          hint: 'Dr. Jane Smith',
          isDark: isDark,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your name';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _InputField(
          controller: emailCtrl,
          label: 'Email',
          hint: 'your@email.com',
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your email';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _InputField(
          controller: passCtrl,
          label: 'Password',
          hint: 'Min. 8 characters',
          obscure: obscurePass,
          isDark: isDark,
          suffixIcon: IconButton(
            icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility,
                size: 18,
                color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted),
            onPressed: onTogglePass,
          ),
          validator: (v) {
            if (v == null || v.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        _InputField(
          controller: confirmCtrl,
          label: 'Confirm Password',
          hint: '••••••••',
          obscure: obscureConfirm,
          isDark: isDark,
          suffixIcon: IconButton(
            icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility,
                size: 18,
                color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted),
            onPressed: onToggleConfirm,
          ),
          validator: (v) {
            if (v != passCtrl.text) return 'Passwords do not match';
            return null;
          },
        ),
      ]),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool isDark;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final surf = isDark ? AppTheme.bgSurface : AppTheme.lBgSurface;
    final div = isDark ? AppTheme.divider : AppTheme.lDivider;
    final txtP = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final txtM = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: txtM,
              letterSpacing: 0.4)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.dmSans(fontSize: 14, color: txtP),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(fontSize: 14, color: txtM),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: surf,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: div),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: div),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: acc, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: isDark ? AppTheme.errorColor : AppTheme.lErrorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: isDark ? AppTheme.errorColor : AppTheme.lErrorColor,
                width: 1.5),
          ),
        ),
      ),
    ]);
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final bool isDark;
  final VoidCallback onTap;
  const _PrimaryButton(
      {required this.label,
      required this.loading,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final fg = isDark ? AppTheme.bgDeep : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: acc,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: fg))
                  : Text(label,
                      style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: fg)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPassword extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _ForgotPassword({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text('Forgot password?',
            style: GoogleFonts.dmSans(
                fontSize: 13, color: acc, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onClose;
  const _ErrorBanner(
      {required this.message, required this.isDark, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final err = isDark ? AppTheme.errorColor : AppTheme.lErrorColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: err.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: err.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.error_outline, color: err, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style: GoogleFonts.dmSans(fontSize: 13, color: err))),
        GestureDetector(
            onTap: onClose, child: Icon(Icons.close, color: err, size: 14)),
      ]),
    );
  }
}

class _GridBg extends StatelessWidget {
  final bool isDark;
  const _GridBg({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter:
          _GridPainter(color: isDark ? AppTheme.divider : AppTheme.lDivider),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 0.5;
    const s = 40.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
