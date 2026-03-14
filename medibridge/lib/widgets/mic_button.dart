import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Mic button that pulses on every new word detected during speech recognition.
///
/// Pass [wordCount] (derived from partialText.trim().split(' ').length) so the
/// button flashes each time a new word arrives.
class MicButton extends StatefulWidget {
  final bool isListening;
  final bool isTranslating;
  final SpeakerRole activeSpeaker;
  final VoidCallback onTap;

  /// Word count from the partial transcript — increments on every new word.
  /// Derive it in the parent as:
  ///   wordCount: provider.partialText.trim().isEmpty
  ///       ? 0
  ///       : provider.partialText.trim().split(RegExp(r'\s+')).length,
  final int wordCount;

  const MicButton({
    super.key,
    required this.isListening,
    required this.isTranslating,
    required this.activeSpeaker,
    required this.onTap,
    this.wordCount = 0,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  // ── Word-flash controller ────────────────────────────────────────────────
  late final AnimationController _flashCtrl;
  late final Animation<double> _flashAnim;

  int _lastWordCount = 0;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    // Quick flash: scale up then back down
    _flashAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.12)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.12, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 60),
    ]).animate(_flashCtrl);
  }

  @override
  void didUpdateWidget(MicButton old) {
    super.didUpdateWidget(old);
    // Fire flash whenever a new word arrives while listening
    if (widget.isListening &&
        widget.wordCount > _lastWordCount &&
        widget.wordCount > 0) {
      _lastWordCount = widget.wordCount;
      _flashCtrl.forward(from: 0);
    }
    // Reset counter when we stop listening
    if (!widget.isListening) {
      _lastWordCount = 0;
    }
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  // ── Theme helpers ────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _acc => _isDark ? AppTheme.accent : AppTheme.lAccent;

  Color get _speakerColor => widget.activeSpeaker == SpeakerRole.doctor
      ? (_isDark ? AppTheme.doctorColor : AppTheme.lDoctorColor)
      : (_isDark ? AppTheme.patientColor : AppTheme.lPatientColor);

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isListening ? _speakerColor : _acc;

    return Column(
      children: [
        // ── Status label ─────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            key: ValueKey(widget.isListening
                ? (widget.isTranslating ? 'translating' : 'listening')
                : 'idle'),
            widget.isTranslating
                ? 'Translating...'
                : widget.isListening
                    ? 'Listening  •  tap to stop'
                    : 'Tap to speak',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: widget.isListening
                  ? activeColor
                  : (_isDark
                      ? AppTheme.textSecondary
                      : AppTheme.lTextSecondary),
              fontWeight:
                  widget.isListening ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Mic button ───────────────────────────────────────────────
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _flashAnim,
            builder: (_, child) => Transform.scale(
              scale: _flashAnim.value,
              child: child,
            ),
            child: _MicCore(
              isListening: widget.isListening,
              isTranslating: widget.isTranslating,
              activeColor: activeColor,
              isDark: _isDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Core visual of the mic button ───────────────────────────────────────────

class _MicCore extends StatelessWidget {
  final bool isListening;
  final bool isTranslating;
  final Color activeColor;
  final bool isDark;

  const _MicCore({
    required this.isListening,
    required this.isTranslating,
    required this.activeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.divider : AppTheme.lDivider;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isListening ? activeColor : bg,
        border: Border.all(
          color: isListening ? activeColor : border,
          width: isListening ? 2 : 1.5,
        ),
        // sin sombra/luz
      ),
      child: Center(
        child: isTranslating
            ? SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: isListening
                      ? (isDark ? AppTheme.bgDeep : Colors.white)
                      : activeColor,
                ),
              )
            : Icon(
                isListening ? Icons.mic : Icons.mic_none,
                size: 30,
                color: isListening
                    ? (isDark ? AppTheme.bgDeep : Colors.white)
                    : activeColor,
              ),
      ),
    );
  }
}
