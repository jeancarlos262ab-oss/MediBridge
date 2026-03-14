import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/consultation_provider.dart';
import '../services/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/mic_button.dart';
import '../widgets/urgency_banner.dart';
import 'emergency_screen.dart';
import '../widgets/speaker_toggle.dart';
import 'summary_screen.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Theme helpers ──────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _acc => _isDark ? AppTheme.accent : AppTheme.lAccent;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsultationProvider>(
      builder: (context, provider, _) {
        if (provider.hasMessages) _scrollToBottom();

        return Scaffold(
          appBar: _buildAppBar(context, provider),
          body: Column(
            children: [
              _LanguageStrip(provider: provider),
              Expanded(
                child: provider.messages.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: provider.messages.length +
                            (provider.partialText.isNotEmpty ? 1 : 0),
                        itemBuilder: (ctx, i) {
                          if (i == provider.messages.length) {
                            return _PartialTextBubble(
                              text: provider.partialText,
                              speaker: provider.activeSpeaker,
                            );
                          }
                          return MessageBubble(
                            message: provider.messages[i],
                            doctorLanguage: provider.doctorLanguage,
                            patientLanguage: provider.patientLanguage,
                            onSpeak: () =>
                                provider.speakMessage(provider.messages[i]),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.15, end: 0);
                        },
                      ),
              ),
              if (provider.detectedSymptoms.isNotEmpty)
                _SymptomsStrip(symptoms: provider.detectedSymptoms),
              if (provider.urgencyLevel != UrgencyLevel.none)
                UrgencyBanner(
                  level: provider.urgencyLevel,
                  message: provider.urgencyMessage,
                  onDismiss: provider.dismissUrgency,
                ),
              if (provider.error != null)
                _ErrorBanner(message: provider.error!),
              _BottomControls(provider: provider),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, ConsultationProvider provider) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: provider.isListening ? _acc : Theme.of(context).dividerColor,
            boxShadow: provider.isListening
                ? [BoxShadow(color: _acc.withOpacity(0.6), blurRadius: 8)]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          provider.isListening
              ? context.watch<SettingsProvider>().strings.listening
              : context.watch<SettingsProvider>().strings.consultation,
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ]),
      actions: [
        IconButton(
          icon: Icon(Icons.emergency,
              color: _isDark ? AppTheme.errorColor : AppTheme.lErrorColor),
          tooltip: 'Emergency Phrases',
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const EmergencyScreen())),
        ),
        if (provider.hasMessages)
          TextButton.icon(
            onPressed: provider.summaryLoading
                ? null
                : () async {
                    await provider.generateSummary();
                    if (context.mounted && provider.summary != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SummaryScreen(
                              summary: provider.summary!,
                              patientLanguage: provider.patientLanguage),
                        ),
                      );
                    }
                  },
            icon: provider.summaryLoading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: _acc))
                : Icon(Icons.summarize_outlined, size: 16, color: _acc),
            label: Text(context.watch<SettingsProvider>().strings.summary,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: _acc, fontWeight: FontWeight.w600)),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ── Language strip ─────────────────────────────────────────────────────────

class _LanguageStrip extends StatelessWidget {
  final ConsultationProvider provider;
  const _LanguageStrip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
        border: Border(
            bottom: BorderSide(
                color: isDark ? AppTheme.divider : AppTheme.lDivider)),
      ),
      child: Row(children: [
        _LangChip(
            language: provider.doctorLanguage,
            color: isDark ? AppTheme.doctorColor : AppTheme.lDoctorColor),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.compare_arrows,
              color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
              size: 18),
        ),
        _LangChip(
            language: provider.patientLanguage,
            color: isDark ? AppTheme.patientColor : AppTheme.lPatientColor),
        const Spacer(),
        GestureDetector(
          onTap: () => provider.clearSession(),
          child: Consumer<SettingsProvider>(
            builder: (_, s, __) => Text(
              s.uiLanguage == 'es'
                  ? 'Limpiar'
                  : s.uiLanguage == 'pt'
                      ? 'Limpar'
                      : s.uiLanguage == 'fr'
                          ? 'Effacer'
                          : s.uiLanguage == 'de'
                              ? 'Löschen'
                              : 'Clear',
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ]),
    );
  }
}

class _LangChip extends StatelessWidget {
  final Language language;
  final Color color;
  const _LangChip({required this.language, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text('${language.flag} ${language.name}',
          style: GoogleFonts.dmSans(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Bottom controls ────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final ConsultationProvider provider;
  const _BottomControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
        border: Border(
            top: BorderSide(
                color: isDark ? AppTheme.divider : AppTheme.lDivider)),
      ),
      child: Column(children: [
        SpeakerToggle(
          activeSpeaker: provider.activeSpeaker,
          onChanged: provider.setActiveSpeaker,
          doctorLanguage: provider.doctorLanguage,
          patientLanguage: provider.patientLanguage,
        ),
        const SizedBox(height: 20),
        MicButton(
          isListening: provider.isListening,
          isTranslating: provider.state == ConsultationState.translating,
          activeSpeaker: provider.activeSpeaker,
          // Increments on every new word → triggers the flash animation
          wordCount: provider.partialText.trim().isEmpty
              ? 0
              : provider.partialText.trim().split(RegExp(r'\s+')).length,
          onTap: () {
            if (provider.isListening) {
              provider.stopListening();
            } else {
              provider.startListening();
            }
          },
        ),
      ]),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final accG = isDark ? AppTheme.accentGlow : AppTheme.lAccentGlow;
    final txt = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final sub = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: accG, shape: BoxShape.circle),
            child: Icon(Icons.mic_none, color: acc, size: 40),
          ),
          const SizedBox(height: 20),
          Text(context.watch<SettingsProvider>().strings.readyToInterpret,
              style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: txt)),
          const SizedBox(height: 8),
          Text(context.watch<SettingsProvider>().strings.selectSpeaker,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: sub)),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

// ── Partial text bubble ────────────────────────────────────────────────────

class _PartialTextBubble extends StatelessWidget {
  final String text;
  final SpeakerRole speaker;
  const _PartialTextBubble({required this.text, required this.speaker});

  @override
  Widget build(BuildContext context) {
    final isDoctor = speaker == SpeakerRole.doctor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf = isDark ? AppTheme.bgSurface : AppTheme.lBgSurface;
    final borderC = isDark
        ? (isDoctor ? AppTheme.doctorColor : AppTheme.patientColor)
        : (isDoctor ? AppTheme.lDoctorColor : AppTheme.lPatientColor);
    final sub = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderC.withOpacity(0.3)),
          ),
          child: Text(
            text.isEmpty ? '...' : text,
            style: GoogleFonts.dmSans(
                fontSize: 14, color: sub, fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }
}

// ── Symptoms strip ─────────────────────────────────────────────────────────

class _SymptomsStrip extends StatelessWidget {
  final List<String> symptoms;
  const _SymptomsStrip({required this.symptoms});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
        border: Border(
            top: BorderSide(
                color: isDark ? AppTheme.divider : AppTheme.lDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.monitor_heart_outlined,
                color: AppTheme.warningColor, size: 13),
            const SizedBox(width: 5),
            Text('DETECTED SYMPTOMS',
                style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warningColor,
                    letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: symptoms
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppTheme.warningColor.withOpacity(0.35)),
                      ),
                      child: Text(s,
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ── Error banner ───────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style:
                  GoogleFonts.dmSans(fontSize: 13, color: AppTheme.errorColor)),
        ),
      ]),
    );
  }
}
