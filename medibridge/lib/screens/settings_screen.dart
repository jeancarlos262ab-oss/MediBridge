import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _rate;
  late double _pitch;
  late double _volume;
  bool _testingVoice = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>();
    _rate = s.speechRate;
    _pitch = s.pitch;
    _volume = s.volume;
  }

  // ── helpers ──────────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? AppTheme.bgDeep : AppTheme.lBgDeep;
  Color get _card => _isDark ? AppTheme.bgCard : AppTheme.lBgCard;
  Color get _border => _isDark ? AppTheme.divider : AppTheme.lDivider;
  Color get _txt => _isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
  Color get _sub => _isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;
  Color get _muted => _isDark ? AppTheme.textMuted : AppTheme.lTextMuted;
  Color get _acc => _isDark ? AppTheme.accent : AppTheme.lAccent;
  Color get _accGlow => _isDark ? AppTheme.accentGlow : AppTheme.lAccentGlow;

  Future<void> _testVoice() async {
    if (_testingVoice) return;
    setState(() => _testingVoice = true);
    final s = context.read<SettingsProvider>();
    await TtsService.instance
        .applySettings(rate: _rate, pitch: _pitch, volume: _volume);
    await TtsService.instance.speak(
      text: s.strings.testPhrase,
      languageCode: s.currentUiLanguage.code == 'en'
          ? 'en-US'
          : '${s.currentUiLanguage.code}-${s.currentUiLanguage.code.toUpperCase()}',
    );
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => _testingVoice = false);
  }

  Future<void> _save() async {
    final s = context.read<SettingsProvider>();
    await s.setVoice(rate: _rate, pitch: _pitch, volume: _volume);
    await TtsService.instance
        .applySettings(rate: _rate, pitch: _pitch, volume: _volume);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.strings.settingsSaved,
            style: GoogleFonts.dmSans(
                color: _isDark ? AppTheme.bgDeep : Colors.white)),
        backgroundColor: _acc,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, s, __) {
      final str = s.strings;
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _isDark ? AppTheme.bgDeep : AppTheme.lBgCard,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 18, color: _sub),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(str.settingsTitle,
              style: GoogleFonts.dmSans(
                  fontSize: 17, fontWeight: FontWeight.w700, color: _txt)),
          actions: [
            TextButton(
              onPressed: _save,
              child: Text(str.saveSettings,
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: _acc, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // ── APPEARANCE ──────────────────────────────────────────────
            _SectionHeader(
                label: str.appearance,
                icon: Icons.palette_outlined,
                color: _acc),
            const SizedBox(height: 12),
            Row(children: [
              _ThemeChip(
                icon: Icons.dark_mode_outlined,
                label: str.darkMode,
                isSelected: s.themeMode == ThemeMode.dark,
                acc: _acc,
                accGlow: _accGlow,
                card: _card,
                border: _border,
                muted: _muted,
                onTap: () => s.setTheme(ThemeMode.dark),
              ),
              const SizedBox(width: 10),
              _ThemeChip(
                icon: Icons.light_mode_outlined,
                label: str.lightMode,
                isSelected: s.themeMode == ThemeMode.light,
                acc: _acc,
                accGlow: _accGlow,
                card: _card,
                border: _border,
                muted: _muted,
                onTap: () => s.setTheme(ThemeMode.light),
              ),
              const SizedBox(width: 10),
              _ThemeChip(
                icon: Icons.brightness_auto_outlined,
                label: str.systemDefault,
                isSelected: s.themeMode == ThemeMode.system,
                acc: _acc,
                accGlow: _accGlow,
                card: _card,
                border: _border,
                muted: _muted,
                onTap: () => s.setTheme(ThemeMode.system),
              ),
            ]).animate().fadeIn(delay: 60.ms),

            const SizedBox(height: 28),

            // ── APP LANGUAGE ─────────────────────────────────────────────
            _SectionHeader(
                label: str.appLanguage,
                icon: Icons.translate_outlined,
                color: _acc),
            const SizedBox(height: 4),
            Text(str.appLanguageSubtitle,
                    style: GoogleFonts.dmSans(fontSize: 12, color: _muted))
                .animate()
                .fadeIn(delay: 80.ms),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: kUiLanguages.length,
              itemBuilder: (_, i) {
                final lang = kUiLanguages[i];
                final isSelected = lang.code == s.uiLanguage;
                return GestureDetector(
                  onTap: () => s.setUiLanguage(lang.code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _acc.withOpacity(0.1) : _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? _acc.withOpacity(0.55) : _border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(lang.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? _acc : _txt,
                            ),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: _acc, size: 14),
                    ]),
                  ),
                );
              },
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 28),

            // ── VOICE SETTINGS ───────────────────────────────────────────
            _SectionHeader(
                label: str.voiceSettings,
                icon: Icons.record_voice_over_outlined,
                color: _acc),
            const SizedBox(height: 12),

            _VoiceSlider(
              label: str.speechRate,
              icon: Icons.speed_outlined,
              value: _rate,
              min: 0.3,
              max: 1.5,
              leftLabel: str.slow,
              rightLabel: str.fast,
              card: _card,
              border: _border,
              txt: _txt,
              muted: _muted,
              acc: _acc,
              onChanged: (v) => setState(() => _rate = v),
            ).animate().fadeIn(delay: 140.ms),
            const SizedBox(height: 12),

            _VoiceSlider(
              label: str.pitch,
              icon: Icons.graphic_eq_outlined,
              value: _pitch,
              min: 0.5,
              max: 2.0,
              leftLabel: str.low,
              rightLabel: str.high,
              card: _card,
              border: _border,
              txt: _txt,
              muted: _muted,
              acc: _acc,
              onChanged: (v) => setState(() => _pitch = v),
            ).animate().fadeIn(delay: 160.ms),
            const SizedBox(height: 12),

            _VoiceSlider(
              label: str.volume,
              icon: Icons.volume_up_outlined,
              value: _volume,
              min: 0.1,
              max: 1.0,
              leftLabel: str.low,
              rightLabel: str.high,
              card: _card,
              border: _border,
              txt: _txt,
              muted: _muted,
              acc: _acc,
              onChanged: (v) => setState(() => _volume = v),
            ).animate().fadeIn(delay: 180.ms),

            const SizedBox(height: 18),

            // Test voice
            GestureDetector(
              onTap: _testingVoice ? null : _testVoice,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _testingVoice ? _acc.withOpacity(0.08) : _accGlow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _acc.withOpacity(_testingVoice ? 0.3 : 0.55)),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (_testingVoice)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _acc),
                    )
                  else
                    Icon(Icons.play_circle_outline, color: _acc, size: 20),
                  const SizedBox(width: 10),
                  Text(str.testVoice,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _acc)),
                ]),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 32),

            // ── APP INFO ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.local_hospital_outlined,
                        color: _acc, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MediBridge AI',
                            style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _txt)),
                        Text('Version 1.0.0 · Frostbyte Hackathon 2026',
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: _muted)),
                      ]),
                ]),
                const SizedBox(height: 12),
                Divider(height: 1, color: _border),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.auto_awesome, color: _acc, size: 13),
                  const SizedBox(width: 6),
                  Text('Powered by Gemini 2.5 Flash',
                      style: GoogleFonts.dmSans(fontSize: 12, color: _sub)),
                ]),
              ]),
            ).animate().fadeIn(delay: 240.ms),
          ],
        ),
      );
    });
  }
}

// ── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SectionHeader(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 7),
      Text(label.toUpperCase(),
          style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.0)),
    ]);
  }
}

// ── Theme chip ─────────────────────────────────────────────────────────────

class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color acc, accGlow, card, border, muted;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.acc,
    required this.accGlow,
    required this.card,
    required this.border,
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? acc.withOpacity(0.1) : card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? acc.withOpacity(0.55) : border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(children: [
            Icon(icon, color: isSelected ? acc : muted, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? acc : muted)),
          ]),
        ),
      ),
    );
  }
}

// ── Voice slider ────────────────────────────────────────────────────────────

class _VoiceSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value, min, max;
  final String leftLabel, rightLabel;
  final Color card, border, txt, muted, acc;
  final ValueChanged<double> onChanged;

  const _VoiceSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.leftLabel,
    required this.rightLabel,
    required this.card,
    required this.border,
    required this.txt,
    required this.muted,
    required this.acc,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pct = ((value - min) / (max - min) * 100).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(children: [
        Row(children: [
          Icon(icon, color: acc, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: txt)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: acc.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$pct%',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: acc, fontWeight: FontWeight.w700)),
          ),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: acc,
            inactiveTrackColor: acc.withOpacity(0.15),
            thumbColor: acc,
            overlayColor: acc.withOpacity(0.1),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(leftLabel,
                style: GoogleFonts.dmSans(fontSize: 10, color: muted)),
            Text(rightLabel,
                style: GoogleFonts.dmSans(fontSize: 10, color: muted)),
          ]),
        ),
      ]),
    );
  }
}
