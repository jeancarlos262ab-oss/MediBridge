import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/auth_provider.dart';
import '../services/consultation_provider.dart';
import '../services/settings_provider.dart';
import '../theme/app_theme.dart';
import 'consultation_screen.dart';
import 'emergency_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsultationProvider>();
    final settings = context.watch<SettingsProvider>();
    final str = settings.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _GridBackground(),
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 400,
              height: 400,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 28),
                    // ── Logo row with profile button ──────────────────────
                    Row(
                      children: [
                        // SizedBox del mismo ancho que el botón de perfil (36px)
                        // para que el logo quede matemáticamente centrado
                        const SizedBox(width: 36),
                        const Spacer(),
                        _Logo()
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: -0.2, end: 0),
                        const Spacer(),
                        _ProfileButton(isDark: isDark)
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 400.ms),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      str.medicalInterpreter,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 28,
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.lTextPrimary,
                        height: 1.15,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
                    const SizedBox(height: 6),
                    Text(
                      str.realtimeSubtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.lTextSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 250.ms, duration: 500.ms),
                    const SizedBox(height: 24),
                    _LanguageConfigCard(provider: provider, isDark: isDark)
                        .animate()
                        .fadeIn(delay: 350.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 28),
                    _MenuButton(
                      icon: Icons.mic,
                      label: str.startConsultation,
                      subtitle: str.liveSession,
                      isPrimary: true,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ConsultationScreen())),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 28),
                    Row(children: [
                      Expanded(
                        child: _MenuButton(
                          icon: Icons.history,
                          label: str.history,
                          subtitle: str.pastSessions,
                          isPrimary: false,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HistoryScreen())),
                        )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuButton(
                          icon: Icons.settings_outlined,
                          label: str.settings,
                          subtitle: str.preferences,
                          isPrimary: false,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen())),
                        )
                            .animate()
                            .fadeIn(delay: 650.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: _MenuButton(
                          icon: Icons.emergency_outlined,
                          label: str.emergency,
                          subtitle: str.quickPhrases,
                          isPrimary: false,
                          accentColor: AppTheme.errorColor,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EmergencyScreen())),
                        )
                            .animate()
                            .fadeIn(delay: 700.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuButton(
                          icon: Icons.help_outline,
                          label: str.about,
                          subtitle: str.howItWorks,
                          isPrimary: false,
                          onTap: () => _showAbout(context, str, isDark),
                        )
                            .animate()
                            .fadeIn(delay: 750.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // ── "Powered by" fixed at the very bottom ──────────────────
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Consumer<SettingsProvider>(
              builder: (_, s, __) {
                final isDarkLocal =
                    Theme.of(context).brightness == Brightness.dark;
                return Text(
                  'Powered by Gemini 2.5 Flash',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color:
                        isDarkLocal ? AppTheme.textMuted : AppTheme.lTextMuted,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 800.ms);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context, AppStrings str, bool isDark) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final accG = isDark ? AppTheme.accentGlow : AppTheme.lAccentGlow;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(str.aboutTitle,
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 22,
                    color:
                        isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary)),
            const SizedBox(height: 12),
            Text(
              str.aboutBody,
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color:
                      isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary,
                  height: 1.6),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accG,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: acc.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: acc, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(str.aboutBadge,
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: acc,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Profile button with logout menu ────────────────────────────────────────

class _ProfileButton extends StatelessWidget {
  final bool isDark;
  const _ProfileButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final accG = isDark ? AppTheme.accentGlow : AppTheme.lAccentGlow;
    final card = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.divider : AppTheme.lDivider;
    final txt = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final sub = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;
    final muted = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;
    final err = isDark ? AppTheme.errorColor : AppTheme.lErrorColor;

    // Get user info from AuthProvider if available
    final auth = context.watch<AuthProvider>();
    final userEmail = auth.userEmail ?? '';
    final userName = auth.displayName?.isNotEmpty == true
        ? auth.displayName!
        : userEmail.split('@').first;

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      color: card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      elevation: 8,
      onSelected: (value) async {
        if (value == 'signout') {
          final confirmed = await _confirmSignOut(context, isDark);
          if (confirmed && context.mounted) {
            await context.read<AuthProvider>().signOut();
          }
        } else if (value == 'settings') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }
      },
      itemBuilder: (_) => [
        // ── User info header ──────────────────────────────────────────
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: acc.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: acc.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: acc,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: txt,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (userEmail.isNotEmpty)
                      Text(
                        userEmail,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: muted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(height: 1, color: border),
        ),
        // ── Settings shortcut ─────────────────────────────────────────
        PopupMenuItem<String>(
          value: 'settings',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.settings_outlined, color: sub, size: 16),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: txt,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(height: 1, color: border),
        ),
        // ── Sign out ──────────────────────────────────────────────────
        PopupMenuItem<String>(
          value: 'signout',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: err, size: 16),
              const SizedBox(width: 12),
              Text(
                'Sign Out',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: err,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: acc.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: acc.withOpacity(0.3)),
        ),
        child: Center(
          child: userName.isNotEmpty
              ? Text(
                  userName[0].toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: acc,
                  ),
                )
              : Icon(Icons.person_outline, color: acc, size: 18),
        ),
      ),
    );
  }

  Future<bool> _confirmSignOut(BuildContext context, bool isDark) async {
    final txt = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final sub = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;
    final card = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final err = isDark ? AppTheme.errorColor : AppTheme.lErrorColor;

    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: card,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Sign Out',
              style: GoogleFonts.dmSans(
                  fontSize: 17, fontWeight: FontWeight.w700, color: txt),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: GoogleFonts.dmSans(fontSize: 14, color: sub),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: sub, fontWeight: FontWeight.w500)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Sign Out',
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: err, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ── Logo ────────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final accG = isDark ? AppTheme.accentGlow : AppTheme.lAccentGlow;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('MediBridge',
            style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary,
                letterSpacing: -0.5)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: accG, borderRadius: BorderRadius.circular(4)),
          child: Text('AI',
              style: GoogleFonts.dmSans(
                  fontSize: 10, fontWeight: FontWeight.w700, color: acc)),
        ),
      ],
    );
  }
}

// ── Language config card ────────────────────────────────────────────────────

class _LanguageConfigCard extends StatelessWidget {
  final ConsultationProvider provider;
  final bool isDark;
  const _LanguageConfigCard({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final str = context.read<SettingsProvider>().strings;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? AppTheme.divider : AppTheme.lDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(str.languageSetup,
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _LangPicker(
                role: 'Dr.',
                color: isDark ? AppTheme.doctorColor : AppTheme.lDoctorColor,
                selected: provider.doctorLanguage,
                onChanged: provider.setDoctorLanguage,
                isDark: isDark,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.bgSurface : AppTheme.lBgSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppTheme.divider : AppTheme.lDivider,
                  ),
                ),
                child: Icon(Icons.swap_horiz,
                    color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
                    size: 16),
              ),
            ),
            Expanded(
              child: _LangPicker(
                role: 'Pt.',
                color: isDark ? AppTheme.patientColor : AppTheme.lPatientColor,
                selected: provider.patientLanguage,
                onChanged: provider.setPatientLanguage,
                isDark: isDark,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Language picker ─────────────────────────────────────────────────────────

class _LangPicker extends StatelessWidget {
  final String role;
  final Color color;
  final Language selected;
  final Function(Language) onChanged;
  final bool isDark;
  const _LangPicker({
    required this.role,
    required this.color,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(role,
            style: GoogleFonts.dmSans(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: DropdownButton<Language>(
            value: selected,
            isExpanded: true,
            dropdownColor: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
            underline: const SizedBox(),
            isDense: true,
            style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary),
            icon: Icon(Icons.keyboard_arrow_down, color: color, size: 16),
            items: LanguageList.supported
                .map((l) => DropdownMenuItem(
                    value: l, child: Text('${l.flag} ${l.name}')))
                .toList(),
            onChanged: (l) {
              if (l != null) onChanged(l);
            },
          ),
        ),
      ],
    );
  }
}

// ── Menu button ─────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;
  final Color? accentColor;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final iconColor = accentColor ??
        (isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary);
    final cardColor = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final borderColor = accentColor?.withOpacity(0.3) ??
        (isDark ? AppTheme.divider : AppTheme.lDivider);
    final primaryFg = isDark ? AppTheme.bgDeep : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
            horizontal: isPrimary ? 20 : 16, vertical: isPrimary ? 18 : 14),
        decoration: BoxDecoration(
          color: isPrimary ? acc : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isPrimary ? acc : borderColor),
        ),
        child: isPrimary
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: primaryFg, size: 22),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: primaryFg)),
                      Text(subtitle,
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: primaryFg.withOpacity(0.7))),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(height: 8),
                  Text(label,
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentColor ??
                              (isDark
                                  ? AppTheme.textPrimary
                                  : AppTheme.lTextPrimary))),
                  Text(subtitle,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.textMuted
                              : AppTheme.lTextMuted)),
                ],
              ),
      ),
    );
  }
}

// ── Grid background ─────────────────────────────────────────────────────────

class _GridBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _GridPainter(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.divider
            : AppTheme.lDivider,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
