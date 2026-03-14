import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Language doctorLanguage;
  final Language patientLanguage;
  final VoidCallback onSpeak;

  const MessageBubble({
    super.key,
    required this.message,
    required this.doctorLanguage,
    required this.patientLanguage,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDoctor = message.speaker == SpeakerRole.doctor;

    final speakerColor = isDoctor
        ? (isDark ? AppTheme.doctorColor : AppTheme.lDoctorColor)
        : (isDark ? AppTheme.patientColor : AppTheme.lPatientColor);
    final speakerLabel = isDoctor
        ? '🩺 ${doctorLanguage.name}'
        : '🧑‍⚕️ ${patientLanguage.name}';

    final surf = isDark ? AppTheme.bgSurface : AppTheme.lBgSurface;
    final txt = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final sub = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;
    final muted = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isDoctor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Speaker label
          Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 4, right: 4),
            child: Text(speakerLabel,
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: speakerColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3)),
          ),

          // Original bubble
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isDoctor ? 4 : 14),
                bottomRight: Radius.circular(isDoctor ? 14 : 4),
              ),
              border: Border.all(color: speakerColor.withOpacity(0.25)),
            ),
            child: Text(message.originalText,
                style:
                    GoogleFonts.dmSans(fontSize: 15, color: txt, height: 1.45)),
          ),

          const SizedBox(height: 4),

          // Translation bubble
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: speakerColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(color: speakerColor.withOpacity(0.15)),
            ),
            child: message.status == MessageStatus.translating
                ? _TranslatingIndicator(color: speakerColor, muted: muted)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(message.translatedText,
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: sub, height: 1.45)),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onSpeak,
                        child: Icon(Icons.volume_up_outlined,
                            size: 16, color: speakerColor.withOpacity(0.7)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TranslatingIndicator extends StatelessWidget {
  final Color color;
  final Color muted;
  const _TranslatingIndicator({required this.color, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
      ),
      const SizedBox(width: 8),
      Text('Translating...',
          style: GoogleFonts.dmSans(fontSize: 13, color: muted)),
    ]);
  }
}
