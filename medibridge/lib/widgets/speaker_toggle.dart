import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SpeakerToggle extends StatelessWidget {
  final SpeakerRole activeSpeaker;
  final Function(SpeakerRole) onChanged;
  final Language doctorLanguage;
  final Language patientLanguage;

  const SpeakerToggle({
    super.key,
    required this.activeSpeaker,
    required this.onChanged,
    required this.doctorLanguage,
    required this.patientLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf = isDark ? AppTheme.bgSurface : AppTheme.lBgSurface;
    final border = isDark ? AppTheme.divider : AppTheme.lDivider;
    final docColor = isDark ? AppTheme.doctorColor : AppTheme.lDoctorColor;
    final patColor = isDark ? AppTheme.patientColor : AppTheme.lPatientColor;
    final muted = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        _ToggleOption(
          label: 'Doctor',
          sublabel: doctorLanguage.flag,
          isActive: activeSpeaker == SpeakerRole.doctor,
          color: docColor,
          muted: muted,
          onTap: () => onChanged(SpeakerRole.doctor),
        ),
        _ToggleOption(
          label: 'Patient',
          sublabel: patientLanguage.flag,
          isActive: activeSpeaker == SpeakerRole.patient,
          color: patColor,
          muted: muted,
          onTap: () => onChanged(SpeakerRole.patient),
        ),
      ]),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isActive;
  final Color color;
  final Color muted;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.sublabel,
    required this.isActive,
    required this.color,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive ? Border.all(color: color.withOpacity(0.4)) : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(sublabel, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? color : muted)),
          ]),
        ),
      ),
    );
  }
}
