import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum UrgencyLevel { none, low, medium, high, critical }

class UrgencyBanner extends StatelessWidget {
  final UrgencyLevel level;
  final String message;
  final VoidCallback? onDismiss;

  const UrgencyBanner({
    super.key,
    required this.level,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (level == UrgencyLevel.none) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final config = _configs[level]!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(children: [
        level == UrgencyLevel.critical
            ? Icon(config.icon, color: config.color, size: 20)
                .animate(onPlay: (c) => c.repeat())
                .scaleXY(end: 1.2, duration: 500.ms)
                .then()
                .scaleXY(end: 1.0, duration: 500.ms)
            : Icon(config.icon, color: config.color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(config.label,
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: config.color,
                    letterSpacing: 0.8)),
            Text(message, style: GoogleFonts.dmSans(fontSize: 13, color: txt)),
          ]),
        ),
        if (onDismiss != null)
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, color: config.color, size: 16),
          ),
      ]),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3, end: 0);
  }

  static const _configs = {
    UrgencyLevel.low: _UrgencyConfig(
        color: Color(0xFF4DA8FF), icon: Icons.info_outline, label: 'NOTE'),
    UrgencyLevel.medium: _UrgencyConfig(
        color: Color(0xFFFFB347),
        icon: Icons.warning_amber_outlined,
        label: 'ATTENTION'),
    UrgencyLevel.high: _UrgencyConfig(
        color: Color(0xFFFF7043), icon: Icons.priority_high, label: 'URGENT'),
    UrgencyLevel.critical: _UrgencyConfig(
        color: Color(0xFFFF5C7A),
        icon: Icons.emergency,
        label: '🚨 CRITICAL — CALL EMERGENCY SERVICES'),
  };
}

class _UrgencyConfig {
  final Color color;
  final IconData icon;
  final String label;
  const _UrgencyConfig(
      {required this.color, required this.icon, required this.label});
}
